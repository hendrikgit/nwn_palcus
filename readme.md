# nwn_sqlite
Extracts information from a [Neverwinter Nights](https://www.beamdog.com/games/neverwinter-nights-enhanced/) module and saves it to a [sqlite3](https://www.sqlite.org/index.html) file. sqlite databases can be read and queried via nwscript beginning with version 8193.14.

This program is written in [Nim](https://nim-lang.org/) and uses the excellent [neverwinter.nim](https://github.com/niv/neverwinter.nim) library to do all the work.

![creaturepalcus.sqlite3 database view in gui](screenshots/creaturepalcus.png)

For [table schemas see below](#table-schemas).

If you are missing a column or a whole table that would be useful to you please contact me or open a GitHub issue and I'll add it.

## Download binaries
Binaries are available for download on the [releases](https://github.com/hendrikgit/nwn_sqlite/releases) page.

## What exactly does it do?
It reads the information from Neverwinter files. A .mod file can be read and/or various GFF files like `.are`, `.utc`, `.uti` and so on. Names are looked up by reading the relevant `.2da` files and looking up strrefs in `dialog.tlk` or a possible custom tlk. The paths to these additional resources can be provided as command line parameters. The tool will run without dialog.tlk or .2da files but then some columns might not be filled.

That data is then written to a sqlite3 database file.

The `-2da:` parameter can be used to convert any .2da file to a SQLite table. This parameter can be used multiple times. See also the [hint](#hints) about `cast`.  
Use with `-2daonly` to create a database with only the requested .2da file tables.

The `-withkey` parameter can be used to include resources from the base game which are skipped by default.

## Why do I need this?
Having this sqlite table will allow you to query information comfortably and quickly via nwscript. Perhaps to select the most fitting creatures to spawn for an encounter. The sqlite database can be used by many other tools, too, like the graphical database tool seen in the screenshot above for a great overview.

Here are a few use cases. Also check out the [list of example queries](queries.md).
1) **Statistics**. Find out what kind of resources you have or miss in the module. For instance items by base class, creature by class, but also what music is used most/least etc.
2) **Cleanup**. Find mistakes like spelling inconsistencies, broken resources, outliers like too high CR of a creature.
3) **In-game lookup** if you want to select items or creatures within nwscript systems according to some criteria. For instance you could implement a loot system based on that or DM navigation between areas or DM persistent placeable setup system using the tables.
4) **Data pool** for own tables. Related to 3) but slightly different. You might want to create your own subset of data, for example only item names, resrefs, tags and base item type and drop everything else to design and maintain an own data table and just do an initial import once.

## Usage
A good start is to run the program and keep adding paths until there are no more warning messages.  

**Warning: Existing tables in the sqlite database file will be dropped (and recreated and filled with new data).**

Example program call on Linux:
```
./nwn_sqlite -o:sf.sqlite3 ~/server/modules/SoulForge.mod ~/Beamdog\ Library/00785/lang/en/data/ ~/Beamdog\ Library/00785/data/ ~/server/tlk/ ~/server/hak ~/server/override
```

### Hints
* If there are any warnings it will work but it means some information will be missing in the tables!
* Don't forget the servers override folder.
* Column names in queries are case insensitve.
* On macOS the tool needs to be allowed to run because of strict execution rules. The developer is unknown, macOS will complain. Allow it by holding ctrl right click on the file and open.
* All colums, except id, of tables generated via the `-2da:` parameter have the type `TEXT`. To treat values as, for example, INTEGER use `cast(colname as integer)`. See https://sqlite.org/lang_expr.html#castexpr.

### Example queries
See [the list](queries.md) of useful, interesting or funny example queries.

## Language
A dialog.tlk file of any language should work. The language of the provided dialog.tlk will also be used when looking up localized strings. If a localized string has no entry for the language the dialog.tlk is in, then next english will be tried and lastly the first language with a value

Use the `-e:encoding` parameter to use a different input encoding (default is windows-1252). This can be used for Cyrillic (cp1251) for example.

## Speed
On my computer with my module file it takes less than a second to create the sqlite3 file. This tool could possibly be run at each nwserver start to always have up to date information for the running module.

## Build
* Install [Nim](https://nim-lang.org/)
* Clone this repo
* A sqlite3 library (like libsqlite3 on Debian) needs to be installed on your system (or see the last point)
* Run `nimble build -d:release`
* For creating a static binary the nimble tasks defined in [nwn_sqlite.nimble](nwn_sqlite.nimble) can be used. The tasks `musl` and `win` assume you are building on Linux, `macos` needs to be run on macOS.

## Table schemas
Schemas for the tables in the sqlite3 database file that will be written.  
To generate schema output like what is seen below run:
```
sqlite3 dbname.sqlite3 < schemas.sqlite | sed -r 's/.{9}$//'
```
[schemas.sqlite](schemas.sqlite) contains the commands to generate the table info. Piping the output from above command to the [update_readme_schemas.rb](update_readme_schemas.rb) ruby script will directly update this readme file.

Column names match the names of the fields/keys in the corresponding gff. Additional columns beginn with an underscore.

**Tables**
* [areas](#areas)
* [creatures](#creatures)
* [items](#items)
* [placeables](#placeables)
* [appearance2da](#appearance2da)
* [placeables2da](#placeables2da)
* [ambientmusic2da](#ambientmusic2da)
* [ambientsound2da](#ambientsound2da)
* [tilesets](#tilesets)
* [area_encounters](#area_encounters)
* [area_encounters_creatures](#area_encounters_creatures)
* [ute_encounters](#ute_encounters)
* [ute_encounters_creatures](#ute_encounters_creatures)

### areas
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    Name                      text
2    _NameLowercase            text
3    ResRef                    text
4    Tag                       text
5    Height                    integer
6    Width                     integer
7    Flags                     integer
8    _FlagInterior             integer
9    _FlagUnderground          integer
10   _FlagNatural              integer
11   NoRest                    integer
12   PlayerVsPlayer            integer
13   Tileset                   text
14   _TilesetName              text
15   OnEnter                   text
16   OnExit                    text
17   OnHeartbeat               text
18   OnUserDefined             text
19   LoadScreenID              integer
20   IsNight                   integer
21   DayNightCycle             integer
22   ChanceLightning           integer
23   ChanceRain                integer
24   ChanceSnow                integer
25   WindPower                 integer
26   FogClipDist               real
27   ModListenCheck            integer
28   ModSpotCheck              integer
29   Comments                  text
30   AmbientSndDay             integer
31   AmbientSndDayVol          integer
32   AmbientSndNight           integer
33   AmbientSndNitVol          integer
34   EnvAudio                  integer
35   MusicBattle               integer
36   MusicDay                  integer
37   MusicDelay                integer
38   MusicNight                integer
39   _AmbientSndDayResource    text
40   _AmbientSndNightResource  text
41   _MusicBattleResource      text
42   _MusicDayResource         text
43   _MusicDelayResource       text
44   _MusicNightResource       text
```

### creatures
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    FirstName                 text
2    LastName                  text
3    _Name                     text
4    _NameLowercase            text
5    TemplateResRef            text
6    Tag                       text
7    PaletteID                 integer
8    _Palette                  text
9    _PaletteFull              text
10   Appearance_Type           integer
11   _Appearance_TypeName      text
12   ChallengeRating           integer
13   CRAdjust                  integer
14   MaxHitPoints              integer
15   _Level                    integer
16   _Class1                   integer
17   _Class1Name               text
18   _Class1Level              integer
19   _Class2                   integer
20   _Class2Name               text
21   _Class2Level              integer
22   _Class3                   integer
23   _Class3Name               text
24   _Class3Level              integer
25   FactionID                 integer
26   _ParentFactionID          integer
27   _FactionName              text
28   _ParentFactionName        text
29   Race                      integer
30   _RaceName                 text
31   Gender                    integer
32   _GenderName               text
33   LawfulChaotic             integer
34   GoodEvil                  integer
35   _Alignment                text
36   NaturalAC                 integer
37   Str                       integer
38   Dex                       integer
39   Con                       integer
40   Int                       integer
41   Wis                       integer
42   Cha                       integer
43   Lootable                  integer
44   Disarmable                integer
45   IsImmortal                integer
46   NoPermDeath               integer
47   Plot                      integer
48   Interruptable             integer
49   PerceptionRange           integer
50   WalkRate                  integer
51   Conversation              text
52   Comment                   text
53   ScriptAttacked            text
54   ScriptDamaged             text
55   ScriptDeath               text
56   ScriptDialogue            text
57   ScriptDisturbed           text
58   ScriptEndRound            text
59   ScriptHeartbeat           text
60   ScriptOnBlocked           text
61   ScriptOnNotice            text
62   ScriptRested              text
63   ScriptSpawn               text
64   ScriptSpellAt             text
65   ScriptUserDefined         text
```

### items
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    LocalizedName             text
2    _NameLowercase            text
3    TemplateResRef            text
4    Tag                       text
5    BaseItem                  integer
6    _BaseItemName             text
7    PaletteID                 integer
8    _Palette                  text
9    _PaletteFull              text
10   Identified                integer
11   StackSize                 integer
12   _StackingBaseitems2da     integer
13   Charges                   integer
14   Cost                      integer
15   AddCost                   integer
16   Cursed                    integer
17   Plot                      integer
18   Stolen                    integer
19   Comment                   text
```

### placeables
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    LocName                   text
2    _NameLowercase            text
3    TemplateResRef            text
4    Tag                       text
5    PaletteID                 integer
6    _Palette                  text
7    _PaletteFull              text
8    Faction                   integer
9    _ParentFactionID          integer
10   _FactionName              text
11   _ParentFactionName        text
12   Static                    integer
13   Plot                      integer
14   Useable                   integer
15   HasInventory              integer
16   HP                        integer
17   Hardness                  integer
18   Fort                      integer
19   Will                      integer
20   Locked                    integer
21   Lockable                  integer
22   KeyRequired               integer
23   KeyName                   text
24   OpenLockDC                integer
25   CloseLockDC               integer
26   DisarmDC                  integer
27   Interruptable             integer
28   TrapDetectable            integer
29   TrapDetectDC              integer
30   TrapDisarmable            integer
31   TrapFlag                  integer
32   TrapOneShot               integer
33   TrapType                  integer
34   Conversation              text
35   Comment                   text
36   OnClosed                  text
37   OnDamaged                 text
38   OnDeath                   text
39   OnDisarm                  text
40   OnHeartbeat               text
41   OnInvDisturbed            text
42   OnLock                    text
43   OnMeleeAttacked           text
44   OnOpen                    text
45   OnSpellCastAt             text
46   OnTrapTriggered           text
47   OnUnlock                  text
48   OnUsed                    text
49   OnUserDefined             text
```

### appearance2da
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    LABEL                     text
2    _STRING_REF               text
```

### placeables2da
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    Label                     text
2    ModelName                 text
3    _StrRef                   text
```

### ambientmusic2da
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    Resource                  text
2    _Description              text
```

### ambientsound2da
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    Resource                  text
2    _Description              text
```

### tilesets
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    Resref                    text
2    Name                      text
```

### area_encounters
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    area_id                   integer
2    Difficulty                integer
3    DifficultyIndex           integer
4    Faction                   integer
5    LocalizedName             text
6    MaxCreatures              integer
7    OnEntered                 text
8    OnExhausted               text
9    OnExit                    text
10   OnHeartbeat               text
11   OnUserDefined             text
12   PlayerOnly                integer
13   RecCreatures              integer
14   Reset                     integer
15   ResetTime                 integer
16   Respawns                  integer
17   SpawnOption               integer
18   Tag                       text
19   TemplateResRef            text
20   XPosition                 real
21   YPosition                 real
22   ZPosition                 real
```

### area_encounters_creatures
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    area_encounter_id         integer
2    ResRef                    text
3    SingleSpawn               text
```

### ute_encounters
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    Active                    integer
2    Comment                   text
3    Difficulty                integer
4    DifficultyIndex           integer
5    Faction                   integer
6    LocalizedName             text
7    MaxCreatures              integer
8    OnEntered                 text
9    OnExhausted               text
10   OnExit                    text
11   OnHeartbeat               text
12   OnUserDefined             text
13   PaletteID                 integer
14   PlayerOnly                integer
15   RecCreatures              integer
16   Reset                     integer
17   ResetTime                 integer
18   Respawns                  integer
19   SpawnOption               integer
20   Tag                       text
21   TemplateResRef            text
```

### ute_encounters_creatures
```
cid  name                      type
---  ------------------------  -------
0    id                        integer
1    ute_encounter_id          integer
2    ResRef                    text
3    SingleSpawn               text
```
