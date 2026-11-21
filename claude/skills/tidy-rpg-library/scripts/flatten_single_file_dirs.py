import os, re, sys, shutil, datetime, filecmp
force = '--force' in sys.argv
os.chdir(os.path.expanduser('~/RPG/Systems'))
cut = 0
CATS = [  # (keyword regex, candidate existing folder names)
 (r'soundtrack|music|\bost\b|mp3', ['Music']),
 (r'novel|novella|fiction|stories|comic|journal', ['Fiction']),
 (r'\bmaps?\b|poster|battle ?mat', ['Maps']),
 (r'\bdeck|\bcards?\b|card set', ['Decks', 'Cards']),
 (r'token|pawn|figure flats?|standee|stl', ['Tokens']),
 (r'adventure|scenario|mission|one-?shots?|jumpstart|nano op|campaign|operation', ['Adventures', 'Adventure']),
 (r'character sheet|screen|handout|forms?\b|primer|wallpaper|vtt|archetypes?', ['Etc']),
 (r'guide|sourcebook|companion|supplement|bestiary', ['Sourcebooks', 'Sourcebook', 'Guides']),
]
SKIP = {'Etc','Decks','Maps','Fiction','Music','Adventure','Adventures','Sourcebook','Sourcebooks','Worlds','Places','Creatures',
        'Companion','Conversions','Player Assist','Tokens','Cards','Guides','Illustration','Locations','Old','@eaDir','Beginner\'s Box'}
SYS = sorted(d for d in os.listdir(".") if os.path.isdir(d) and not d.startswith("."))
def real(p): return [f for f in os.listdir(p) if f not in ('@eaDir', '.DS_Store', 'Thumbs.db')]
moved = clash = 0
for s in SYS:
    for d in sorted(os.listdir(s)):
        p = os.path.join(s, d)
        if d in SKIP or not os.path.isdir(p) or os.stat(p).st_mtime < cut: continue
        fs = real(p)
        if len(fs) != 1 or not os.path.isfile(os.path.join(p, fs[0])): continue
        f = fs[0]; name = d + ' ' + f
        dest = s
        for rx, cands in CATS:
            if re.search(rx, name, re.I):
                hit = [c for c in cands if os.path.isdir(os.path.join(s, c))]
                if hit: dest = os.path.join(s, hit[0]); break
        src, tgt = os.path.join(p, f), os.path.join(dest, f)
        if os.path.exists(tgt):
            if os.path.samefile(src, tgt) or filecmp.cmp(src, tgt, shallow=False):
                print('DUPLINK', src, '==', tgt)
                if force: os.unlink(src); shutil.rmtree(os.path.join(p, '@eaDir'), True); os.rmdir(p)
                moved += 1
            elif os.stat(src).st_mtime > os.stat(tgt).st_mtime and os.path.getsize(src) > 0.8 * os.path.getsize(tgt):
                print('NEWER', src, '->', tgt, os.path.getsize(tgt), '->', os.path.getsize(src))
                if force:
                    os.unlink(tgt); os.rename(src, tgt); shutil.rmtree(os.path.join(p, '@eaDir'), True); os.rmdir(p)
                moved += 1
            else:
                print('CLASH', src, '|', tgt); clash += 1
            continue
        print(dest.split('/',1)[-1] if dest != s else '.', '<-', src)
        if force:
            os.rename(src, tgt); shutil.rmtree(os.path.join(p, '@eaDir'), True); os.rmdir(p)
        moved += 1
print(moved, 'moved', clash, 'clashes')
