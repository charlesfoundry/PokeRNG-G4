# Pt Starter Shiny

## Core Idea

Pt starter RNG has no stable coin flip or Chatot confirmation step.

You confirm what happened after the rival battle by reading the starter stats, then use reverse search on the calibration page to infer:

- seed
- delay
- frame

## Scene Notes

In Pt, the starter is given directly on Route 201.

- Professor Rowan and the assistant are stationary.
- The rival turns often.
- Two off-screen NPCs may move or turn frequently.

These NPCs can advance frames, so the goal is: **open the briefcase as fast as possible after loading the save**, before NPCs can move, turn, and advance frames.

## Steps

1. Move in front of the briefcase.
2. Save the game.
3. Follow the timer to set the DS clock, start the game, and enter the save.
4. After loading, immediately mash A.
5. Open the briefcase as fast as possible.

With this operation, the result is usually the **frame 1** starter, because opening the briefcase itself consumes 1 frame.

## Reverse Search

After the rival battle, check the starter stats.

Enter these into the starter reverse search on the calibration page:

- Pokemon
- level
- nature
- stats
- characteristic

Recommended initial range:

- frame range: 1 to 5
- delay range: +/-300

If you mashed A immediately after loading, NPCs usually should not reach a higher frame.

## Calibration

1. Tap the reverse search result.
2. The app fills the actual hit delay.
3. Confirm the result.
4. Tap Apply Calibration.
5. The timer is refreshed.
6. Repeat hit, check stats, reverse search, and apply calibration.

## Troubleshooting

If the reverse search result is not frame 1, it usually means:

- A was not pressed fast enough after loading.
- Or an NPC advanced frames first.
