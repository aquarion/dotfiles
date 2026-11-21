import os, sys, hashlib, collections
force = len(sys.argv) > 1 and sys.argv[1] == '--force'
root = os.path.expanduser('~/RPG')
ino = collections.defaultdict(list)   # (dev,ino) -> paths
size = {}
for tree in ('DriveThruRPG', 'Systems'):
    for dp, dn, fn in os.walk(os.path.join(root, tree)):
        dn[:] = [d for d in dn if d not in ('@eaDir', '#recycle')]
        for f in fn:
            if f in ('.DS_Store', 'Thumbs.db'): continue
            p = os.path.join(dp, f)
            st = os.lstat(p)
            if not os.path.isfile(p) or os.path.islink(p) or st.st_size < 20000: continue
            ino[(st.st_dev, st.st_ino)].append(p); size[(st.st_dev, st.st_ino)] = st.st_size
bysize = collections.defaultdict(list)
for k, s in size.items(): bysize[s].append(k)
def md5(p):
    h = hashlib.md5()
    with open(p, 'rb') as f:
        for c in iter(lambda: f.read(1 << 20), b''): h.update(c)
    return h.hexdigest()
n = 0; groups = 0
for s, ks in bysize.items():
    if len(ks) < 2: continue
    if not any('/DriveThruRPG/' in p for k in ks for p in ino[k]): continue
    byh = collections.defaultdict(list)
    for k in ks: byh[md5(ino[k][0])].append(k)
    for h, kk in byh.items():
        if len(kk) < 2: continue
        groups += 1
        best = max(kk, key=lambda k: (len(ino[k]), any('/Systems/' in p for p in ino[k])))
        bp = ino[best][0]
        for k in kk:
            if k == best: continue
            for p in ino[k]:
                n += 1
                if force:
                    os.unlink(p); os.link(bp, p)
                else:
                    print('would link', p.replace(root + '/', ''), '->', bp.replace(root + '/', ''))
print(('relinked' if force else 'would relink'), n, 'paths in', groups, 'groups')
