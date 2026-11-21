# Sonarr v4 recipes for fixing identified files

All calls use `X-Api-Key` from Sonarr's `config.xml` (`<ApiKey>`), base `http://127.0.0.1:8989/api/v3`. When Sonarr runs in a container the paths it reports (`/data/...`) differ from the host's: map them before touching the disk. Run scripts by piping them over ssh stdin (`ssh host 'sudo python3 -I -' < script.py`); write them to a file first, because apostrophes in filenames break inline shell quoting.

## Reading state

```
GET /series                                              # find the family: filter by title/year/tvdbId
GET /episode?seriesId=N&includeEpisodeFile=true          # per episode: title, runtime, hasFile, episodeFile{id,path,size}
GET /episodefile?seriesId=N
```
Match series by **tvdbId**, not name. Use `episode.runtime` (minutes) for the per-episode length test.

## Assign a file to the right series/episode (also moves it between series)

```
GET  /manualimport?folder=<dir as Sonarr sees it>&filterExistingFiles=false     # take quality/languages from the item with your path
POST /command  {"name":"ManualImport","importMode":"move","files":[
   {"path":P,"seriesId":S,"episodeIds":[E],"quality":Q,"languages":L,"releaseGroup":"","downloadId":"","indexerFlags":0,"releaseType":"singleEpisode"}]}
poll GET /command/{id} until completed
```
Behaviour verified in practice:
- Works for an **untracked** file and for a file already tracked to the **wrong** episode; the wrong episode loses its file and the right one gains it (no duplicate record).
- Re-assigning a file **inside the same folder changes the database only**; the file keeps its old name. Follow with a rename.
- Moving a file into **another series** moves and renames it into that series' folder.
- Importing onto an episode that **already has a file replaces it** (the old file is deleted, there is no recycle bin by default). Good for a quality swap, dangerous if you didn't mean it; check `hasFile` first.
- `GET /manualimport?seriesId=N` lists that series' own folder and ignores `folder`; use `folder` only.

## Rename

```
GET  /rename?seriesId=N                                    # preview: existingPath -> newPath
POST /command {"name":"RenameFiles","seriesId":N,"files":[episodeFileId]}
```
The preview renames to the **current** mapping: re-map first, then rename, or you will bake the wrong name in. Specials go to a `Specials/` folder; companion `.nfo`/thumbs move with the file.

## Delete

`DELETE /episodefile/{id}` removes the record **and the file on disk**, so do not use it: `mv` the file to the trash with `scripts/trash.sh`, then `RescanSeries` so Sonarr drops the record. Only trash a file with a verified same-length tracked twin (or one the user chose to drop); an untracked file is trashed the same way.

## Stale records and rescans

- After a file is moved out of a folder, the old episode can briefly still show `hasFile`. Before deleting a "stale" record, check that its **path really doesn't exist**. A `RescanSeries` can re-map files by filename S/E: in one case a rescan attached the correct 720p file to the right episode by itself, and deleting the "stale" record would have been a mistake. Always re-read the episode after a step.
- A guard worth keeping in scripts: `assert not os.path.exists(path)` before deleting a record.

## Probing commands (host with ffmpeg)

```
ffprobe -v error -show_entries format=duration:format_tags=title -of default=nw=1 FILE        # length + embedded title
ffprobe -v error -show_entries format=duration -of csv=p=0 FILE                               # seconds
ffmpeg -v error -accurate_seek -ss 00:00:32.01 -i FILE -frames:v 1 frame.jpg                  # one frame (title card)
ffmpeg -v error -t 300 -i FILE -vf 'fps=1/20,scale=480:270,tile=4x4' -frames:v 1 sheet.jpg    # 5-minute contact sheet
```
Copy the JPEGs to where you can Read them (`ssh host '... -f image2pipe -vcodec mjpeg -' > local.jpg`). ImageMagick `montage` combines several frames into one image to save reading effort.

## Worked example (Taskmaster, UK/AU/NZ/US/SE/NO/Champion of Champions)

Audit of 359 files found: 245 correct, 30 Australian episodes filed under the UK show with Australian titles, 22 same-length duplicates, 6 specials mapped to the wrong episode by number, and about 23 generic names.
- **Lengths alone** showed 18 "Australian" files were byte-for-byte the same length as the tracked UK episodes (same video, wrong name), and 12 fitted only Australian runtimes.
- **Embedded tags** identified six YouTube-origin specials the filenames called "New Year Treat" (Taskmastermind, Ultimate Episode, Outtakes), and a UK "keeper" that was really Champion of Champions 2025.
- **Title cards** confirmed Australian files ("TASKMASTER AUSTRALIA" logo, Channel 10 promo), and exposed three UK episodes (host Greg Davies, UK house) that a title-and-length check had wrongly imported into the Australian series. Captions in the first task ("Fear of failure.", "A pea in a haystack", "A fat bald white man.") confirmed or refuted each keeper.
- Outcome: 41 duplicates and 2 alternate cuts deleted, 14 files moved to their true series, 6 specials remapped and renamed, a mislabelled keeper swapped for the real episode, and a 1080p copy upgraded into the right series.
