return {
    zone_name='Abyssea - Uleguerand', zone_id=253,
    -- Conflux #8 corrected to D-8 (verified in-game)
    confluxes={[1]={pos='G-12'},[2]={pos='G-9'},[3]={pos='D-4'},[4]={pos='J-11'},[5]={pos='K-9'},[6]={pos='J-5'},[7]={pos='F-8'},[8]={pos='D-8'}},
    nms={
        --==========================================================================
        -- RESHEPH (H-8) — timed pop via Awahondo diremite
        -- Awahondo timed around H-8 area
        -- Drops: Ardor Coin, Ardor Stone
        --==========================================================================
        {name='Resheph',pos='H-8',conflux=2,
         goal_drops={{name='Ardor Coin',type='item'},{name='Ardor Stone',type='item'}},
         atma={'Atma of the Apocalypse'},trusts={'TBD'},
         chain={
             {nm='Awahondo',pos='H-8',timed=true,ki={id=1527,name='Decaying Diremite Fang'},pop_items={}},
         }},
        --==========================================================================
        -- ISGEBIND (I-5/J-5) — timed pop via Kur
        -- Kur: timed wolf NM, spawns among Adasaurus @ I-5/J-5, near Conflux #6
        -- Repop: every 10-15 minutes
        -- Drops: Isgebind's Heart (trial)
        --==========================================================================
        {name='Isgebind',pos='J-5',conflux=6,
         goal_drops={{name="Isgebind's Heart",type='item'}},
         atma={'TBD'},trusts={'TBD'},
         chain={
             {nm='Kur',pos='I-5/J-5',timed=true,ki={id=1526,name='Begrimed Dragon Hide'},pop_items={},
              notes='Timed wolf NM among Adasaurus near Conflux #6 — repops every 10-15 min'},
         }},
        --==========================================================================
        -- APADEMAK (F-7) — pops with 3 items traded to ??? @ F-7 (bottom of ramp):
        --   Snow God Core (from Upas-Kamuy @ G-5)
        --   Sisyphus Fragment (from Sisyphus timed @ G-6 among Verglas Golem)
        --   H.Q. Marid Hide (from Marid-family mob in zone)
        -- Drops: Apademak Horn (trial)
        --==========================================================================
        {name='Apademak',pos='F-7',conflux=7,
         goal_drops={{name='Apademak Horn',type='item'}},
         atma={'TBD'},trusts={'TBD'},
         chain={
             {nm='Dhorme Khimaira',pos='F-7',timed=false,ki={id=1525,name='Torn Khimaira Wing'},
              pop_items={
                  {name='Snow God Core',from='Upas-Kamuy',from_pos='G-5',
                   pop_items={
                       {name='Gelid Arm',from='Snowflake',from_pos='F-5'},
                   }},
                  {name='Sisyphus Fragment',from='Sisyphus',from_pos='G-6',
                   pop_items={
                       {name='TBD',from='Verglas Golem (timed among)',from_pos='G-6'},
                   }},
                  {name='H.Q. Marid Hide',from='Marid (zone mob)',from_pos='TBD'},
              },
              notes='Sisyphus is timed (10+ min repop) among Verglas Golem @ G-6. Trade all 3 to ??? @ F-7'},
         }},
        --==========================================================================
        -- PANTOKRATOR (H-10) — pops with 3 KIs
        -- Drops: Ardor Stone, Ardor Coin, Atma of the Omnipotent
        --==========================================================================
        {name='Pantokrator',pos='H-10',conflux=2,
         goal_drops={{name='Ardor Stone',type='item'},{name='Ardor Coin',type='item'}},
         atma={'Atma of the Omnipotent'},trusts={'TBD'},
         chain={
             {nm='Ironclad Triturator',pos='H-10',timed=false,ki={id=1523,name='Warped Iron Giant Nail'},
              pop_items={
                  {name='Bevel Gear',from='Koghatu',from_pos='G-I/9-11',
                   pop_items={{name='Helical Gear',from='Mechanical Menace',from_pos='H-J/9-11'}}},
              }},
             {nm='Impervious Chariot',pos='K-10',timed=true,ki={id=1524,name='Dented Chariot Shield'},pop_items={}},
             {nm='Assailer Chariot',pos='I-7',timed=true,ki={id=1529,name='Warped Chariot Plate'},pop_items={}},
         }},
    },
}
