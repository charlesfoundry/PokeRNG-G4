# Lead Abilities

## Match the Real Game

When searching wild Pokemon, the app lead setting must match the Pokemon at the front of the party.

This is especially important for Synchronize, Cute Charm, Static, Magnet Pull, and similar lead abilities.

If the real game has a Synchronize lead but the app is set to no lead, the results will not line up.

## Synchronize Changes PID and IV Flow

The wild encounter flow is roughly:

1. Choose the encounter slot.
2. Calculate the level.
3. Check the lead ability.
4. Generate PID and IVs.

Synchronize usually does not change the slot that was already selected for that frame.

It can change the PID, nature, and IVs generated afterward.

Under the same seed, a high-IV PID found with no lead may move to another frame or another slot when Synchronize is enabled, or the same frame may produce a completely different PID.

## Practical Use

If the real lead has Synchronize:

1. Set the lead to Synchronize on the search page.
2. Select the real lead's nature as the Synchronize nature.
3. Use the same condition for reverse search.

If you do not want Synchronize to affect the result, move that Pokemon away from the lead position and search with no lead.
