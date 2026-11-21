---
name: tidy-rpg-library
description: Use when tidying the user's RPG library on the cistern NAS (~/RPG/Systems, ~/RPG/DriveThruRPG): hard-linking new DriveThruRPG downloads into Systems, dropping old versions, flattening single-file folders, cleaning file names, and keeping .thalium thumbnails in sync. Systems is the seed for the Thalium app (~/code/thalium).
---

# Tidy the RPG library

`~/RPG` on `cistern` (`ssh aquarion@cistern`; SMB mount at `/mnt/rpg` for read-only work). `Systems/` is what Thalium indexes; `DriveThruRPG/` is the raw download tree, kept in sync by something external that **replaces files and breaks hard links**. Re-run the link pass after each sync.

## Ground rules

- **Dry-run first, then act.** Every script in `scripts/` prints what it would do and only changes things with `--force`.
- **Only the latest version of an edition belongs in `Systems`.** Old versions stay unlinked in `DriveThruRPG` on purpose, so Thalium doesn't index them. Don't offer to relink them.
- **Layout:** one folder per system; category subfolders (Adventures, Sourcebook, Decks, Maps, Tokens, Music, Fiction, Etc) rather than one folder per product. `Etc` is for character sheets and miscellany. Avoid single-file folders. Delete empty folders.
- **Games built on a system** live inside it (Deadlands and RIFTS under Savage Worlds). Numenera and The Strange have their own folders although they are Cypher System games.
- **Classify by contents, not filenames,** when unsure (`scripts/scan_pdf_text.sh` uses `gs -sDEVICE=txtwrite` on the first pages and counts game-name keywords). Adverts for other lines give false hits, so confirm with an existing copy or the title before moving anything.
- **Product codes and tags are dropped from names** (`US82074PDF`, `UNA10020`, `CAT27453`, trailing `meta`/`BM`). Keep dates, version numbers and "Backer preview". Leave names alone where the code is the only identifier (Pathfinder chapter files).
- **One variant per item.** Keep the normal/full-spread file; leave print-quality (`300dpi`), printable single-page, STL, poster/bookmark and presentation-source (`.key`, `.pptx`) files in DriveThruRPG. Where a publisher ships a "low res" copy for size or download reasons, keep the normal one. Thalium indexing two variants of the same thing isn't useful.
- **File mtime is the download time, not the version.** The sync from DriveThru stamps files when it fetches them, so mtime says nothing about when a file was bought or updated (a batch synced on 2026-11-15 all share that date). Use version tokens in names, page-1 covers and the DriveThruRPG folder name instead; treat an mtime tie-break as a guess and say so. "Newest wins" can keep a Kickstarter preview over the finished book (Torg: `Delphi_Missions_Living_Land_v5` and `The_God_Box_v11` sat in DriveThruRPG folders named `PREVIEW (KS ONLY)` and had newer mtimes than the finals). Before deleting "older" copies, check the DriveThruRPG folder name for PREVIEW/Backer/KS, and compare page-1 covers (`gs -sDEVICE=png16m -r40 -dFirstPage=1 -dLastPage=1`, run locally on `/mnt/rpg`; the NAS has no gs). A first page of credits with no cover art usually means a preview or sample.
- A file that is smaller than the one it would replace is usually a lower-res edition or a prerelease; keep the larger one and ask.

## Gotchas

- SFTP is off: use `scp -O`, or `ssh bash -s < script.sh`. `ssh` inside a `while read` loop needs `-n`. Quote remote paths with `printf '%q'`. Paths with spaces break `scp`; upload to a safe name and `mv` over ssh.
- Run Python with `-I` when reading untrusted files. Scripts run on the NAS via `ssh aquarion@cistern 'cat > /tmp/x.py' < x.py` then `ssh -n ... 'python3 /tmp/x.py'`.
- ssh `rm` does not use the Synology `#recycle`. Skip `@eaDir`, `#recycle`, `.DS_Store`, `Thumbs.db`.
- A long command on the NAS (xrelink hashes everything) can exceed the tool timeout and go to the background; wait for it rather than starting a second copy.
- Unlinked check: `find DriveThruRPG -type f -links -2` (link count 1 = not in Systems).

## Workflow

1. **List unlinked files:** `find ... -links -2 -printf '%s\t%P\n' > unl_sizes.tsv`.
2. **Map to systems:** `scripts/map_dtrpg.py` (first-match-wins `RULES` list, fallback creates a new folder from the product name, keeps latest version per group). The rules are specific to this library, so extend them and check the `NEW` folders in its output before linking. Generate an `ln` script with `mkdir -p`, a `cmp` guard and `COLLISION` reporting, run it with `ssh bash -s`.
3. **Collisions** (same path, different content): usually a newer download over an older file. Replace with the newer (compare mtime and size) and delete the old one, except when the new file is much smaller.
4. **Unify identical copies:** `scripts/xrelink.py` (dry run, then `--force`) links identical-content files across both trees to one inode. The user's own `~/bin/relink_rpg.sh` does the same inside `DriveThruRPG`.
5. **Flatten single-file folders:** `scripts/flatten_single_file_dirs.py` moves the file into a matching category folder if one exists (keyword rules), else the system root; on a name clash the newer file wins. Review two-file folders by hand: book plus sheet pairs and PDF/EPUB/MOBI sets are fine.
6. **Clean names:** `scripts/clean_names.py` (underscores to spaces, drop "Hyperlinked/Bookmarked", trailing dates into brackets), then `scripts/strip_product_codes.py`.
7. **Dedupe versions:** group files by name with version/date tokens stripped (see `VER` in `map_dtrpg.py`); keep the highest. Filename matching misses editions with different names, so ask about those.
8. **Thumbnails:** each system needs `Systems/.thalium/<system name lowercased>.png` (the core rules' cover page: `gs -sDEVICE=png16m -r100 -dFirstPage=1 -dLastPage=1`, then `magick ... -fuzz 8% -trim +repage -resize 200x`). Moran and Misc have none by design. Remove thumbnails whose system no longer exists, and rename them when a system folder is renamed.
9. **Report:** counts, new folders, collisions, what was deleted for good (files with link count 1 are gone), and what is still unlinked and why.
