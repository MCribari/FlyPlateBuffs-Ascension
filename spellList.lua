local _, fPB = ...

local defaultSpells1 = {--Important spells, add them with huge icons.

	-- Mage
	45438, --Ice Block
	118, --Polymorph
	12826, --Polymorph
	198111, --Temporal Shield (pvp)
	12043, --Presence of Mind
	42950, --Dragon's Breath


	-- DK
	48707, --Anti-Magic Shell
	207319, --Corpse Shield
	221562, --Asphyxiate

	-- Shaman
	51514, --Hex
	210918, --Ethereal Form
	204437, --Lightning Lasso (pvp)

	-- Druid
	61336, --Survival Instincts
	29166, --Innervate
	33786, --Cyclone
	5211, --Mighty Bash / Bash
	16979, --Feral Charge - Bear
	19675, -- Feral Charge - Effect
	9005, --Pounce

	-- Paladin
	642, --Divine Shield
	86659, --Guardian of Ancient Kings
	228049, --Guardian of the Forgotten Queen
	6940, --Blessing of Sacrifice / Hand of Sacrifice
	853, --Hammer of Justice
	10278, --Hand of Protection
	1044, --Hand of Freedom

	-- Warrior
	871, --Warrior Shield Wall
	5246, --Intimidating Shout
	20511, --Intimidating Shout

	-- Rogue
	2094, --Blind
	199743, --Parley
	6770, --Sap
	51724, --Sap

	-- Hunter
	19386, --Wyvern Sting
	49012, --Wyvern Sting
	186265, --Aspect of the Turtle
	53480, --Roar of Sacrifice (pet)

	-- Monk
	115078, --Paralysis
	115176, --Zen Meditation
	122783, --Diffuse Magic
	122278, --Dampen Harm

	-- Priest
	605, --Mind Control
	8122, --Psychic Scream
	10890, --Psychic Scream
	205369, --Mind Bomb
	33206, --Pain Suppression
	64901, --Symbol of Hope
	47788, --Guardian Spirit
	47585, --Dispersion
	64044, --Psychic Horror
	64058, --Psychic Horror
	
	-- Warlock
	710, --Banish
	18647, --Banish
	5782, --Fear
	6215, --Fear
	104773, --Unending Resolve
	6789, --Death Coil
	47860, --Death Coil
	5484, --Howl of Terror
	17928, --Howl of Terror
	212295, --Nether Ward
	6358, --Seduction (Succubus)
	18708, --Fel Domination

	-- Demon Hunter
	162264, --Metamorphosis
	196555, --Netherwalk
	206804, --Rain from Above (pvp) ?
	204490, --Sigil of Silence
	205629, --Demonic Trample
	205630, --Illidan's Grasp

	-- Other CCs
	10326, --Turn Evil
	14327, --Scare Beast
	10955, --Shackle Undead

	----
	23333, -- Warsong Flag (horde WSG flag)
	23335, -- Silverwing Flag (alliance WSG flag)
	34976, -- Netherstorm Flag (EotS flag)
	121164, --Orb of Power (Kotmogu?)
	168506, --Ancient Artifact (Ashran)
	46393, --Brutal Assault
	46392, --Focused Assault
	19753, --Divine Intervention

}

local defaultSpells2 = {--semi-important spells, add them with mid size icons.

	-- Mage
	12042, --Arcane Power
	190319, --Combustion - burst
	12472, --Icy Veins
	82691, --Ring of frost
	198144, --Ice form (pvp)
	86949, --Cauterize
	44572, --Deep Freeze (mage)
	
	-- DK
	47476, --Strangulate (pvp) - silence
	48792, --Icebound Fortitude
	116888, --Shroud of Purgatory
	114556, --Purgatory (cd)
	49039, --Lichborne (DK)
	47481, --Gnaw - Ghoul
	49203, --Hungering Cold
	
	-- Shaman
	32182, --Heroism
	2825, --Bloodlust
	108271, --Astral shift
	16166, --Elemental Mastery - burst
	204288, --Earth Shield
	49284, --Earth Shield
	114050, --Ascendance

	-- Druid
	106951, --Berserk - burst
	50334, --Berserk
	102543, --Incarnation: King of the Jungle - burst
	102560, --Incarnation: Chosen of Elune - burst
	33891, --Incarnation: Tree of Life
	1850, --Dash
	22812, --Barkskin
	194223, --Celestial Alignment - burst
	78675, --Solar beam
	77761, --Stampeding Roar
	102793, --Ursol's Vortex
	102342, --Ironbark
	339, --Entangling Roots
	102359, --Mass Entanglement
	22570, --Maim
	2637, --Hibernate
	18658, --Hibernate
	16689, --Nature's Grasp (Druid)
	
	-- Paladin
	1022, --Hand of Protection
	204018, --Blessing of Spellwarding
	1044, --Blessing of Freedom
	31884, --Avenging Wrath
	224668, --Crusade
	216331, --Avenging Crusader
	20066, --Repentance
	184662, --Shield of Vengeance
	498, --Divine Protection
	53563, --Beacon of Light
	156910, --Beacon of Faith
	115750, --Blinding Light
	31821, --Aura Mastery
	54428, --Divine Plea
	64205, --Divine Sacrifice
	53601, --Sacred Shield
	
	-- Warrior
	1719, --Battle Cry / Recklessness
	23920, --Spell Reflection
	46968, --Shockwave
	18499, --Berserker Rage
	11578, --Charge
	7922, --Charge Stun
	20252, --Intercept
	20253, --Intercept
	107574, --Avatar
	213915, --Mass Spell Reflection
	118038, --Die by the Sword
	46924, --Bladestorm
	12292, --Bloodbath / Death Wish
	199261, --Death Wish
	107570, --Storm Bolt
	12809, --Concussion Blow
	2812, --Holy Wrath
	2565, --Shield Block
	12328, --Sweeping Strikes
	20230, --Retaliation
	56638, --Taste for Blood
	12798, --Revenge Stun

	-- Rogue
	45182, --Cheating Death
	31230, --Cheat Death (cd)
	31224, --Cloak of Shadows
	2983, --Sprint
	121471, --Shadow Blades
	1966, --Feint
	5277, --Evasion
	26669, --Evasion
	212182, --Smoke Bomb
	13750, --Adrenaline Rush
	199754, --Riposte
	198529, --Plunder Armor
	199804, --Between the Eyes
	1833, --Cheap Shot
	1776, --Gouge
	408, --Kidney Shot
	51713, --Shadow Dance
	1330, --Garrote - Silence

	-- Hunter
	117526, --Binding Shot
	209790, --Freezing Arrow
	60210, --Freezing Arrow Effect
	14309, --Freezing Trap Effect
	213691, --Scatter Shot
	19503, --Scatter Shot (hunter)
	3355, --Freezing Trap
	1499, --Freezing Trap
	14309, --Freezing Trap Effect
	162480, -- Steel Trap
	37587, --Bestial Wrath
	19574, --Bestial Wrath
	193526, --Trueshot
	19577, --Intimidation
	24394, --Intimidation
	90355, --Ancient Hysteria
	160452, --Netherwinds
	34490, --Silencing Shot (hunter)
	19263, --Deterrence
	53271, --Master's Call
	34692, --The Beast Within
	
	-- Monk
	125174, --Touch of Karma
	116849, -- Life Cocoon
	119381, --Leg Sweep

	-- Priest
	10060, --Power Infusion
	9484, --Shackle Undead
	10955, --Shackle Undead
	200183, --Apotheosis
	15487, --Silence
	15286, --Vampiric Embrace
	193223, --Surrender to Madness
	88625, --Holy Word: Chastise
	48066, --Power Word: Shield
	41635, --Prayer of Mending
	6346, --Fear Ward

	-- Warlock
	108416, --Dark Pact
	196098, --Soul Harvest
	30283, --Shadowfury
	24259, --Spell Lock - Felhunter

	-- Demon Hunter
	198589, --Blur
	179057, --Chaos Nova
	209426, --Darkness
	217832, --Imprison
	206491, --Nemesis
	211048, --Chaos Blades
	207685, --Sigil of Misery
	209261, --Last Resort (cd)
	207810, --Nether Bond

	-- Disarms
	676, --Disarm
	51722, --Dismantle
	53359, --Chimera Shot - Scorpid
	64346, --Fiery Payback
	50541, --Snatch - Bird of Prey

	-- Silences
	18498, --Silenced - Gag Order
	55021, --Silenced - Improved Counterspell
	18425, --Silenced - Improved Kick
	63529, --Silenced - Shield of the Templar
	43523, --Unstable Affliction

	-- Healing Reduction
	49050, --Aimed Shot
	47486, --Mortal Strike
	64850, --Unrelenting Assault
	57975, --Wound Poison VII

	-- Other Important
	49016, --Hysteria
	48451, --Lifebloom
	69369, --Predator's Swiftness
	48441, --Rejuvenation
	61301, --Riptide
	8178, --Grounding Totem Effect
	12355, --Impact
	9005, --Pounce
	50518, --Ravage - Ravager
	50519, --Sonic Blast (Bat)
	19306, --Counterattack
	64695, --Earthgrab
	19185, --Entrapment
	50245, --Pin(Crab)
	58373, --Glyph of Hamstring
	54833, --Glyph of Innervate
    44545, --Fingers Of Frost
	12494, --Frostbite
    33395, --Freeze(pet)
	122, --Frost Nova
	55080, --Shattered Barrier(mage talent)
	39796, --Stoneclaw Stun
	20170, --Stun(mele)
	32752, --Summoning Disorientation
	54706, --Venom Web Spray
	4167, --Web
	

	----
	2335, --Swiftness Potion
	6624, --Free Action Potion
	6615, --Free Action
	67867, --Trampled (ToC arena spell when you run over someone)
	3448, --Lesser Invisibility Potion
	11464, --Invisibility Potion
	17634, --Potion of Petrification
	53905, --Indestructible Potion
	54221, --Potion of Speed
	53908, --Speed
	52418, --Carrying Seaforium
	30217, --Adamantite Grenade
	67769, --Cobalt Frag Bomb
	30216, --Fel Iron Bomb
}
fPB.defaultSpells1 = defaultSpells1
fPB.defaultSpells2 = defaultSpells2