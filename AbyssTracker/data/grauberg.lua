return {
    zone_name='Abyssea - Grauberg', zone_id=254,
    confluxes={[1]={pos='B-13'},[2]={pos='F-12'},[3]={pos='H-10'},[4]={pos='F-11'},[5]={pos='E-6'},[6]={pos='G-5'},[7]={pos='C-7'},[8]={pos='I-7'}},
    nms={
        -- ── Empyrean bosses ──────────────────────────────────────────────────
        {name='Azdaja',pos='H-8',conflux=7,
         goal_drops={{id=3292,name="Azdaja's Horn",type='item',target=75}},
         atma={},trusts={'TBD'},
         chain={
             {nm='Deelgeed',pos='F-10',conflux=7,timed=true,ki={id=1531,name='Vacant Bugard Eye'},pop_items={}},
         }},
        {name='Alfard',pos='G-7',conflux=8,
         goal_drops={{id=3291,name="Alfard's Fang",type='item',target=75}},
         atma={},trusts={'TBD'},
         chain={
             {nm='Ningishzida',pos='I-7',conflux=8,timed=false,ki={id=1530,name='Venomous Hydra Fang'},
              pop_items={
                  {id=3262,name='Jaculus Wing',from='Jaculus',from_pos='I-8',from_conflux=3,notes='Jaculus is timed'},
                  {id=3261,name='Minaruja Skull',from='Minaruja',from_pos='I-10',from_conflux=3,
                   pop_items={{id=3267,name="Pursuer's Wing",from='Faunus Wyvern',from_pos='I-9',from_conflux=3}}},
                  {id=3268,name='H.Q. Wivre Hide',from='Glade Wivre',from_pos='I-8',from_conflux=8},
              }},
         }},
        {name='Amphitrite',pos='F-8',conflux=4,
         goal_drops={},
         atma={},trusts={'TBD'},
         chain={
             {nm='Melo Melo',pos='G-11',conflux=4,timed=true,ki={id=1532,name='Variegated Uragnite Shell'},pop_items={}},
         }},
        {name='Raja',pos='G-6',conflux=6,
         goal_drops={},
         atma={},trusts={'TBD'},
         chain={
             {nm='Ironclad Sunderer',pos='F-8',conflux=8,timed=false,ki={id=1528,name='Shattered Iron Giant Chain'},
              pop_items={
                  {id=3260,name='Teekess. Fragment',from='Teekesselchen',from_pos='I-5',from_conflux=6,
                   pop_items={{id=3265,name='Bubbling Oil',from='Sinister Seidel',from_pos='J-5',from_conflux=6}}},
                  {id=3266,name='Darkflame Arm',from='Stygian Djinn',from_pos='K-7',from_conflux=8},
              }},
             {nm='Assailer Chariot',pos='I-7',conflux=8,timed=true,ki={id=1529,name='Warped Chariot Plate'},pop_items={}},
         }},
        -- ── Other zone NMs (direct item pops, no KI chain) ──────────────────
        {name='Bomblix Flamefinger',pos='G-8',conflux=3,
         goal_drops={},
         atma={},trusts={'TBD'},
         chain={
             {nm='Bomblix Flamefinger',pos='G-8',conflux=3,timed=false,ki={id=nil,name='(direct pop)'},
              pop_items={
                  {id=3264,name='Goblin Gunpowder',from='Burstrox Powderpate',from_pos='I-12',from_conflux=2,
                   pop_items={{id=3273,name='Goblin Rope',from='Goblin Plunderer',from_pos='I-12',from_conflux=2}}},
                  {id=3274,name='Goblin Oil',from='Goblin Meatgrinder',from_pos='J-11',from_conflux=3},
              }},
         }},
        {name='Teugghia',pos='E-6',conflux=5,
         goal_drops={},
         atma={},trusts={'TBD'},
         chain={
             {nm='Teugghia',pos='E-6',conflux=5,timed=false,ki={id=nil,name='(direct pop)'},
              pop_items={
                  {id=3263,name="Naiad's Lock",from='Lorelei',from_pos='F-6',from_conflux=5,
                   pop_items={{id=3271,name='Fay Teardrop',from='Seelie',from_pos='E-6',from_conflux=5}}},
                  {id=3272,name='Unseelie Eye',from='Unseelie',from_pos='F-7',from_conflux=5},
              }},
         }},
        {name='Ika-Roa',pos='J-6',conflux=4,
         goal_drops={},
         atma={},trusts={'TBD'},
         chain={
             {nm='Ika-Roa',pos='J-6',conflux=4,timed=false,ki={id=nil,name='(direct pop)'},
              pop_items={
                  {id=3270,name='H.Q. Pugil Scale',from='Peak Pugil',from_pos='H-11',from_conflux=4},
              }},
         }},
        {name='Xibalba',pos='I-8',conflux=7,
         goal_drops={},
         atma={},trusts={'TBD'},
         chain={
             {nm='Xibalba',pos='I-8',conflux=7,timed=false,ki={id=nil,name='(direct pop)'},
              pop_items={
                  {id=3269,name='Decaying Molar',from='Sensenmann',from_pos='D-8',from_conflux=7},
              }},
         }},
    },
}
