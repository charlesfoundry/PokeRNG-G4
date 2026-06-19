# HGSS Egg Generation

## Core Idea

Egg generation uses **Egg Frame**.

The egg generation stage decides:

- PID
- nature
- gender
- ability
- shininess

The simplest target is usually **Egg Frame 1**. If the seed is hit, enter the game and walk until the Day-Care Man generates the first egg.

## What Advances Egg Frame

Actions that advance Egg Frame:

- calling Youngster Joey
- rejecting an egg
- similar egg-generation actions

Actions that do not advance Egg Frame:

- calling Professor Elm
- calling Juggler Irwin

Elm or Irwin calls can verify the seed, but they are not automatically treated as Egg Frame advances.

## Search Stage

1. Set the Egg Frame range.
2. Choose the target PID.
3. Send it to the egg timer.
4. Start the RNG attempt.

Recommended first setup:

- minimum Egg Frame: 1
- maximum Egg Frame: 1

## Hitting the Seed

1. Enter the game with the timer.
2. Immediately open the phone.
3. Call Professor Elm or Juggler Irwin to verify whether the seed was hit.

After every call, tap the exact matching E/K/P result in the app in the same order.

After confirming the hit seed, manually tap that seed result so the app records the seed you hit.

If the seed was missed:

1. Tap the seed result you actually hit.
2. The app fills the Egg Delay actually hit in this attempt.
3. The egg timer is updated only after you tap Apply Calibration.
4. Try again.

If the hit delay differs from the target delay by only **±2**, you can avoid updating calibration yet and try a few more times with the current calibration first.

If the same offset appears consistently, then apply the calibration.

If the seed was hit:

1. Exit the phone.
2. Start walking.
3. Wait until the Day-Care Man generates the egg.

## Locking the Target Egg

After the egg is generated:

1. Save in front of the Day-Care Man.
2. Receive and hatch the egg.
3. Confirm nature, shininess, and gender.

If the egg matches the target:

1. Do not save after hatching.
2. Reset the game.
3. Return to the save in front of the Day-Care Man.

The expected state is now: the target egg has already been generated, has not been received, and the player is saved in front of the Day-Care Man. Next, RNG the pickup IVs.
