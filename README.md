# AbyssTracker

A Windower 4 addon for FFXI that tracks Abyssea NM pop chains, key items, inventory, and drop progress across all nine Abyssea zones simultaneously.

**Current version: v3.0**

---

## Features

### Zone Overview
- Browse all 9 Abyssea zones grouped by expansion (Vision / Scars / Heroes)
- Per-zone pop readiness badge shows how many bosses you can currently pop `[2/4 pop]`
- Click any zone to view its NM list

### NM Pop Chain Tracking
- Full nested pop chain display — boss → forced NMs → farm mobs
- Green/red checkbox for each pop item based on live inventory
- Counts items across all bags simultaneously (inventory, case, satchel, sack, wardrobes)
- Shows nearest conflux number and map coordinates for each NM
- Conflux number shown next to boss name in the NM list (e.g. `T5 Chloris (I-8) #7`)
- Automatically refreshes every 5 seconds

### Drop Overview
- Boss trial drops (Chloris Bud, Glavoid Shell, etc.) grouped by zone and NM — click any line to jump to that NM's pop chain, or click the item name to see all sources
- Color gradient: grey (0) → yellow → green (50+) shows farming progress at a glance

### Empyrean Armor +1
- Dedicated screen per job showing all five seal slots with live inventory counts
- All 20 jobs in FFXI canonical order across two tab rows (WAR MNK WHM BLM RDM THF PLD DRK BST BRD RNG SAM NIN DRG SMN BLU COR PUP DNC SCH)
- Click any seal to see a full list of NMs that drop it with direct navigation links

### Empyrean Armor +2
- Currency series (Vision / Voyage / Ardor / Balance / Wieldance) in two-column layout with live counts
- Click any currency item to see which NMs drop it with direct navigation links

### Drop Sources
- Click any item in the Boss Drops, +1, or +2 screens to open a Sources view
- Lists all NMs that drop the item, with zone colour coding
- Each NM is a clickable link that navigates directly to its pop chain or entity view
- Breadcrumb navigation back to whichever screen you came from

### Map Display
- Per-zone BMP map shown alongside the tracker
- Configurable position: right / bottom / left / top of the main panel
- Adjustable size (100–1000 px) via Cfg buttons or `Shift+Scroll`
- Persistent map prim — no flicker when dragging or navigating
- Texture loads once per zone change; repositions instantly

### Configuration
- All settings persist across sessions (position, size, opacity, font, map)
- Scroll wheel shortcuts: `Scroll` = opacity, `Ctrl+Scroll` = width, `Alt+Scroll` = font size, `Shift+Scroll` = map size
- Full Cfg panel accessible in-UI or via commands

### Extras
- Trust set recall: assign a `/console trust recall <set>` name per boss
- Atma notes: override atma suggestions per NM
- Conflux override: set preferred conflux per NM

---

## Installation

1. Copy the `AbyssTracker` folder into `Windower/addons/`
2. Copy all `data/*.lua` files into `AbyssTracker/data/`
3. Copy all `maps/*.bmp` map images into `AbyssTracker/maps/`
4. In-game: `//lua load abysstracker` or add to `init.txt`

### Folder structure
```
Windower/addons/AbyssTracker/
├── AbyssTracker.lua
├── data/
│   ├── tahrongi.lua
│   ├── latheine.lua
│   ├── konschtat.lua
│   ├── misareaux.lua
│   ├── vunkerl.lua
│   ├── attohwa.lua
│   ├── grauberg.lua
│   ├── altepa.lua
│   ├── uleguerand.lua
│   └── abyssea_drops.lua
└── maps/
    ├── tahrongi.bmp
    ├── latheine.bmp
    ├── konschtat.bmp
    ├── misareaux.bmp
    ├── vunkerl.bmp
    ├── attohwa.bmp
    ├── grauberg.bmp
    ├── altepa.bmp
    └── uleguerand.bmp
```

---

## Commands

Commands use `//at` or `//abysstracker`.

### Navigation
| Command | Description |
|---|---|
| `//at zone <name>` | Navigate to zone (partial match, e.g. `//at zone tahr`) |
| `//at nm <name>` | Navigate to NM across all zones (e.g. `//at nm chloris`) |
| `//at track <name>` | Alias for `nm` |
| `//at overview` | Open the Drop Overview screen |
| `//at list` | List all trackable NMs in chat, grouped by zone |
| `//at bg` | Open BG-wiki page for the currently viewed NM |

### Display
| Command | Description |
|---|---|
| `//at show` | Show the tracker |
| `//at hide` | Hide the tracker |
| `//at min` | Toggle minimize |
| `//at map` | Toggle map panel on/off |
| `//at pos` | Cycle map position (right → bottom → left → top) |
| `//at size <n>` | Set map size in pixels (100–1000) |
| `//at refresh` / `//at r` | Force inventory and key item refresh |

### Settings
| Command | Description |
|---|---|
| `//at alpha <n>` | Set panel opacity (20–245) |
| `//at font <n>` | Set font size (8–16) |
| `//at width <n>` | Set panel width (300–600) |
| `//at cflx <nm> <id>` | Override conflux for an NM (e.g. `//at cflx Chloris 3`) |
| `//at trust set <nm> <set>` | Assign trust set to NM (e.g. `//at trust set Chloris chloris`) |
| `//at atma add <nm> <text>` | Add atma note for an NM |
| `//at atma clear <nm>` | Clear atma notes for an NM |
| `//at help` | Show full command list in chat |

---

## Data Files

### Zone files (`data/<zone>.lua`)

Each zone file defines the boss list, pop chains, and conflux positions for one Abyssea zone. Zone files live in `data/` and follow this structure:

```lua
return {
    zone_name = 'Abyssea - Tahrongi',
    zone_id   = 45,
    confluxes = {
        [1]={pos='H-12'}, [2]={pos='H-9'}, -- ...
    },
    nms = {
        {
            name       = 'Chloris',
            pos        = 'I-8',
            conflux    = 7,
            goal_drops = {
                {id=2928, name='2Lf. Chloris Bud', type='item', target=50},
            },
            atma   = {'Atma of the Merciless Matriarch'},
            trusts = {'TBD'},
            chain  = {
                {
                    nm        = 'Ophanim',
                    pos       = 'G-9',
                    conflux   = 3,
                    timed     = false,
                    ki        = {id=1468, name='Veinous Hecteyes Eyelid'},
                    pop_items = {
                        {id=2917, name='Bl. Hecteye', from='Beholder', from_pos='G-9', from_conflux=3},
                        {id=2946, name='Tarnished Pincer', from='Vetehinen', from_pos='H-10',
                         pop_items = {
                             {id=2916, name='H.Q. Lim. Pincer', from='Gulch Limule', from_pos='H-10'},
                         }},
                    },
                },
                {nm='Chukwa', pos='F-5', conflux=6, timed=true,
                 ki={id=1471, name='Mossy Adamantoise Shell'}, pop_items={}},
            },
        },
    },
}
```

**Key fields:**

| Field | Description |
|---|---|
| `confluxes` | Map of conflux number → grid position for the zone |
| `chain[]` | Ordered list of NMs whose KIs are needed to pop the boss |
| `chain[].conflux` | Nearest conflux number for this NM |
| `chain[].ki.id` | Windower key item numeric ID |
| `chain[].timed` | `true` = spawns on a timer, no pop items needed |
| `chain[].pop_items[].id` | Windower item numeric ID (preferred over name for inventory lookup) |
| `chain[].pop_items[].name` | Windower abbreviated item name (e.g. `Bl. Hecteye`) |
| `goal_drops[].target` | Farming target quantity |

Item names must match Windower's abbreviated `en` field from `resources/items.lua`. Use numeric `id` wherever possible — the addon prefers ID-based inventory lookup.

### abyssea_drops.lua (`data/abyssea_drops.lua`)

Defines Empyrean Armor upgrade data used by the +1 and +2 screens:

- **`currencies`** — the five currency series (Vision/Voyage/Ardor/Balance/Wieldance), each item listing NM sources for the Drop Sources view
- **`seals`** — all 20 jobs × 5 slots with in-game abbreviated item names (e.g. `Charis Seal: Hd.`) and 2–3 NM sources per slot, verified against bg-wiki
- **`job_display_order`** — canonical FFXI job order used for the +1 tab row

---

## Dependencies

- [Windower 4](https://www.windower.net/) with the following standard libraries:
  - `texts`
  - `resources`
  - `config`

---

## Changelog

### v3.0
- Two-row header: "Abyssea Tracker" title bar (drag zone) above nav/breadcrumb row
- Drop Overview restructured: Boss Drops always visible, `>> Empyrean Armor +1` and `>> Empyrean Armor +2` navigate to dedicated full screens
- **Empyrean Armor +1**: all 20 jobs in FFXI canonical order across two tab rows; correct in-game abbreviated seal names (`Rvg.`, `Aoid.`, `Estq.` etc.); click any seal to see drop sources
- **Empyrean Armor +2**: five currency series with per-item NM source data; click any currency to see drop sources
- **Drop Sources screen**: click any item across all three overview screens to see every NM that drops it, with direct navigation links to the pop chain
- Conflux number now shown next to boss NM name in the zone NM list
- `abyssea_drops.lua` v2.0: full seal table (all 20 jobs × 5 slots × 2–3 NM sources, bg-wiki verified), currency NM sources, canonical job order

### v2.6
- Unified `item_label`/`farm_label` format functions
- Drag-move with no flicker
- NM|PI/KI|(pos)[#] chain format
- Persistent map prims
- Two-row header
- ID-based inventory lookup
- Pool detection and target counts

### v2.5 and earlier
- Initial zone tracking, pop chain display, map integration, trust/atma/conflux overrides

---

## Credits

- **Maquis** (Phoenix) — design, development, in-game testing
- NM data cross-referenced with [EmpyPopTracker](https://github.com/devonbwied/empypoptracker) by Dean James (Xurion of Bismarck)
- Zone maps sourced from the FFXI wiki and pre-scaled for display
- Seal and currency drop data verified against [bg-wiki.com/ffxi/Abyssea_Guide](https://www.bg-wiki.com/ffxi/Abyssea_Guide)

---

## License

MIT License — free to use, modify, and distribute with attribution.
