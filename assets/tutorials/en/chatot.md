# Pt/HGSS Chatot and Target Frames

## Core Rule

Each custom Chatot cry consumes one RNG call.

That call determines the pitch for the next frame.

After you hear one custom cry, the current frame has already advanced by **1 frame**.

## Difference From Pokemon Generation

Pokemon generation works differently from Chatot pitch preview.

When an encounter or A-press starts generation, the game reads the **current frame**, not the next frame.

The goal is:

1. Use Chatter to advance directly onto the target frame.
2. Then trigger the encounter or press A to generate the Pokemon.

## In Practice

The app shows the upcoming pitches.

After hearing the required number of cries, follow the app prompt and return to the map or target screen to perform the target action.
