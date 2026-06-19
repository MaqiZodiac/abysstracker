return {
    zone_name='Abyssea - Misareaux', zone_id=216,
    confluxes={[1]={pos='L-7'},[2]={pos='J-8'},[3]={pos='F-7'},[4]={pos='H-11'},[5]={pos='G-6'},[6]={pos='F-8'},[7]={pos='H-13'},[8]={pos='L-13'}},
    nms={
        --==========================================================================
        -- CIREIN-CROIN — Zone Boss
        -- MECHANIC: Can Charm when near death — kill quickly!
        -- Drops: Cirein. Lantern (trial), Balance Stone
        --==========================================================================
        {name='Cirein-croin',pos='K-8',conflux=2,
         goal_drops={{name='Cirein. Lantern',type='item'},{name='Balance Stone',type='item'}},
         atma={'Atma of the Apocalypse'},trusts={'TBD'},
         chain={
             {nm='Cep-Kamuy',pos='J-7',timed=false,ki={id=1504,name='Glistening Orobon Liver'},
              pop_items={{name='Orobon Meat',from='Ancient Orobon',from_pos='H-J/6-8'}}},
             {nm='Heqet',pos='H-13',timed=true,ki={id=1505,name='Doffed Poroggo Hat'},pop_items={}},
         }},
        --==========================================================================
        -- AMHULUK (Amphiptere) — pops with 3 KIs
        -- Drops: Balance Stone, Balance Card
        --==========================================================================
        {name='Amhuluk',pos='G-8',conflux=2,
         goal_drops={{name='Balance Stone',type='item'},{name='Balance Card',type='item'}},
         atma={'TBD'},trusts={'TBD'},
         chain={
             {nm='Funereal Apkallu',pos='H-7',timed=false,ki={id=1501,name='Jagged Apkallu Beak'},
              pop_items={{name='Apkallu Down',from='Overking Apkallu',from_pos='H-I/6-7'}}},
             {nm='Manohra',pos='I-7',timed=false,ki={id=1502,name='Clipped Bird Wing'},
              pop_items={{name='Avian Remex',from='Frigatebird',from_pos='I-J/6-8'}}},
             {nm='Asanbosam',pos='G-8',timed=true,ki={id=1503,name='Bloodied Bat Fur'},pop_items={}},
         }},
        --==========================================================================
        -- SOBEK (Bugard boss) — pops with 3 KIs from Minax Bugard/Sirrush/Gukumatz
        -- Drops: Sobek's Skin (trial)
        --==========================================================================
        {name='Sobek',pos='K-10',conflux=4,
         goal_drops={{name="Sobek's Skin",type='item'}},
         atma={'Atma of the Gnarled Horn'},trusts={'TBD'},
         chain={
             {nm='Minax Bugard',pos='J-10',timed=false,ki={id=1498,name='Bloodstained Bugard Fang'},
              pop_items={{name='Bewitching Tusk',from='Abyssobugard',from_pos='J-K/10-11'}}},
             {nm='Sirrush',pos='K-9',timed=false,ki={id=1499,name='Gnarled Lizard Nail'},
              pop_items={{name='Molt Scraps',from='Dusk Lizard',from_pos='J-L/8-10'}}},
             {nm='Gukumatz',pos='I-8',timed=true,ki={id=1500,name='Molted Peiste Skin'},pop_items={}},
         }},
        --==========================================================================
        -- IRONCLAD PULVERIZER — Zone Ironclad
        -- Drops: Ardor Stone, Ardor Coin, Atma of the Razed Ruins
        -- MECHANIC: At low HP, head separates as second NM — defeat both!
        --==========================================================================
        {name='Ironclad Pulverizer',pos='K-13',conflux=7,
         goal_drops={{name='Ardor Stone',type='item'},{name='Ardor Coin',type='item'}},
         atma={'Atma of the Razed Ruins'},trusts={'TBD'},
         chain={
             {nm='Ironclad Observer',pos='K-13',timed=false,ki={id=1506,name='Scalding Ironclad Spike'},
              pop_items={{name='Spheroid Plate',from='Observer',from_pos='K-L/12-14'}}},
             {nm='Abyssic Cluster',pos='H-12',timed=true,ki={id=1507,name='Blazing Cluster Soul'},pop_items={}},
         }},
    },
}
