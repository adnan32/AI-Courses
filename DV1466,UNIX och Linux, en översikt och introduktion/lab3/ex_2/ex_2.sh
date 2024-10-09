#!/bin/bash

# Poem
poem="Only a legend whispered in the air.
A flicker faints in a dying ember’s gleam, until the Warrior rises, living out a
silent dream. With a heart, bright as morning dew, A warrior sees the dark-
ness that has wrapped the land. Clear one who can stand against this tide of
night, wield your courage with all your might. Heart of an ancient time, show
us the bravery lost to ages past. Can it, by a touch of fate, bring its brilliance
back?. Enter to mend what is broken and bring back the light. The destiny of
the Vault beckons, the path is clear in sight. Of righteousness high, a beacon
burning bright, ready to fight, against the endless night. The time is now to
reclaim what was hidden. Third eon of freedom challenged by the evil spree, and
to confront it, the heart is the Key."

# Extract words starting with capital letters
echo "$poem" | grep -o '\b[A-Z][a-zA-Z]*\b'
