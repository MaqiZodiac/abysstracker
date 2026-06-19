return {
    zone_name='Abyssea - Grauberg', zone_id=254,
    confluxes={[1]={pos='B-13'},[2]={pos='F-12'},[3]={pos='H-10'},[4]={pos='F-11'},[5]={pos='E-6'},[6]={pos='G-5'},[7]={pos='C-7'},[8]={pos='I-7'}},
    nms={
        --==========================================================================
        -- AMPHITRITE (Uragnite boss) — timed pop via Melo Melo
        -- Drops: Ardor Stone
        --==========================================================================
        {name='Amphitrite',pos='F-8',conflux=3,
         goal_drops={{name='Ardor Stone',type='item'}},
         atma={'Atma of the Shimmering Shell'},trusts={'TBD'},
         chain={
             {nm='Melo Melo',pos='E-7',timed=true,ki={id=1532,name='Variegated Uragnite Shell'},pop_items={}},
         }},
        --==========================================================================
        -- AZDAJA (Wyvern boss) — timed pop via Deelgeed
        -- Drops: Azdaja's Horn (trial), Ardor Jewel
        --==========================================================================
        {name='Azdaja',pos='H-8',conflux=3,
         goal_drops={{name="Azdaja's Horn",type='item'},{name='Ardor Jewel',type='item'}},
         atma={'TBD'},trusts={'TBD'},
         chain={
             {nm='Deelgeed',pos='I-8',timed=true,ki={id=1531,name='Vacant Bugard Eye'},pop_items={}},
         }},
        --==========================================================================
        -- ALFARD (Hydra boss) — pops with Venomous Hydra Fang from Ningishzida
        -- Drops: Alfard's Fang (trial)
        -- Ningishzida pops from: Pursuer's Wing (Faunus Wyvern) + Minaruja Skull (Minaruja)
        --==========================================================================
        {name='Alfard',pos='G-7',conflux=3,
         goal_drops={{name="Alfard's Fang",type='item'}},
         atma={'Atma of the Brother Wolf'},trusts={'TBD'},
         chain={
             {nm='Ningishzida',pos='H-7',timed=false,ki={id=1530,name='Venomous Hydra Fang'},
              pop_items={
                  {name="Pursuer's Wing",from='Faunus Wyvern',from_pos='H-I/6-8'},
                  {name='Minaruja Skull',from='Minaruja',from_pos='G-H/7-9'},
              }},
         }},
        --==========================================================================
        -- RAJA (Manticore boss) — pops with 2 KIs from Ironclad Sunderer + Assailer Chariot
        -- MECHANIC: Charms when near death — kill quickly!
        -- Drops: Ardor Card, Ardor Stone
        --==========================================================================
        {name='Raja',pos='G-6',conflux=3,
         goal_drops={{name='Ardor Card',type='item'},{name='Ardor Stone',type='item'}},
         atma={'TBD'},trusts={'TBD'},
         chain={
             {nm='Ironclad Sunderer',pos='F-8',timed=false,ki={id=1528,name='Shattered Iron Giant Chain'},
              pop_items={
                  {name='Teekess. Fragment',from='Teekesselchen',from_pos='E-G/7-9',
                   pop_items={{name='Bubbling Oil',from='Sinister Seidel',from_pos='F-H/8-10'}}},
              }},
             {nm='Assailer Chariot',pos='I-7',timed=true,ki={id=1529,name='Warped Chariot Plate'},pop_items={}},
         }},
    },
}
