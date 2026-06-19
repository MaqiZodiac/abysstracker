--==================================================================================================
-- AbyssTracker Atma Data
-- Effects verified from BG-wiki (bg-wiki.com/ffxi/Abyssea_Lights) and FFXIclopedia
-- Source: Search result index 13 from bg-wiki.com/ffxi/Abyssea_Lights confirmed effects
-- Format: name = { source, effects[] }
-- Effect tiers: Minor < Major < Superior
--==================================================================================================

return {
    -- ── VISION: LA THEINE ────────────────────────────────────────────────────

    ['Atma of the Lion'] = {
        source = 'Hadhayosh (Abyssea - La Theine)',
        effects = {
            'STR+: Major',
            'DEX+: Major',
            'Attack+: Major',
        },
    },
    ['Atma of the Stout Arm'] = {
        source = 'Briareus (Abyssea - La Theine)',
        effects = {
            'STR+: Major',
            'Attack+: Superior',
            'Ranged Attack+: Major',
        },
    },
    ['Atma of the Voracious Violet'] = {
        source = 'Eccentric Eve (Abyssea - Konschtat)',
        effects = {
            'STR+: Superior',
            'Double Attack+: Major',
            'Regain+: Major (2 TP/tick)',
        },
    },

    -- ── VISION: KONSCHTAT ────────────────────────────────────────────────────

    ['Atma of the Stormbird'] = {
        source = 'Kukulkan (Abyssea - Konschtat)',
        effects = {
            'Wind Accuracy+: Major',
            'Lightning Accuracy+: Major',
            'Refresh+: Minor',
        },
    },
    ['Atma of the Gnarled Horn'] = {
        source = 'Bloodeye Vileberry (Abyssea - Konschtat)',
        effects = {
            'AGI+: Superior',
            'Critical Hit Rate+: Minor',
            'Counter+: Minor',
        },
    },

    -- ── VISION: TAHRONGI ─────────────────────────────────────────────────────

    ['Atma of the Merciless Matriarch'] = {
        source = 'Chloris (Abyssea - Tahrongi) / Rani (Abyssea - Altepa)',
        effects = {
            'Magic Accuracy+: Superior',
            'Fast Cast+: Superior (7.5%)',
            'Enmity-: Superior',
            'Note: Element bonus applies to same-element weather',
        },
    },
    ['Atma of the Stronghold'] = {
        source = 'Glavoid (Abyssea - Tahrongi)',
        effects = {
            'Attack+: Major',
            'Defense+: Major',
            'Regen+: Major',
        },
    },

    -- ── SYNTHETIC (purchasable) ───────────────────────────────────────────────

    ['Atma of the Apocalypse'] = {
        source = 'Shinryu (Empyreal Paradox) — requires all 9 zone bosses',
        effects = {
            'Triple Attack+: Superior (15%)',
            'Quick Magic (10% chance to cast instantly)',
            'Auto-Reraise (Reraise III on KO)',
        },
    },
    ['Atma of the Einherjar'] = {
        source = 'Synthetic — requires Elite Einherjar title from Odin. Buy from Atma Fabricant for 1500 Cruor',
        effects = {
            'MP+: Superior',
            'Regen+: Major',
            'Auto-Reraise (Reraise III on KO)',
        },
    },
    ['Atma of the Minikin Monstrosity'] = {
        source = 'Durinn (Abyssea - Vunkerl) / Ulhuadshi (Abyssea - Attohwa)',
        effects = {
            'INT+: Superior',
            'Refresh+: Major (10 MP/tick)',
            'Enmity-: Minor',
        },
    },
    ['Atma of the Razed Ruins'] = {
        source = 'Ironclad Pulverizer (Abyssea - Misareaux)',
        effects = {
            'DEX+: Superior',
            'Critical Hit Rate+: Major',
            'Critical Hit Damage+: Major',
        },
    },

    -- ── SCARS: ATTOHWA ───────────────────────────────────────────────────────

    ['Atma of the Clawed Butterfly'] = {
        source = 'Itzpapalotl (Abyssea - Attohwa)',
        effects = {
            'STR+: Major',
            'Accuracy+: Major',
            'Wind Attack+: Major',
        },
    },
    ['Atma of the Desert Worm'] = {
        source = 'Smok (Abyssea - Attohwa)',
        effects = {
            'HP+: Superior',
            'Evasion+: Major',
            'Regen+: Major',
        },
    },
    ['Atma of the Undying'] = {
        source = 'Titlacauan (Abyssea - Attohwa)',
        effects = {
            'Dark Attack+: Major',
            'Dark Accuracy+: Major',
            'Enspell Damage+: Major',
        },
    },

    -- ── SCARS: MISAREAUX ─────────────────────────────────────────────────────

    ['Atma of the Gnarled Horn'] = {
        source = 'Sobek (Abyssea - Misareaux)',
        effects = {
            'AGI+: Superior',
            'Critical Hit Rate+: Minor',
            'Counter+: Minor',
        },
    },
    ['Atma of the Sanguine Scythe'] = {
        source = 'Bukhis (Abyssea - Vunkerl)',
        effects = {
            'HP+: Major',
            'Critical Hit Damage+: Major',
            'Enmity+: Minor',
        },
    },

    -- ── SCARS: VUNKERL ───────────────────────────────────────────────────────

    ['Atma of the Earth Wyrm'] = {
        source = 'Dragua (Abyssea - Vunkerl)',
        effects = {
            'STR+: Major',
            'VIT+: Major',
            'Store TP+: Major',
            'Double Attack+: Minor',
        },
    },

    -- ── HEROES: GRAUBERG ─────────────────────────────────────────────────────

    ['Atma of the Brother Wolf'] = {
        source = 'Alfard (Abyssea - Grauberg)',
        effects = {
            'STR+: Superior',
            'Attack+: Major',
            'Double Attack+: Minor',
        },
    },

    -- ── HEROES: ALTEPA ───────────────────────────────────────────────────────

    ['Atma of the Ascending One'] = {
        source = 'Bennu (Abyssea - Altepa)',
        effects = {
            'Fire Attack+: Superior',
            'Fire Accuracy+: Superior',
            'Magic Attack Bonus+: Major',
        },
    },

    -- ── HEROES: ULEGUERAND ───────────────────────────────────────────────────

    ['Atma of the Omnipotent'] = {
        source = 'Pantokrator (Abyssea - Uleguerand)',
        effects = {
            'DEX+: Superior',
            'Haste+: Superior',
            'Enmity+: Minor',
        },
    },
}