# Gen 4 RNG Principles

Generation 4 RNG can be understood like this:

```text
System time + Delay creates the initial seed
The fixed random sequence after that seed decides the result
Player actions, NPCs, phone calls, and Chatot cries advance that sequence
```

The practical goal is:

1. Hit the correct `seed`.
2. Advance to the correct `frame / advance`.
3. Trigger generation at the correct position.

## Core Terms

| Term | Simple meaning | Practical meaning |
| --- | --- | --- |
| `seed` | Starting point of the random sequence | The same seed gives the same later sequence |
| `Delay` | Hardware timing offset before the game reads the seed | Key value for hitting the target seed |
| `second` | The second used when the seed is generated | The DS clock can only be set to the minute, so the player waits for the second |
| `frame / advance` | How many times the RNG has been consumed | Decides which later result is used |
| `PID` | Hidden personality value | Decides nature, gender, ability slot, shiny status, and more |
| `IV` | Individual values | Usually generated from RNG results after the PID |
| `TID/SID` | Visible and secret Trainer IDs | Used with PID to determine shiny status |

## How Time Creates the Seed

The Gen 4 initial seed is created from DS system time and Delay.

A simplified version is:

```text
AB = month * day + minute + second
CD = hour

seed = (AB << 24) | (CD << 16)
seed = seed + Delay + year adjustment
```

In plain terms:

```text
year/month/day/hour/minute/second  decide the high part of the seed
Delay                              decides the low part of the seed
year                               adjusts the displayed Delay
```

This is why the same seed can have many possible dates and times: different dates, minutes, and seconds can produce the same high-byte combination.

> For the player, the important question is not the date itself. The important question is whether that date, time, and Delay produce the target seed.

## What Delay Means

`Delay` can be understood as:

```text
the hardware timing offset between starting the game
and the moment the game reads the initial seed.
```

In normal retail practice, it can be understood approximately as:

```text
the startup offset produced by the time between
pressing A on the DS system menu to start the game
and pressing A on the save-select screen to enter the save.
```

It is not a normal in-game frame, and it is not a number of seconds to wait.

For example:

```text
Seed: 00130AE9
Delay: 2782
Second: 57
```

means:

```text
At second 57 of the target time,
enter the game with startup offset Delay 2782,
so the game receives seed 00130AE9.
```

The timer exists to help the player do this consistently.

## Why Calibration Is Needed

The player will not hit the exact target Delay on the first try every time.

The usual process is:

```text
Choose target seed / Delay / second
Use the timer to enter the game
Verify the hit with phone calls, coin flips, or the actual result
Reverse-search the actual Delay
Apply calibration
Try again
```

For example:

```text
Target Delay: 2782
Actual hit:   2772
```

The app uses that difference to update the calibrated Delay, making the next timer attempt closer to your actual input timing.

## Year and Delay Parity

The Gen 4 seed formula includes a year adjustment:

```text
Delay + year - 2000
```

Because of this, the year affects Delay parity.

If you see:

```text
target Delay is even
but actual hits are always odd
```

or the opposite, you usually do not need to change any app filters. Change the DS system year by +1 or -1 to switch parity.

## What Happens After the Seed

After the game receives the initial seed, it repeatedly generates the next random value with a fixed formula:

```text
seed = seed * 0x41C64E6D + 0x6073
```

Each generated random value is one RNG advance.

Therefore:

```text
same seed + same number of advances = same result
```

Encounter slot, level, PID, nature, gender, ability slot, IVs, held item, and some forms are all read from later random values.

## Phone Calls, Coin Flips, and Chatot

### HGSS Phone Calls

HGSS phone calls can verify the seed and also advance the RNG.

Each call to Professor Elm or Irwin produces one of `E/K/P`. The app can use the observed sequence to reverse-search:

```text
Which seed produces this E/K/P sequence?
Which frame was the game on before the sequence started?
```

### DPPt Coin Flips

DPPt coin flips observe the sequence after the seed. They are mainly used to verify the seed.

### Chatot

Chatot is mainly used to advance frames.

Each recorded cry:

```text
consumes the RNG once
moves the player forward by 1 frame
uses that random value to decide pitch
```

## Method 1 / J / K

Not every Gen 4 target reads random values in the same way.

| Method | Common use | Notes |
| --- | --- | --- |
| Method 1 | Starters, gifts, some special generation | Relatively direct reading order |
| Method J | DP/Pt stationary and wild targets | Handles Synchronize, nature selection, encounter slots, and more |
| Method K | HGSS stationary and wild targets | HGSS counterpart to Method J |

They share the same initial seed and LCRNG, but they read random values in different orders.

That means the same seed and same frame can produce completely different results under different methods.

## Why Wild Encounters Are More Complex

Wild encounters do more than generate PID and IVs. They often calculate:

- Whether an encounter occurs
- Encounter slot
- Level
- Species
- Nature and PID
- IVs
- Held item
- Some special forms

Lead abilities also affect the process:

| Lead ability | Possible effect |
| --- | --- |
| Synchronize | Nature / PID generation |
| Cute Charm | PID pool and gender result |
| Static / Magnet Pull | Certain type-based species |
| Pressure | Level |
| Compound Eyes | Held item |

The lead setting in the app must match the actual game state.

## ID RNG

ID RNG is also based on a time seed, but TID/SID are not produced directly by the normal LCRNG. The game starts MT from the seed.

Simplified:

```text
time + Delay -> seed
seed -> MT -> TID/SID
```

TID/SID matter because shiny status uses:

```text
TID ^ SID ^ upper PID ^ lower PID
```

If you can control TID/SID, you can make certain excellent PIDs shiny.

## Why Egg RNG Has Two Stages

Gen 4 egg RNG has two stages:

```text
egg generation
egg pickup
```

Egg generation decides:

- PID
- Nature
- Gender
- Ability slot
- Shiny status

Egg pickup decides:

- IVs
- Parent inheritance

So if an egg has been generated but not picked up yet, you can reset and RNG the pickup stage for IVs.

## Common Mistakes

### 1. Treating Delay as frame

`Delay` is a startup timing offset.
`frame / advance` is how many times the RNG has been consumed after the seed.

They are not the same thing.

### 2. Correct seed, wrong frame

Common causes:

- NPC turns or movement
- Roamer initial advances
- Phone calls not matching app taps
- Miscounted Chatot cries
- Misunderstood encounter trigger timing

### 3. Search settings do not match the real game

Examples:

- The app has no Synchronize selected, but the lead has Synchronize
- Wrong time of day
- Wrong inserted cartridge state
- Wrong location or encounter method
- Wrong level range or encounter slot assumption

## One-Sentence Summary

```text
Gen 4 RNG is not gambling on randomness.
It is hitting a seed with DS time and Delay,
then using controlled actions to advance RNG to the target position.
```
