#!/usr/bin/env python3
"""Plan hard links from unlinked DriveThruRPG files into Systems. Writes plan.tsv + prints summary."""
import re, os, collections, html

EXISTING = set(os.listdir('/mnt/rpg/Systems')) - {'@eaDir'}

# (regex on "publisher/product/file", Systems destination)  first match wins
RULES = [
 (r'delta green', 'Delta Green'),
 (r'dozen sugary rumors', 'Philip Reed Games'),
 (r'cthulhu confidential', 'Cthulhu Confidential'),
 (r"night.s black agents", "Night's Black Agents"),
 (r'blades in the dark', 'Blades In The Dark'),
 (r'dresden files', 'Fate'),
 (r'uncanny echo', 'Powered by the Apocalypse'),
 (r'^Artemis', 'Jigsaw Fantasy'),
 (r'secret world|TSW', 'The Secret World'),
 (r'blue rose', 'Blue Rose'),
 (r'voidheart', 'Voidheart Symphony'),
 (r'shattered city', 'Shattered City'),
 (r'm[oö]rk borg|bork borg|cthork|bork cthorg|dire mutterings|bergen chrypt|dungeoneer|galgenbeck|purgatory|miserere|rumrunner|seven strangers|faces in the crowd|moonlight and tide|signs in the entrails|tombs of our ancestors|quiet country home|macallen farm|curic|wizard.s dying|^Christian Eichhorn/', 'MORK BORG'),
 (r'^Philip Reed', 'Philip Reed Games'),
 (r'ORC BORG', 'Grant Howitt'),
 (r'Resistance Toolbox', 'Grant Howitt'),
 (r'Deadlands Noir', 'Savage Worlds Deluxe/Deadlands Noir'),
 (r'deadlands|DLWW|weird west|crater lake|carnage in the cascades|abominable northwest|black circle|hell on the high plains|showdown at sundown|marshal.s notes|headstone hill', 'Deadlands'),
 (r'rifts', 'Savage Worlds/RIFTS'),
 (r'fantasy|tyrant isle|turning of the leaves|earthshaker', 'Savage Worlds/Fantasy Companion'),
 (r'Pinnacle|Savage Worlds|SWADE', 'Savage Worlds'),
 (r'secret world|TSW', 'The Secret World'),
 (r'Torg|Infiniverse|Aysle|Tharkold|Nile|Pan-Pacifica|Cyberpapacy|Orrorsh|Living Land|Possibility Wars|Relics of Power|Destiny Deck|Drama Deck|Blasted Lands|UNA10020|Ulisses', 'Torg Eternity'),
 (r'eclipse phase|Posthuman', 'Eclipse Phase'),
 (r'exalted|scoundrelsong|what lies forgotten|tomb of memory|deeds yet undone', 'Exalted Essence'),
 (r'pugmire|monarchies of mau|squeaks|pirates|good dogs|pan.s guide|curious cats|vinsen|buried bones|sunken bones|Onyx Path', 'Realms of Pugmire'),
 (r'shadowrun|Catalyst', 'Shadowrun'),
 (r'heart[_ ]|vermissian', 'Heart'),
 (r'spire|strata|kings of silver|book of masks|secrets kept|golden serpent|Rowan', 'Spire'),
 (r'tribe ?8|tribes in the dark|Dream Pod', 'Tribe8'),
 (r'invisible sun', 'Invisible Sun'),
 (r'the strange|into the night|into the deep|expanded worlds|estate dossiers|ohunkakan|infinity shift|the takings|nightcraft', 'The Strange'),
 (r'cypher|heist on miracle|extreme cyphers', 'Cypher System'),
 (r'numenera|ninth world|violet vale|swordbreakers|teratology|silent streets|dark spiral|explorer.s guide|eschatology|beyond all worlds|dread expectations|enchiridion|the key|the gate|the path|the way|castaway|book m|cults, factions|assault on singularity|when worlds collide|welcome to the digital|introduction|consent in gaming|coupon|TSPG|Monte Cook', 'Numenera'),
 (r'orbital blues|afterburn', 'Orbital Blues'),
 (r'inevitable', 'Inevitable'),
 (r'aegean|we evolve', 'Aegean'),
 (r'shadow of the demon lord|demon lord|hunger in the void|terrible beauty|exquisite agony|tombs of the desolation|uncertain faith|glorious death|last hope|Schwalb', 'Shadow Of The Demon Lord'),
 (r'unknown armies|maria in three', 'Unknown Armies'),
 (r'ars magica', 'Ars Magica'),
 (r'Cubicle 7.*Laundry|laundry', 'The Laundry Files'),
 (r'Opera House', 'Opera House'),
 (r'wyrd abacus', 'Wyrd Abacus'),
 (r'solemn vale', 'Solemn Vale'),
 (r'carbon 2185|Dragon Turtle', 'Carbon 2185'),
 (r'apocalypse keys', 'Apocalypse Keys'),
 (r"blades '68|b68_", 'Blades 68'),
 (r'fate|ngen_mapu|weird_world_news|venture city', 'Fate'),
 (r'brinkwood', 'Brinkwood'),
 (r'vaesen', 'Vaesen'),
 (r'blue rose', 'Blue Rose'),
 (r'silver road', 'The Silver Road'),
 (r'Greg Stolze|ninki', 'Greg Stolze'),
 (r'glitch', 'Glitch'),
 (r'Jenna Katerin Moran|far roofs|flood|unclean legacy|fable of the swan|night-bird', 'Moran'),
 (r'urban shadows', 'Urban Shadows 2nd Ed'),
 (r'^Modiphius/.*Legacy', 'Legacy'),
 (r'Mongoose|paranoia|DPM_', 'Paranoia'),
 (r'fabula ultima', 'Fabula Ultima'),
 (r'trail of cthulhu|kingsbury|boundary of the darkness', 'Trail Of Cthulhu'),
 (r'Practical Fox|beat the boss', 'Powered by the Apocalypse'),
 (r'catthulhu|cats of cat', 'Cats Of Cathulhu'),
 (r'hard wired island', 'Hard Wired Island'),
 (r'changeling|White Wolf', 'White Wolf'),
 (r'Prism Hobbies|Game Mechanics', 'Misc'),
 (r'^Alea', 'Genesis Roleplaying System'),
 (r'^Signal Fire', 'Building An Elder God'),
]

def clean_publisher(p):
    return html.unescape(p).replace('_', ':') if False else html.unescape(p)

def system_for(path):
    for rx, dest in RULES:
        if re.search(rx, path, re.I):
            return dest
    return None

VER = re.compile(r'(\d{4}[-._]\d{2}[-._]\d{2}|(?<!\d)\d{8}(?!\d)|[vV]?\d+(?:[._]\d+)+|[vV]\d+|[Uu]pdated\w*?\d{4})')
def vkey(name):
    stem = os.path.splitext(name)[0]
    nums = []
    for m in VER.finditer(stem):
        nums += [int(x) for x in re.findall(r'\d+', m.group(0))]
    return tuple(nums)
def gkey(name):
    stem, ext = os.path.splitext(name)
    return re.sub(r'[\W_]+', ' ', VER.sub('', stem)).strip().lower() + ext.lower()

rows = []
for l in open('unl_sizes.tsv', encoding='utf-8', errors='replace'):
    s, p = l.rstrip('\n').split('\t', 1)
    rows.append((int(s), p))

# latest-only within a directory
groups = collections.defaultdict(list)
for s, p in rows:
    d, n = os.path.split(p)
    groups[(d, gkey(n))].append((vkey(n), s, p))
keep, old = [], []
for g in groups.values():
    g.sort()
    keep.append(g[-1][2]); old += [x[2] for x in g[:-1]]

plan, unmatched = [], []
for p in sorted(keep):
    parts = p.split('/')
    pub, rest = html.unescape(parts[0]), parts[1:]
    prod = rest[0] if len(rest) > 1 else None
    sysdest = system_for(pub + '/' + '/'.join(rest))
    if sysdest is None:
        # new system folder named after the product dir, or the file stem
        sysdest = clean = re.sub(r'\s*_\s*', ' - ', prod) if prod else re.sub(r'[_]+', ' ', os.path.splitext(rest[-1])[0])
        unmatched.append((p, sysdest))
    sub = re.sub(r'\s*_\s*', ' - ', prod).strip(' -') if prod else ''
    if sub == sysdest: sub = ''
    dest = '/'.join(x for x in (sysdest, sub) if x) + '/' + rest[-1]
    plan.append((p, dest))

with open('plan.tsv', 'w') as f:
    for p, d in plan:
        f.write(f'{p}\t{d}\n')
with open('old_versions.txt', 'w') as f:
    f.write('\n'.join(sorted(old)) + '\n')

print(len(rows), 'unlinked;', len(plan), 'to link (latest only);', len(old), 'older versions skipped')
c = collections.Counter(d.split('/')[0] for _, d in plan)
for k, v in sorted(c.items()):
    print(f'{v:4d} {"NEW " if k not in EXISTING else "    "}{k}')
