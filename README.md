# Mik's Scrolling Battle Text (MSBT)

For World of Warcraft 3.3.5a (Wrath of the Lich King). Version 6.0.0, based on version 5.4.78 by Mikord, with a loot count fix and the settings window built in.

> **I am not the original author of the addon.** There was an issue with the original addon displaying the incorrect amount of items looted versus what was actually in your bags.
>
> **Fix:** in `MSBTLoot.lua`, MSBT now waits 0.3 seconds for the bags to update, then shows the real bag count. It's correct whichever comes first, the bag update or the message. The popup appears a fraction of a second later, which should be hard to notice.

Original author: **Mikord** (http://mikord.wowinterface.com).

---

## What it does

MSBT scrolls combat information around your character, in separate scroll areas you can place and style. It replaces Blizzard's floating combat text.

- Incoming and outgoing damage and heals, each in its own scroll area
- Notifications: buffs and debuffs, combat enter / leave, power gains, combo points, honor, reputation, skill and experience gains, killing blows, cooldowns ready
- Loot: looted items with the total now in your bags, and money
- Triggers: alerts such as low health, low mana, procs (Hot Streak, Art of War, Sudden Death, Maelstrom Weapon…)
- Sounds for events and triggers
- Fonts, sizes, outlines, colours, opacity and animation styles for every scroll area and event
- Merging of area damage into one line, overheal amounts, class-coloured names, damage colours by school
- Spam filters

---

## Installation

1. Close the game.
2. Extract the zip into `<WoW folder>\Interface\AddOns\`.
3. Keep the folder name `MikScrollingBattleText`: the addon finds its fonts, sounds and settings window through it.
4. Start the game (restart it completely if it was running: new files are not loaded by `/reload`).

The settings window is included in this folder (`Options`), so the separate `MSBTOptions` folder is no longer needed. If you update from another version, delete the old `MikScrollingBattleText` and `MSBTOptions` folders first.

---

## Commands

| Command | |
| --- | --- |
| `/msbt` | Open the settings window |
| `/msbt reset` | Reset the current profile to the default settings |
| `/msbt disable` | Turn the addon off |
| `/msbt enable` | Turn the addon on |
| `/msbt version` | Show the version |
| `/msbt help` | List the commands |

---

## Custom triggers

Triggers show your own alerts for game events MSBT does not already show (procs, crowd control breaking, key enemy abilities…). Open them with `/msbt` → **Triggers**. Several common triggers are included by default.

### Basic concepts

Almost everything that happens in the game creates a combat log entry, and each entry has an event type. These event types drive triggers.

- **Main event**: the type of event, for example "Skill Damage" when a Fireball hits you.
- **Conditions**: the details of that event: who cast it, who it hit, the amount, whether it crit, whether the caster is a player or an NPC…
- **Exceptions**: other "state" information, not tied to the event: the zone you are in, whether a buff is active, whether a skill is available… An exception that applies stops the trigger.

### How a trigger fires

1. One of the trigger's main events happens.
2. The conditions of that main event are tested. If any of them is false, the trigger stops.
3. The exceptions are tested. If any of them applies, the trigger stops.
4. The trigger fires and shows its output message with its event settings.

- Main events are **OR**: any one of them starts the test.
- The conditions of one main event are **AND**: all of them must be true.
- Exceptions are **OR**: any one of them stops the trigger.

### Advanced use

- The same main event can be added several times to one trigger, each time with different conditions. Example: two "Aura Application" events, one with Skill Name = Mace Stun Effect and one with Skill Name = Improved Hamstring, fire the same trigger for either proc. `%s` in the message shows which skill it was, and the trigger picks the right icon.
- The same condition can be used several times in one main event, for ranges: "Amount - Is Greater Than - X" and "Amount - Is Less Than - Y".
- Skill IDs (from any online database) let a trigger fire only for a specific rank of a skill.

### Examples

**Polymorph broke** (crowd control break in the arena)

| | |
| --- | --- |
| Output message | `Poly Broke - %r!` |
| Main event | Aura Removal |
| Conditions | Skill Name - Is Equal To - Polymorph<br>Recipient Unit Affiliation - Is Equal To - Focus<br>Recipient Unit Reaction - Is Equal To - Hostile |
| Exceptions | Zone Type - Is Not Equal To - Arena |

**Mace Stun** (proc on your target)

| | |
| --- | --- |
| Output message | `Mace Stun!` |
| Main event | Aura Application |
| Conditions | Skill Name - Is Equal To - Mace Stun Effect<br>Recipient Unit Affiliation - Is Equal To - Target<br>Recipient Unit Reaction - Is Equal To - Hostile |
| Exceptions | None |

**Focus** (proc on you, from Mystical Skyfire Diamond)

| | |
| --- | --- |
| Output message | `Focus!` |
| Main event | Aura Application |
| Conditions | Skill Name - Is Equal To - Focus<br>Recipient Unit Affiliation - Is Equal To - You |
| Exceptions | None |

**Hand of Protection used** (key enemy ability in the arena)

| | |
| --- | --- |
| Output message | `Melee Bubble!` |
| Main event | Cast Success |
| Conditions | Skill Name - Is Equal To - Hand of Protection<br>Source Unit Reaction - Is Equal To - Hostile |
| Exceptions | Zone Type - Is Not Equal To - Arena |

**Priest Fear used**

| | |
| --- | --- |
| Output message | `Priest Fear Down!` |
| Main event | Cast Success |
| Conditions | Skill Name - Is Equal To - Psychic Scream<br>Source Unit Reaction - Is Equal To - Hostile |
| Exceptions | Zone Type - Is Not Equal To - Arena |

### Trigger fields

- **Output message**: the text shown when the trigger fires. Codes: `%n` source name, `%r` recipient name, `%a` amount, `%s` skill name, `%e` the second skill name (for events with two skills, like dispels).
- **Trigger classes**: the classes the trigger applies to. This is **your** class, not the target's: the default Execute trigger only works when you play a warrior.
- **Main events**: the events that start the test (see the table below).
- **Exceptions**: what stops the trigger; only checked when a main event happened and all its conditions are true.

### Main events

| Main event | Fired when |
| --- | --- |
| Aura Application | an aura is applied to a unit |
| Aura Broken | an aura is broken by a skill |
| Aura Dispel | an aura is dispelled from a unit |
| Aura Removal | an aura is removed from a unit |
| Aura Refresh | an aura is refreshed on a unit |
| Aura Stolen | an aura is stolen from a unit |
| Cast Failure | a cast fails |
| Cast Start | a cast begins |
| Cast Success | a cast completes |
| Create | items are created (usually conjured items) |
| Damage Shield Damage | damage is done by a damage shield like Thorns |
| Damage Shield Miss | damage from a damage shield is resisted, absorbed… |
| Dispel Failed | a dispel attempt fails |
| Enchant Application | an enchant is applied to an item |
| Energy Change | the energy of a supported unit changes |
| Environmental Damage | damage from falling, drowning… |
| Extra Attacks | extra attacks happen (Windfury…) |
| Heal | a unit is healed |
| Health Change | the health of a supported unit changes |
| Killing Blow | a unit gets a killing blow |
| Mana Change | the mana of a supported unit changes |
| Periodic Skill Damage (DoT) | damage from a periodic source is done |
| Periodic Skill Miss | damage from a periodic source is resisted, absorbed… |
| Periodic Heal (HoT) | a unit is healed by a periodic source |
| Periodic Power Drain / Gain / Leech | power is drained, gained or leeched by a periodic source |
| Power Drain / Gain / Leech | power is drained from, gained by or leeched from a unit |
| Rage Change | the rage of a supported unit changes |
| Range Damage | damage from a ranged source (wands, bows) is done |
| Range Miss | ranged damage is dodged, absorbed… |
| Skill Cooldown Complete | a skill's cooldown completes |
| Skill Damage | damage from a skill is done to a unit |
| Skill Interrupt | a skill is interrupted (not pushed back) |
| Skill Miss | damage from a skill is resisted, absorbed… |
| Split Damage | damage is split between the source and the recipient |
| Swing Damage | damage from melee swings is done to a unit |
| Swing/Range/Skill Damage | any non-periodic damage is done to a unit |
| Swing Miss | melee damage is dodged, absorbed… |
| Swing/Range/Skill Miss | any non-periodic damage is dodged, resisted, absorbed… |
| Summon | a creature is summoned |
| Unit Death | a unit dies |
| Unit Destroy | a mechanical unit is destroyed |

### Main event conditions

| Condition | |
| --- | --- |
| Absorb Amount | the amount of damage absorbed |
| Amount | the amount of damage, health, power… of the event |
| Aura Type | buff or debuff |
| Block Amount | the amount of damage blocked |
| Crit | whether the event is a critical |
| Crushing Blow | whether the hit was a crushing blow |
| Damage Type | the damage school (arcane, fire, holy…) |
| Extra Amount | the second amount, for events with two amounts |
| Extra Skill ID / Name / School | the second skill of the event |
| Glancing Hit | whether the hit was a glancing hit |
| Hazard Type | falling, drowning… (environmental damage) |
| Miss Type | block, dodge, parry, resist… |
| Power Type | energy, mana, rage… |
| Recipient Unit Affiliation | mine, target, focus, you, party member… |
| Recipient Unit Control | server or human |
| Recipient Unit Name | the recipient's name |
| Recipient Unit Reaction | hostile, friendly, neutral |
| Recipient Unit Type | player, pet, NPC… |
| Resist Amount | the amount of damage resisted |
| Skill ID / Name / School | the skill of the event |
| Source Unit Affiliation / Control / Name / Reaction / Type | the same, for the source of the event |
| Threshold | a percentage that must be crossed (energy, health, mana changes) |
| Unit ID | the unit to test for energy, health, mana changes |
| Unit Reaction | the reaction of the unit whose energy, health, mana changed |

### Trigger exceptions

| Exception | |
| --- | --- |
| Active Talents | the specified talent group is active |
| Buff Active | the specified buff is active on you |
| Current Combo Points | your current combo points |
| Current Power | your current power |
| Trigger Recently Fired | seconds since the trigger last fired |
| Trivial Target | your target is trivial (grey) |
| Unavailable Skill | the skill is unknown or on cooldown (reagents, range… are not checked) |
| Warrior Stance | your current stance (warriors only) |
| Zone Name | the zone you are in |
| Zone Type | the type of zone you are in |

### Search patterns

Fields that compare text with **Is Like** / **Is Not Like** use Lua search patterns: `.` any character, `%d` a digit, `%a` a letter, `%s` a space, `*` / `+` / `-` repeat, `^` / `$` start / end of the text, `%` before a magic character to match it literally (for example `%.`). The full reference is in the Lua 5.1 manual, section "Patterns".

---

## The loot count fix

Before the fix, the loot popup added the amount you looted to the number already in your bags. On some servers the item is already in the bags when the "You receive loot" message arrives, so the total was one too high (for example "+1 Frostweave Cloth (21)" with 20 in the bags).

Now the popup waits 0.3 seconds, reads the real count in your bags and shows that number (never less than the amount just looted). Only `MSBTLoot.lua` was changed.

---

## For addon authors

`API.html` describes `MikSBT.DisplayMessage`, `MikSBT.RegisterFont`, custom animation styles and the other functions other addons can use.
