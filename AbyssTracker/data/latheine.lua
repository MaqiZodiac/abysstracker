return {
    zone_name='Abyssea - La Theine', zone_id=132,
    -- Confluxes verified from gamerescape zone page
    confluxes={[1]={pos='E-3'},[2]={pos='D-8'},[3]={pos='G-8'},[4]={pos='H-7'},[5]={pos='I-10'},[6]={pos='L-11'},[7]={pos='K-6'},[8]={pos='I-9'}},
    nms={
        --==========================================================================
        -- BRIAREUS (G-6) — Zone Boss, pops with 3 KIs from Adamastor/Pantagruel/Grandgousier
        -- Drops: Helm of Briareus (trial), Stone/Jewel of Voyage, Blood-Smeared Gigas Helm (KI→Hadhayosh)
        --==========================================================================
        {name='Briareus',pos='G-6',conflux=4,
         goal_drops={{name='Helm of Briareus',type='item'},{name='Voyage Stone',type='item'}},
         atma={'Atma of the Stout Arm','Atma of the Apocalypse'},trusts={'TBD'},
         chain={
             {nm='Adamastor',pos='C-4',timed=false,ki={id=1482,name='Dented Gigas Shield'},
              pop_items={{name='Trophy Shield',from='Bathyal Gigas',from_pos='C-D/3-5'}}},
             {nm='Grandgousier',pos='F-10',timed=false,ki={id=1484,name='Severed Gigas Collar'},
              pop_items={{name='Massive Armband',from='Demersal Gigas',from_pos='E-F/9-11'}}},
             {nm='Pantagruel',pos='F-7',timed=false,ki={id=1483,name='Warped Gigas Armband'},
              pop_items={{name='Oversized Sock',from='Hadal Gigas',from_pos='F-G/7-9'}}},
         }},
        --==========================================================================
        -- CARABOSSE (H-7) — pops with Pellucid Fly Eye + Shimmering Pixie Pinion
        -- Drops: Carabosse's Gem (trial), Coin/Card of Voyage, Glittering Pixie Choker (KI→Hadhayosh)
        --==========================================================================
        {name='Carabosse',pos='H-7',conflux=4,
         goal_drops={{name="Carabosse's Gem",type='item'},{name='Voyage Coin',type='item'}},
         atma={'Atma of Allure'},trusts={'TBD'},
         chain={
             {nm='La Theine Liege',pos='I-7',timed=false,ki={id=1485,name='Pellucid Fly Eye'},
              pop_items={{name='Tr. Insect Wing',from='Plateau Glider',from_pos='H-K/6-9'}}},
             {nm='Baba Yaga',pos='H-7',timed=false,ki={id=1486,name='Shimmering Pixie Pinion'},
              pop_items={{name='Piceous Scale',from='Farfadet',from_pos='H-K/7-10'}}},
         }},
        --==========================================================================
        -- HADHAYOSH (K-8) — pops with 4 KIs: 2 from Briareus chain + 2 from Carabosse chain
        -- NOTE: You need Blood-Smeared Gigas Helm (from Briareus) AND Glittering Pixie Choker (from Carabosse)!
        -- Drops: Coin/Jewel of Voyage
        --==========================================================================
        {name='Hadhayosh',pos='K-8',conflux=7,
         goal_drops={{name='Voyage Coin',type='item'},{name='Voyage Jewel',type='item'}},
         atma={'Atma of the Lion'},trusts={'TBD'},
         chain={
             {nm='Trudging Thomas',pos='J-8',timed=false,ki={id=1478,name='Marbled Mutton Chop'},
              pop_items={{name='R. Mutton Chop',from='Hammering Ram',from_pos='H-K/7-10'}}},
             {nm='Megantereon',pos='C-7',timed=false,ki={id=1479,name='Bloodied Saber Tooth'},
              pop_items={{name='G. Blk. Tiger Fang',from='Angler Tiger',from_pos='B-D/6-8'}}},
             -- NOTE: Also requires Blood-Smeared Gigas Helm (KI from Briareus)
             -- and Glittering Pixie Choker (KI from Carabosse) — farm those bosses first!
         }},
        --==========================================================================
        -- ECCENTRIC EVE (I-7, Konschtat) — also spawnable here with same 5 KIs
        -- Drops: Stone/Card of Vision
        --==========================================================================
        {name='Eccentric Eve',pos='I-7',conflux=4,
         goal_drops={{name='Voyage Stone',type='item'},{name='Voyage Card',type='item'}},
         atma={'Atma of the Voracious Violet'},trusts={'TBD'},
         chain={
             {nm='Clingy Clare',pos='I-8',timed=false,ki={id=1461,name='Decaying Morbol Tooth'},
              pop_items={{name='Tiny Morbol Vine',from='Morboling',from_pos='H-J/7-9'}}},
             {nm='Gangly Gean',pos='E-10',timed=true,ki={id=1459,name='Fragrant Treant Petal'},pop_items={}},
             {nm='Raskovnik',pos='F-6',timed=true,ki={id=1460,name='Fetid Rafflesia Stalk'},pop_items={}},
             {nm='Fistule',pos='G-3',timed=true,ki={id=1462,name='Turbid Slime Oil'},pop_items={}},
         }},
    },
}
