return {
    zone_name='Abyssea - Konschtat', zone_id=15,
    confluxes={[1]={pos='I-13'},[2]={pos='G-10'},[3]={pos='D-7'},[4]={pos='H-8'},[5]={pos='G-6'},[6]={pos='F-5'},[7]={pos='K-8'},[8]={pos='J-4'}},
    nms={
        {name='Kukulkan',pos='H-5',conflux=5,
         goal_drops={{id=2932,name="Kukulkan's Fang",type='item',target=50}},
         atma={'Atma of the Noxious Fang','Atma of the Apocalypse'},trusts={'TBD'},
         chain={
             {nm='Alkonost',pos='H-6',conflux=5,timed=false,ki={id=1464,name='Tattered Hippogryph Wing'},
              pop_items={{id=2912,name='Gt. Bugard Tusk',from='Ypotryll',from_pos='I-6',from_conflux=8}}},
             {nm='Keratyrannos',pos='G-6',conflux=5,timed=false,ki={id=1465,name='Cracked Wivre Horn'},
              pop_items={{id=2910,name='Arm. Dragonhorn',from='Mesa Wivre',from_pos='H-5',from_conflux=5}}},
             {nm='Arimaspi',pos='K-6',conflux=7,timed=false,ki={id=1466,name='Mucid Ahriman Eyeball'},
              pop_items={{id=2913,name='Clouded Lens',from='Deep Eye',from_pos='K-7',from_conflux=7}}},
         }},
        {name='Eccentric Eve',pos='I-7',conflux=4,
         goal_drops={},
         atma={'Atma of the Voracious Violet'},trusts={'TBD'},
         chain={
             {nm='Clingy Clare',pos='I-8',conflux=7,timed=false,ki={id=1461,name='Decaying Morbol Tooth'},
              pop_items={{id=nil,name='Tiny Morbol Vine',from='Morboling',from_pos='I-7',from_conflux=4}}},
             {nm='Gangly Gean',pos='E-10',conflux=2,timed=true,ki={id=1459,name='Fragrant Treant Petal'},pop_items={}},
             {nm='Raskovnik',pos='F-6',conflux=5,timed=true,ki={id=1460,name='Fetid Rafflesia Stalk'},pop_items={}},
             {nm='Fistule',pos='G-3',conflux=6,timed=true,ki={id=1462,name='Turbid Slime Oil'},pop_items={}},
             {nm='Kukulkan',pos='H-5',conflux=5,timed=false,ki={id=1463,name='Venomous Peiste Claw'},pop_items={},
              notes='Kill Kukulkan first for this 5th KI'},
         }},
    },
}
