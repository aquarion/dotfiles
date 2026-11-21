import os, re, sys, collections
force = '--force' in sys.argv
os.chdir(os.path.expanduser('~/RPG/Systems'))
EXT = ('.pdf', '.zip', '.epub', '.mobi', '.rar', '.7z', '.docx')
LEAD = re.compile(r'^(?:[A-Za-z]{1,5}\d{3,}[A-Za-z]{0,5}|[A-Z]{2,5}\d{2,}[A-Za-z]?|CAT\d+|PZO\d+E?)(?:PDF)?[ -]+')
TRAIL = re.compile(r'(?:\s+(?:BM|ShopPDF|Shop-PDF|KaufPDF|Kauf PDF|meta))+$', re.I)
def clean(stem):
    s = LEAD.sub('', stem)
    for _ in range(3): s = TRAIL.sub('', s)
    s = re.sub(r'\s{2,}', ' ', s).strip(' -')
    return s
res = collections.OrderedDict(); clash = 0; n = 0
for root, dirs, files in os.walk('.'):
    dirs[:] = sorted(d for d in dirs if d not in ('@eaDir', '.thalium'))
    for f in sorted(files):
        stem, ext = os.path.splitext(f)
        if ext.lower() not in EXT: continue
        if re.match(r'(PZO|SDL1024)', stem): continue
        new = clean(stem)
        if not new or ' ' not in new or new == stem: continue
        dst = os.path.join(root, new + ext)
        if os.path.exists(dst) or dst in res:
            print('CLASH', os.path.join(root, f)[2:], '->', new + ext); clash += 1; continue
        res[dst] = 1
        print(os.path.join(root, f)[2:], '->', new + ext)
        if force: os.rename(os.path.join(root, f), dst)
        n += 1
print(n, 'renamed', clash, 'clashes')
