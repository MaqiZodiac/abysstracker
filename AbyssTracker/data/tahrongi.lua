return {
    zone_name='Abyssea - Tahrongi', zone_id=45,
    confluxes={[1]={pos='F-13'},[2]={pos='H-10'},[3]={pos='F-9'},[4]={pos='F-6'},[5]={pos='G-4'},[6]={pos='G-6'},[7]={pos='H-7'},[8]={pos='J-5'}},
    nms={
        {name='Chloris',pos='I-8',conflux=2,
         goal_drops={{name='2Lf. Chloris Bud',type='item'}},
         atma={
             'Atma of the Merciless Matriarch',
             'Atma of the Einherjar',
             'Atma of the Lion',
         },
         trusts={'TBD'},
         chain={
             {nm='Ophanim',pos='G-9',timed=false,ki={id=1468,name='Veinous Hecteyes Eyelid'},
              pop_items={
                  {name='Bl. Hecteye',from='Beholder',from_pos='H-8'},
                  {name='Shriveled Wing',from='Halimede',from_pos='G-12',
                   pop_items={{name='H.Q. Cli. Wing',from='Gully Clionid',from_pos='F-11'}}},
                  {name='Tarnished Pincer',from='Vetehinen',from_pos='H-10',
                   pop_items={{name='H.Q. Lim. Pincer',from='Gulch Limule',from_pos='H-10'}}},
              }},
             {nm='Treble Noctules',pos='I-9',timed=false,ki={id=1469,name='Torn Bat Wing'},
              pop_items={
                  {name='Bloody Fang',from='Blood Bat',from_pos='I-9'},
                  {name='Exorcised Skull',from='Cannered Noz',from_pos='F-6',
                   pop_items={{name='Baleful Skull',from='Caoineag',from_pos='F-6'}}},
              }},
             {nm='Hedetet',pos='F-7',timed=false,ki={id=1470,name='Gory Scorpion Claw'},
              pop_items={
                  {name='V. Scorp. Stinger',from='Canyon Scorpion',from_pos='F-7'},
                  {name='Acidic Humus',from='Gancanagh',from_pos='H-8',
                   pop_items={{name='Alkaline Humus',from='Pachypodium',from_pos='I-8'}}},
              }},
             {nm='Chukwa',pos='F-4/G-5',timed=true,ki={id=1471,name='Mossy Adamantoise Shell'},pop_items={}},
         }},
        {name='Glavoid',pos='I-5',conflux=8,
         goal_drops={{name='Glavoid Shell',type='item'}},
         atma={
             'Atma of the Merciless Matriarch',
             'Atma of the Einherjar',
             'Atma of the Apocalypse',
         },
         trusts={'TBD'},
         chain={
             {nm='Alectryon',pos='H-8',timed=false,ki={id=1472,name='Fat-lined Cockatrice Skin'},
              pop_items={
                  {name='Ctrice. Tailmeat',from='Cluckatrice',from_pos='H-8'},
                  {name='Quiv. Eft Egg',from='Abas',from_pos='K-10',
                   pop_items={{name='Eft Egg',from='Canyon Eft',from_pos='J-10'}}},
              }},
             {nm='Minhocao',pos='I-6',timed=true,ki={id=1473,name='Sodden Sandworm Husk'},pop_items={}},
             {nm='Muscaliet',pos='J-6',timed=false,ki={id=1474,name='Luxuriant Manticore Mane'},
              pop_items={
                  {name='Resilient Mane',from='Hieracosphinx',from_pos='I-6'},
                  {name='Smooth Whisker',from='Tefenet',from_pos='J-6',
                   pop_items={{name='Shk. Whisker',from='Jaguarundi',from_pos='H-6'}}},
              }},
             {nm='Adze',pos='G-5',timed=true,ki={id=1475,name='Sticky Gnat Wing'},pop_items={}},
         }},
    },
}