return {
    zone_name='Abyssea - Altepa', zone_id=218,
    confluxes={[1]={pos='L-5'},[2]={pos='K-2'},[3]={pos='G-5'},[4]={pos='E-8'},[5]={pos='D-11'},[6]={pos='E-6'},[7]={pos='E-7'},[8]={pos='G-9'}},
    nms={
        --==========================================================================
        -- BENNU (I-8) — item-pop, trade KI Resplendent Roc Quill to ??? @ I-8
        -- "Resplendent Roc Quill" comes from completing certain Dominion objectives
        -- Drops: Ardor Coin, Atma of the Ascending One
        --==========================================================================
        {name='Bennu',pos='I-8',conflux=1,
         goal_drops={{name='Ardor Coin',type='item'}},
         atma={'Atma of the Ascending One'},trusts={'TBD'},
         chain={
             {nm='Roc (source)',pos='Various',timed=true,ki={id=1522,name='Resplendent Roc Quill'},pop_items={},
              notes='Permanent KI from Dominion ops — trade to ??? @ I-8 to pop Bennu'},
         }},
        --==========================================================================
        -- RANI (D-10) — pops with 2 KIs (Broken Iron Giant Spike + Rusted Chariot Gear)
        -- REQUIREMENT: Tier 2 Ironclad AND Chariot Dominion ops must be at 100%
        -- MECHANIC: Charms when near death — have a friend brew or kill fast!
        -- Drops: Ardor Jewel, Ardor Card, Atma of the Merciless Matriarch
        --==========================================================================
        {name='Rani',pos='D-10',conflux=5,
         goal_drops={{name='Ardor Jewel',type='item'},{name='Ardor Card',type='item'}},
         atma={'Atma of the Merciless Matriarch'},trusts={'TBD'},
         chain={
             {nm='Ironclad (Tier 2)',pos='Various',timed=true,ki={id=1518,name='Broken Iron Giant Spike'},pop_items={},
              notes='Complete Tier 2 Ironclad Dominion op — must be at 100%'},
             {nm='Chariot (Tier 2)',pos='Various',timed=true,ki={id=1519,name='Rusted Chariot Gear'},pop_items={},
              notes='Complete Tier 2 Chariot Dominion op — must be at 100%'},
         }},
        --==========================================================================
        -- ORTHRUS (H-8) — pops with Steaming Cerberus Tongue from Amarok
        -- Amarok (E-6, near Conflux #6/#7): trade 3 items to ??? @ E-6:
        --   H.Q. Dhalmel Hide (from Camelopardalis), Sharabha Hide (from Sharabha NM),
        --   Tiger King Hide (from Ansherekh NM)
        -- Drops: Orthrus's Claw (trial)
        --==========================================================================
        {name='Orthrus',pos='H-8',conflux=3,
         goal_drops={{name="Orthrus's Claw",type='item'}},
         atma={'TBD'},trusts={'TBD'},
         chain={
             {nm='Amarok',pos='E-6',timed=false,ki={id=1520,name='Steaming Cerberus Tongue'},
              pop_items={
                  {name='H.Q. Dhalmel Hide',from='Camelopardalis',from_pos='E-G/5-7'},
                  {name='Sharabha Hide',from='Sharabha',from_pos='E-G/5-8'},
                  {name='Tiger King Hide',from='Ansherekh',from_pos='E-G/6-8'},
              }},
         }},
        --==========================================================================
        -- DRAGUA (cross-zone)
        --==========================================================================
        {name='Dragua',pos='F-5 (Vunkerl)',conflux=1,
         goal_drops={{name="Dragua's Scale",type='item'}},
         atma={'Atma of the Earth Wyrm'},trusts={'TBD'},
         chain={
             {nm='Chloris',pos='I-8 (Tahrongi)',timed=false,ki={id=1476,name='Overgrown Mandragora Flower'},
              pop_items={},notes='Cross-zone: pop Chloris in Abyssea - Tahrongi'},
             {nm='Glavoid',pos='I-5 (Tahrongi)',timed=false,ki={id=1477,name='Chipped Sandworm Tooth'},
              pop_items={},notes='Cross-zone: pop Glavoid in Abyssea - Tahrongi'},
         }},
    },
}
