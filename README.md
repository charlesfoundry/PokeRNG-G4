# PokeRNG G4

PokeRNG G4 is a Flutter/Dart tool for Generation 4 Pokemon RNG workflows,
focused on Pokemon Diamond, Pearl, Platinum, HeartGold, and SoulSilver.

The app is designed for practical retail-hardware use on phones and desktop:
search a target, send it to calibration, time the attempt, verify the seed, and
calibrate from the Pokemon or ID result you actually hit.

## Features

- Wild encounter search for Diamond, Pearl, Platinum, HeartGold, and SoulSilver
- Static, gift, starter, legendary, honey tree, and Sweet Scent workflows
- Seed-to-time search, delay support, and multi-stage timer based on EonTimer
  concepts
- HGSS phone sequence and DPPt coin flip seed verification
- Chatot pitch preview and advance tracking for HGSS/DPPt frame adjustment
- Reverse search from observed species, level, nature, stats, ability, gender,
  and characteristic
- Saved targets per game version
- HGSS egg PID generation and egg pickup IV search
- DPPt egg workflow kept separate from HGSS behavior
- Gen 4 ID RNG search, ID calibration, SID range search, and excellent SID
  target finder
- Localized UI in English, Japanese, and Simplified Chinese
- Localized Gen 4 species, ability, nature, characteristic, and location names
- Per-game local persistence for game version, TID, SID, calibration delay,
  egg parents, egg settings, saved targets, and ID RNG settings

Primary platform targets are iOS, iPadOS, and macOS. Android is also kept
buildable when possible.

## Verified Workflows

The current implementation has been used successfully on retail-style Gen 4
workflows including:

- HGSS stationary shiny RNG
- Platinum starter shiny RNG
- Platinum honey tree shiny RNG
- HGSS egg PID generation and egg pickup IV RNG
- Gen 4 ID RNG

Other workflows share the same underlying RNG primitives, but should still be
checked against known tools and real hardware before relying on them for rare
targets.

## What This Project Does Not Include

This repository does not include ROMs, save files, official sprites, official
artwork, or other game assets. The app uses original UI assets and structured
RNG/encounter data needed for calculation.

## Basic Concepts

- `TID` / `SID`: Trainer ID and Secret ID. Together with the PID, they determine
  shiny results.
- `TSV`: Trainer shiny value, derived from TID and SID. It is useful when
  grouping PID targets that can be made shiny by the same trainer ID pair.
- `Seed`: The starting RNG state for a Gen 4 attempt. In Gen 4, the initial
  seed is derived from date, time, delay, and second.
- `Delay`: A timing-dependent value affected by hardware, game version, slot
  behavior, and player input timing. Calibration is used to make future attempts
  more consistent.
- `Second`: The in-game seed second. If you hit the correct delay but the wrong
  second, the timer calibration second may need adjustment.
- `Frame` / `Advance`: One RNG step in the generated sequence.
- `PID`: Personality value. It determines nature, ability slot, gender, shiny
  status, characteristic group, and other properties together with the target
  context.
- `IV`: Individual values, from 0 to 31.
- `Slot`: The encounter table slot. Different slots map to different species
  and levels for each location, time period, encounter type, and special
  condition.
- `Lead ability`: Abilities such as Synchronize can change the PID generated on
  a frame. Search settings should match the actual lead Pokemon.
- `Chatot pitch`: In Gen 4, playing a recorded Chatter cry advances RNG and
  gives an audible pitch that can be used to confirm frame advancement.

## General Search Flow

1. Open `Settings`.
2. Select the game version.
3. Enter the TID and SID for that game version.
4. Open the search page.
5. Select the Pokemon, encounter location, time period, cartridge condition,
   lead ability, and filters.
6. Search and inspect the result cards.
7. Tap a result to send it to calibration or save it for later.

The result card shows the target seed, delay, frame, encounter details, nature,
gender, ability, Hidden Power, IVs, PID, and calculated stats.

## Calibration and Timer

The calibration page is the center of practical Gen 4 attempts.

1. Send a result from search, saved targets, egg search, or ID search.
2. Use seed-to-time to choose a concrete date and time for the target seed.
3. Start the multi-stage timer.
4. Use the timer cues to set the DS time, start the game, and enter the save.
5. Verify the seed with HGSS phone calls or DPPt coin flips when the workflow
   allows it.
6. If the seed missed, tap the seed you actually hit and apply calibration.
7. If the seed hit, use the app's frame guidance, Chatot pitch list, or reverse
   search tools to finish the attempt.

Each timer stage ends with a four-beep cue. The intended input moment is the
start of the fourth beep, not after hearing the fourth beep finish.

## Stationary, Starter, Honey Tree, and Wild RNG

Stationary and starter workflows use the same core Method 1 RNG as many other
Gen 4 targets, but the practical setup differs by game and map.

- HGSS stationary targets can usually verify seed with phone calls, then use
  Chatot to advance to the target frame.
- Platinum starter RNG has heavy NPC pressure on Route 201, so the app includes
  a broad reverse-search workflow intended for low-level starter stats.
- Honey tree species are determined when honey is applied. Once the tree has a
  known species waiting, the later encounter search focuses on IVs, nature, PID,
  shiny status, and frame.
- Sweet Scent wild RNG depends on the selected encounter table, time period,
  cartridge condition, and lead ability. Make sure these inputs match the real
  game state.

## Egg RNG

Egg RNG is handled on its own page because egg PID generation and egg pickup IV
generation are separate workflows.

HGSS egg support includes:

- parent IV settings
- target TID/SID override for shiny egg planning
- egg PID generation search
- phone-based seed verification
- egg pickup IV search
- reverse search from the hatched Pokemon's level 1 stats and characteristic

DPPt egg behavior is intentionally separated from HGSS behavior because the
inheritance mechanics differ.

## ID RNG

The ID RNG page is for finding and timing trainer ID results.

It supports:

- TID/SID target search
- seed/time/delay results for ID attempts
- ID calibration from the TID actually hit
- SID range targets
- excellent SID search for groups of high-quality shiny PID targets

ID RNG uses a separate calibration delay from normal encounter RNG, because the
name-entry flow and startup path can produce a different practical timing
offset.

## Tools

The tools page includes:

- saved target list
- target send-to-calibration flow
- in-app RNG guides

Saved targets are stored separately per game version.

## Development

Install Flutter, then fetch dependencies:

```sh
flutter pub get
```

Run the app on macOS:

```sh
flutter run -d macos
```

Run static analysis:

```sh
flutter analyze
```

Generate localization code after editing ARB files:

```sh
flutter gen-l10n
```

Build an Android release APK for arm64 devices:

```sh
flutter build apk --release --target-platform android-arm64
```

## License

This project is licensed under GPL-3.0-only.

See [LICENSE](LICENSE) for the full license text.

## Privacy

See [PRIVACY.md](PRIVACY.md).

## Credits

- Admiral-Fish and the PokeFinder contributors for
  [PokeFinder](https://github.com/Admiral-Fish/PokeFinder)
- DasAmpharos and the EonTimer contributors for
  [EonTimer](https://github.com/DasAmpharos/EonTimer)
- The PokemonRNG and Retail RNG communities for Gen 4 RNG guides and research
