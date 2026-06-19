return {
    zone_name='Abyssea - Konschtat', zone_id=15,
    confluxes={[1]={pos='I-13'},[2]={pos='G-10'},[3]={pos='D-7'},[4]={pos='H-8'},[5]={pos='G-6'},[6]={pos='F-5'},[7]={pos='K-8'},[8]={pos='J-4'}},
    nms={
        {name='Kukulkan',pos='H-5',conflux=5,
         goal_drops={{name="Kukulkan's Fang",type='item'},{name='Vision Jewel',type='item'}},
         atma={'Atma of the Noxious Fang','Atma of the Apocalypse'},trusts={'TBD'},
         chain={
             {nm='Alkonost',pos='H-6',timed=false,ki={id=1464,name='Tattered Hippogryph Wing'},
              pop_items={{name='M-bugard Tusk',from='Ypotryll',from_pos='H-J/5-7'}}},
             {nm='Keratyrannos',pos='G-6',timed=false,ki={id=1465,name='Cracked Wivre Horn'},
              pop_items={{name='Arm. Dragonhorn',from='Mesa Wivre',from_pos='F-H/5-7'}}},
             {nm='Arimaspi',pos='K-6',timed=false,ki={id=1466,name='Mucid Ahriman Eyeball'},
              pop_items={{name='Clouded Lens',from='Deep Eye',from_pos='J-L/5-7'}}},
         }},
        {name='Eccentric Eve',pos='I-7',conflux=5,
         goal_drops={{name='Vision Stone',type='item'},{name='Vision Card',type='item'}},
         atma={'Atma of the Voracious Violet'},trusts={'TBD'},
         chain={
             {nm='Clingy Clare',pos='I-8',timed=false,ki={id=1461,name='Decaying Morbol Tooth'},
              pop_items={{name='Tiny Morbol Vine',from='Morboling',from_pos='H-J/7-9'}}},
             {nm='Gangly Gean',pos='E-10',timed=true,ki={id=1459,name='Fragrant Treant Petal'},pop_items={}},
             {nm='Raskovnik',pos='F-6',timed=true,ki={id=1460,name='Fetid Rafflesia Stalk'},pop_items={}},
             {nm='Fistule',pos='G-3',timed=true,ki={id=1462,name='Turbid Slime Oil'},pop_items={}},
             -- 5th KI: kill Kukulkan first, he drops this
             {nm='Kukulkan',pos='H-5',timed=false,ki={id=1463,name='Venomous Peiste Claw'},pop_items={},
              notes='Kill Kukulkan first — he drops this 5th KI'},
         }},
    },
}
