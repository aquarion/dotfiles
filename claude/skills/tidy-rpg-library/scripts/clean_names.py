import os, re, sys
force = '--force' in sys.argv
os.chdir(os.path.expanduser('~/RPG/Systems'))
EXT = ('.pdf', '.zip', '.epub', '.mobi', '.rar', '.7z', '.docx')
HYP = re.compile(r'[-_ ]*\(?\b(?:hyperlinked[ _]*(?:and|&)?[ _]*bookmarked|bookmarked[ _]*(?:and|&)?[ _]*hyperlinked|hyperlinkedbookmarked|hyperlinked|bookmarked)\b\)?', re.I)
DATE = re.compile(r'[-_ ]+(\d{4}-\d{2}-\d{2})$')
def clean(stem):
    s = stem.replace('%20', ' ')
    s = HYP.sub('', s)
    s = s.replace('_', ' ')
    s = DATE.sub(r' (\1)', s)
    s = re.sub(r'\(\s+', '(', s); s = re.sub(r'\s+\)', ')', s)
    s = re.sub(r'\s{2,}', ' ', s).strip(' -')
    return s
n = skip = 0
for root, dirs, files in os.walk('.'):
    dirs[:] = [d for d in dirs if d not in ('@eaDir', '.thalium')]
    for f in files:
        stem, ext = os.path.splitext(f)
        if ext.lower() not in EXT: continue
        if not re.search(r'_|%20|hyperlink|bookmark', f, re.I): continue
        new = clean(stem) + ext
        if new == f or not stem: continue
        src, dst = os.path.join(root, f), os.path.join(root, new)
        if os.path.exists(dst):
            print('CLASH', src, '->', new); skip += 1; continue
        print(src[2:], '->', new)
        if force: os.rename(src, dst)
        n += 1
print(n, 'renamed', skip, 'clashes')
