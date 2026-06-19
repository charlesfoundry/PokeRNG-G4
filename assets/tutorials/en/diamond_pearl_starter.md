# DP Starter Shiny

## Core Idea

DP starter RNG has no stable coin flip or Chatot confirmation step.

You confirm what happened after the rival battle by reading the starter stats, then use reverse search on the calibration page to infer:

- seed
- delay
- frame

## Scene Notes

In DP, the starter is chosen at **Lake Verity**.

Save on **Route 201**, one step before the automatic story event is triggered.

During the RNG attempt, after entering the save, immediately hold Up and trigger the story event as fast as possible.

During the Lake Verity opening scene, several NPCs visibly move. These movements are part of a fixed scripted route, not ordinary random NPC movement that advances RNG.

Therefore, if you trigger the event immediately after loading the save, the target should be treated as the **frame 0** starter.

## Steps

1. On Route 201, stand one step before the automatic story event trigger.
2. Face the trigger direction.
3. Save the game.
4. Follow the timer to set the DS clock, start the game, and enter the save.
5. After choosing the save, immediately hold Up.
6. Trigger the Lake Verity event as fast as possible and choose the starter.

When searching for the target, use a fixed frame range:

- minimum frame: 0
- maximum frame: 0

## Reverse Search

After the rival battle, check the starter stats.

Enter these into the starter reverse search on the calibration page:

- Pokemon
- level
- nature
- stats
- characteristic
- gender, if needed to narrow the result

Recommended initial range:

- frame range: 0 to 0
- delay range: +/-300

If you held Up immediately after loading and triggered the event quickly, search as frame 0.

## Calibration

1. Tap the reverse search result.
2. The app fills the actual hit delay.
3. Confirm the result.
4. Tap Apply Calibration.
5. The timer is refreshed.
6. Repeat hit, check stats, reverse search, and apply calibration.

## Troubleshooting

If frame 0 reverse search finds no result, first check:

- Pokemon, level, nature, stats, and characteristic were entered correctly.
- Up was held immediately after entering the save.
- The save position was exactly one step before the story trigger.

If the inputs are correct but no result is found, you can temporarily expand the frame range for diagnosis. For normal target searches, prioritize frame 0.
