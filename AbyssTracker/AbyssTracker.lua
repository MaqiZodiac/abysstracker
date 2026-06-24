--==================================================================================================
-- AbyssTracker v3.0
-- MAJOR: Two-row header — "Abyssea Tracker" title bar (drag zone) + nav/breadcrumb row
-- MAJOR: Drop Overview restructured — Boss Drops + ">> Empyrean Armor +1" + ">> Empyrean Armor +2"
--          each as a full replacement screen (state.view = 'plus1' | 'plus2')
-- MAJOR: Empyrean Armor +1 — all 20 jobs in FFXI canonical order, job tabs, slot rows,
--          seal names use correct in-game abbreviated format (Rvg./Aoid./Estq. etc.)
-- MAJOR: Empyrean Armor +2 — currency series with per-item NM source data
-- MAJOR: Drop Sources screen — click any item (boss drop, seal, currency) → sources view
--          listing all NMs that drop it, each linkable to nm_view / entity_view
-- MAJOR: Conflux # shown in nm_list for boss NMs (e.g. "T5 Chloris (I-8) #7")
-- Data:  abyssea_drops.lua v2.0 — full seal table (all 20 jobs × 5 slots × 2-3 NMs each),
--          currency items with NM source arrays, job_display_order in FFXI canonical order
-- Trusts: shows FindAll trust set name + [Summon] button
--==================================================================================================

_addon.name     = 'AbyssTracker'
_addon.author   = 'Maquis'
_addon.version  = '2.5.0'
_addon.commands = {'abysstracker','at'}

require('tables')
require('strings')
local texts = require('texts')
local config = require('config')
local res    = require('resources')

--==================================================================================================
-- ATMA DATA
--==================================================================================================
local atma_db = {}
local function load_atma_db()
    local fn = loadfile(windower.addon_path..'data/atma.lua')
    if fn then local ok,d=pcall(fn); if ok and d then atma_db=d end end
end

--==================================================================================================
-- THEME
--==================================================================================================
local T = {
    BG_A=200,BG_R=10,BG_G=10,BG_B=18,
    HDR_A=255,HDR_R=28,HDR_G=20,HDR_B=50,
    NMH_A=150,NMH_R=45,NMH_G=28,NMH_B=82,
    GOL_A=0,  -- no background on farm item row
    RDY_A=190,RDY_R=18,RDY_G=85,RDY_B=18,
    SEP_A=200,SEP_R=55,SEP_G=42,SEP_B=95,
    HOV_A=90, HOV_R=48,HOV_G=38,HOV_B=92,
    FTR_A=170,FTR_R=28,FTR_G=18,FTR_B=62,
    CFG_A=150,CFG_R=25,CFG_G=25,CFG_B=55,
    WHITE={255,255,255},GOLD={255,200,70},ORANGE={255,140,45},
    LAVNDR={190,165,255},GREEN={70,220,70},RED={220,70,70},
    CYAN={80,220,200},GREY={130,130,150},BLUE={110,160,255},
    LTBLUE={150,195,255},YELLOW={240,220,80},PINK={255,140,180},
    FONT='Tahoma',SZ=11,SZ_H=12,PAD_X=8,PAD_Y=5,ROW_H=17,HDR_H=30,TITLE_H=20,WIDTH=450,
}

-- Configurable nav/link symbol — change with //at chars, persists in settings
local NAV_SYM='-->'
local NAV_FONT=T.FONT  -- font the symbol renders in

--==================================================================================================
-- DEFAULTS
--==================================================================================================
local defaults = {
    display={pos_x=1200,pos_y=160,bg_alpha=200,minimized=false,show_cfg=false,font_size=11,draggable=true,width=450},
    map={visible=false,position='right',size=500},
    session={last_zone='Abyssea - Tahrongi',last_nm='Chloris',last_view='tree',nav_sym='-->',nav_font='Tahoma'},
    collapse={},conflux={},atma={},
    trust_set={},  -- { ['Chloris']='chloris_set', ['Glavoid']='glavoid_set' }
}

--==================================================================================================
-- STATE
--==================================================================================================
local settings={} local zones={} local zone_list={}
local all_prims={} local all_texts={} local hot_zones={}
local map_ctx={created=false,loaded_key=nil,last_size=nil}
local MAP_PRIM='at_map_img'; local MAP_BORDER='at_map_border'
local drag={active=false,sx=0,sy=0,ox=0,oy=0}
local key_state={ctrl=false,alt=false,shift=false}
local state={
    view='zone_menu',zone=nil,nm=nil,
    show_footer=false,footer_entry=nil,
    inv={},ki={},
    minimized=false,px=1200,py=160,panel_h=100,
    map_visible=false,
    chars_font='Wingdings',
    drop_source_item=nil,
    drop_source_back=nil,
    active_job=nil,
}

-- Debug overlay
local dbg_obj=nil
local dbg_hide_at=0
local function init_debug()
    if dbg_obj then return end
    dbg_obj=texts.new({pos={x=10,y=10},
        text={font=T.FONT,size=T.SZ,red=255,green=220,blue=0,alpha=255,bold=true,
              stroke={width=2,alpha=200,red=0,green=0,blue=0}},
        bg={alpha=180,red=0,green=0,blue=0,visible=true},flags={draggable=false},padding=3})
    dbg_obj:hide()
end
local function dbg(msg)
    if not dbg_obj then init_debug() end
    dbg_obj:text('[AT] '..msg)
    dbg_obj:pos(state.px, state.py+state.panel_h+2)
    dbg_obj:show(); dbg_hide_at=os.clock()+5
end
local function update_dbg()
    if dbg_obj and dbg_hide_at>0 and os.clock()>dbg_hide_at then
        dbg_obj:hide(); dbg_hide_at=0
    end
end

--==================================================================================================
-- ZONE LOADING
--==================================================================================================
local zone_files={'tahrongi','latheine','konschtat','attohwa','misareaux','vunkerl','grauberg','altepa','uleguerand'}
local drops_db={}
local function load_drops_db()
    local fn=loadfile(windower.addon_path..'data/abyssea_drops.lua')
    if fn then local ok,d=pcall(fn); if ok and d then drops_db=d end end
end

local function load_zones()
    zones={};zone_list={}
    for _,f in ipairs(zone_files) do
        local fn=loadfile(windower.addon_path..'data/'..f..'.lua')
        if fn then local ok,z=pcall(fn)
            if ok and z and z.zone_name then zones[z.zone_name]=z;zone_list[#zone_list+1]=z.zone_name end
        end
    end
end

-- Dead-end boss overrides: these are popped by chain NM KIs but lead nowhere useful
-- They show as T3 (not T4) because they don't feed a T5 boss
local BOSS_TIER_OVERRIDE={
    ['Dragua']=3, ['Bennu']=3,       -- Altepa dead-ends
    ['Ironclad Smiter']=3,            -- Altepa chain NM, feeds Rani
    ['Rani']=4,                       -- Altepa T4 (override cross-boss T5 detection)
}

-- Determine tier of a boss NM entry
local function boss_tier(nm, zone)
    -- Explicit overrides for structural edge cases
    if BOSS_TIER_OVERRIDE[nm.name] then return BOSS_TIER_OVERRIDE[nm.name] end

    if not nm.chain or #nm.chain==0 then return 4 end

    -- Build boss name set for cross-boss detection
    local boss_names={}
    for _,n in ipairs(zone.nms) do boss_names[n.name]=true end

    -- T5: any chain entry references another REAL T4 boss (not an overridden T3)
    for _,ce in ipairs(nm.chain) do
        if boss_names[ce.nm] and ce.nm~=nm.name and not BOSS_TIER_OVERRIDE[ce.nm] then
            return 5
        end
    end

    -- Self-referencing chain (direct-pop standalone NM) → T2 or T3
    if #nm.chain==1 and nm.chain[1].nm==nm.name then
        local ce=nm.chain[1]
        local ni=ce.pop_items and #ce.pop_items or 0
        local has_ki=ce.ki and ce.ki.id and type(ce.ki.id)=='number' and ce.ki.id~=0
        if ni>=2 or has_ki then return 3 end
        return 2
    end

    return 4
end

-- Determine tier of a chain entry
local function chain_tier(entry)
    local has_real_ki = entry.ki and entry.ki.id and entry.ki.id~=0 and entry.ki.id~='nil'
    if has_real_ki then return 3 end
    local n_items = entry.pop_items and #entry.pop_items or 0
    if n_items >= 2 then return 3 end
    return 2
end

-- Tier colours
local TIER_COL = {
    [1]=T.BLUE,   -- T1 General Mob
    [2]=T.CYAN,   -- T2 Unique NM
    [3]=T.ORANGE, -- T3 Chained NM
    [4]=T.GOLD,   -- T4 Key NM
    [5]=T.RED,    -- T5 Boss NM
}
local TIER_LBL = {[1]='T1',[2]='T2',[3]='T3',[4]='T4',[5]='T5'}

-- Build a sorted flat entity list and reverse-lookup for a zone
-- Returns: flat_entities (sorted T5->T4->T3->T2->T1), reverse_map (name->parent info)
local function build_zone_index(zone)
    local entities = {}   -- {name, pos, tier, kind='boss'|'chain'|'mob', ref, parent_nm, parent_boss}
    local reverse  = {}   -- name -> {boss=nm, chain_entry=ce} or {chain=ce, boss=nm}
    local seen     = {}

    local function add(e) if not seen[e.name] then seen[e.name]=true; entities[#entities+1]=e end end

    for _,nm in ipairs(zone.nms) do
        local t=boss_tier(nm,zone)
        add({name=nm.name, pos=nm.pos, tier=t, kind='boss', ref=nm})

        for _,ce in ipairs(nm.chain or {}) do
            -- chain NM itself
            if ce.nm and ce.nm~=nm.name then
                local ct=chain_tier(ce)
                add({name=ce.nm, pos=ce.pos, tier=ct, kind='chain', ref=ce, parent_boss=nm})
                -- reverse: chain NM -> boss that needs its KI
                if not reverse[ce.nm] then reverse[ce.nm]={} end
                reverse[ce.nm][#reverse[ce.nm]+1]={boss=nm, via_ki=ce.ki}
            end
            -- pop mobs (T1) and forced intermediate NMs (T2)
            for _,pi in ipairs(ce.pop_items or {}) do
                if pi.from then
                    local has_sub = pi.pop_items and #pi.pop_items>0
                    local tier = has_sub and 2 or 1
                    add({name=pi.from, pos=pi.from_pos, tier=tier, kind='mob',
                         ref=pi, parent_chain=ce, parent_boss=nm})
                    if not reverse[pi.from] then reverse[pi.from]={} end
                    reverse[pi.from][#reverse[pi.from]+1]={chain=ce, boss=nm, for_item=pi.name}
                    -- sub-sources of intermediate forced NMs
                    for _,sub in ipairs(pi.pop_items or {}) do
                        if sub.from then
                            add({name=sub.from, pos=sub.from_pos, tier=1, kind='mob',
                                 ref=sub, parent_chain=ce, parent_boss=nm})
                            if not reverse[sub.from] then reverse[sub.from]={} end
                            reverse[sub.from][#reverse[sub.from]+1]={forced_nm=pi.from, chain=ce, boss=nm, for_item=sub.name}
                        end
                    end
                end
            end
        end
    end

    -- Sort: T5 first, then T4, T3, T2, T1
    table.sort(entities, function(a,b) return a.tier > b.tier end)
    return entities, reverse
end

--==================================================================================================
-- SETTINGS
--==================================================================================================
local function save_settings()
    if state.zone then settings.session.last_zone=state.zone.zone_name end
    if state.nm   then settings.session.last_nm=state.nm.name end
    settings.display.minimized=state.minimized
    settings.display.pos_x=state.px;settings.display.pos_y=state.py
    settings.display.width=T.WIDTH
    settings.map.visible=state.map_visible
    settings.session.nav_sym=NAV_SYM
    settings.session.nav_font=NAV_FONT
    config.save(settings)
end
local function load_settings()
    settings=config.load(defaults)
    if not settings.display.font_size then settings.display.font_size=11 end
    if not settings.display.draggable then settings.display.draggable=true end
    if not settings.display.width     then settings.display.width=450 end
    if settings.display.show_cfg==nil then settings.display.show_cfg=false end
    if not settings.trust_set         then settings.trust_set={} end
    if not settings.map               then settings.map={visible=false,position='right',size=500} end
    if not settings.map.size          then settings.map.size=500 end
    settings.map.large=nil
    if settings.session.nav_sym  then NAV_SYM=settings.session.nav_sym end
    if settings.session.nav_font then NAV_FONT=settings.session.nav_font end
    state.minimized=settings.display.minimized
    state.map_visible=settings.map.visible
    state.px=settings.display.pos_x;state.py=settings.display.pos_y
    T.SZ=settings.display.font_size;T.SZ_H=T.SZ+1;T.ROW_H=T.SZ+6
    T.WIDTH=settings.display.width
    local z=zones[settings.session.last_zone]
    if z then state.zone=z
        for _,nm in ipairs(z.nms) do if nm.name==settings.session.last_nm then state.nm=nm;break end end
    end
    state.view=state.nm and 'nm_view' or 'zone_menu'
end

--==================================================================================================
-- INVENTORY  — named bag keys, exact invtracker pattern
--==================================================================================================
local function scan_bag(bag, max)
    if not bag or not max then return end
    for i=1,max do
        local item=bag[i]
        if item and item.id and item.id~=0 and item.id~=65535 then
            local info=res.items[item.id]
            if info and info.en then
                local n=info.en:lower()
                state.inv[n]=(state.inv[n] or 0)+(item.count or 1)
            end
        end
    end
end

local function refresh_inventory()
    state.inv={}
    local bags=windower.ffxi.get_items()
    if not bags then return end
    scan_bag(bags.inventory, bags.max_inventory)
    scan_bag(bags.satchel,   bags.max_satchel)
    scan_bag(bags.sack,      bags.max_sack)
    scan_bag(bags.case,      bags.max_case)
    scan_bag(bags.wardrobe,  bags.max_wardrobe)
    scan_bag(bags.wardrobe2, bags.max_wardrobe2)
    scan_bag(bags.wardrobe3, bags.max_wardrobe3)
    scan_bag(bags.wardrobe4, bags.max_wardrobe4)
end

local function refresh_key_items()
    state.ki={}
    local kl=windower.ffxi.get_key_items()
    if kl then for _,id in ipairs(kl) do state.ki[id]=true end end
end
local function get_count(name) return state.inv[name:lower()] or 0 end
local function has_ki(id) return id and id~=0 and state.ki[id]==true end

-- Per-zone label colors (muted, distinct)
local ZONE_MAP={
    ['tahrongi']  ={file='tahrongi',  iw=600,ih=600,gx0=77,gy0=76,gx1=521,gy1=528,nc=14,nr=14},
    ['latheine']  ={file='latheine',  iw=600,ih=600,gx0=77,gy0=76,gx1=521,gy1=528,nc=14,nr=14},
    ['konschtat'] ={file='konschtat', iw=600,ih=600,gx0=77,gy0=76,gx1=521,gy1=528,nc=14,nr=14},
    ['attohwa']   ={file='attohwa',   iw=600,ih=600,gx0=59,gy0=59,gx1=525,gy1=525,nc=13,nr=13},
    ['misareaux'] ={file='misareaux', iw=600,ih=600,gx0=59,gy0=59,gx1=525,gy1=525,nc=13,nr=13},
    ['vunkerl']   ={file='vunkerl',   iw=600,ih=600,gx0=59,gy0=59,gx1=525,gy1=525,nc=13,nr=13},
    ['grauberg']  ={file='grauberg',  iw=600,ih=600,gx0=59,gy0=59,gx1=525,gy1=525,nc=13,nr=13},
    ['altepa']    ={file='altepa',    iw=600,ih=600,gx0=59,gy0=59,gx1=525,gy1=525,nc=13,nr=13},
    ['uleguerand']={file='uleguerand',iw=600,ih=600,gx0=59,gy0=59,gx1=525,gy1=525,nc=13,nr=13},
}
local ZONE_TO_KEY={
    ['Abyssea - Tahrongi']  ='tahrongi',  ['Abyssea - La Theine'] ='latheine',
    ['Abyssea - Konschtat'] ='konschtat', ['Abyssea - Misareaux'] ='misareaux',
    ['Abyssea - Vunkerl']   ='vunkerl',   ['Abyssea - Attohwa']   ='attohwa',
    ['Abyssea - Grauberg']  ='grauberg',  ['Abyssea - Altepa']    ='altepa',
    ['Abyssea - Uleguerand']='uleguerand',
}

local ZONE_COLORS={
    ['Abyssea - Tahrongi'] ={160,210,185},
    ['Abyssea - La Theine']={140,175,220},
    ['Abyssea - Konschtat']={175,150,215},
    ['Abyssea - Misareaux']={215,170,125},
    ['Abyssea - Vunkerl']  ={130,205,215},
    ['Abyssea - Attohwa']  ={175,210,135},
    ['Abyssea - Grauberg'] ={215,150,170},
    ['Abyssea - Altepa']   ={220,195,120},
    ['Abyssea - Uleguerand']={180,165,225},
}

-- Color gradient: 0=grey, 1 jumps to 25% of gradient, 50=75% of gradient
-- Full gradient: 0%=grey(130,130,150) 50%=yellow(240,220,80) 100%=green(70,220,70)
local function drop_color(count)
    if count==0 then return {130,130,150} end
    -- Map count 1..50 to gradient t 0.25..0.75 (jump at 1, cap at 50)
    local t=0.25+math.min(count-1,49)/49*0.5
    local r,g,b
    if t<0.5 then
        local s=t*2
        r=math.floor(130+s*(240-130));g=math.floor(130+s*(220-130));b=math.floor(150+s*(80-150))
    else
        local s=(t-0.5)*2
        r=math.floor(240+s*(70-240));g=220;b=math.floor(80+s*(70-80))
    end
    return {r,g,b}
end

--==================================================================================================
-- PRIM / TEXT HELPERS
--==================================================================================================
local pidx=0
local function prim(x,y,w,h,a,r,g,b)
    pidx=pidx+1;local n='at_p'..pidx
    windower.prim.create(n);windower.prim.set_position(n,x,y)
    windower.prim.set_size(n,w,h);windower.prim.set_color(n,a,r,g,b)
    windower.prim.set_visibility(n,true);all_prims[#all_prims+1]=n;return n
end

local function checkbox(x,y,have)
    -- border
    pidx=pidx+1;local bn='at_p'..pidx
    windower.prim.create(bn);windower.prim.set_position(bn,x,y)
    windower.prim.set_size(bn,11,11);windower.prim.set_color(bn,230,190,190,190)
    windower.prim.set_visibility(bn,true);all_prims[#all_prims+1]=bn
    -- fill
    pidx=pidx+1;local fn='at_p'..pidx
    windower.prim.create(fn);windower.prim.set_position(fn,x+1,y+1)
    windower.prim.set_size(fn,9,9)
    if have then windower.prim.set_color(fn,235,35,185,35)
    else         windower.prim.set_color(fn,235,185,35,35) end
    windower.prim.set_visibility(fn,true);all_prims[#all_prims+1]=fn
    return fn
end

local tidx=0
local function txt(x,y,w,h,rgb,sz,bold,str,on_left,dtype,ref)
    tidx=tidx+1
    local obj=texts.new({
        pos={x=x,y=y},
        text={font=T.FONT,size=sz or T.SZ,red=rgb[1],green=rgb[2],blue=rgb[3],
              alpha=255,bold=bold or false,stroke={width=2,alpha=140,red=0,green=0,blue=0}},
        bg={alpha=0,visible=false},flags={draggable=false},padding=0,
    })
    obj:text(str or '');obj:show()
    all_texts[#all_texts+1]={obj=obj,dtype=dtype,ref=ref,fill_prim=nil}
    if on_left then hot_zones[#hot_zones+1]={x=x,y=y,w=w,h=h,fn=on_left} end
    return #all_texts
end

local function destroy_map()
    if map_ctx.created then
        pcall(windower.prim.delete, MAP_PRIM)
        pcall(windower.prim.delete, MAP_BORDER)
        map_ctx.created=false; map_ctx.loaded_key=nil; map_ctx.last_size=nil
    end
end

local function update_map_display()
    if not state.map_visible or not state.zone then
        if map_ctx.created then
            pcall(function() windower.prim.set_visibility(MAP_PRIM,   false) end)
            pcall(function() windower.prim.set_visibility(MAP_BORDER, false) end)
        end
        return
    end
    local zkey=ZONE_TO_KEY[state.zone.zone_name]
    local zm=zkey and ZONE_MAP[zkey]
    if not zm then return end
    local mpos=settings.map.position; local ms=settings.map.size
    local mw,mh=ms,ms
    local mx,my
    if     mpos=='right'  then mx=state.px+T.WIDTH+4; my=state.py
    elseif mpos=='left'   then mx=state.px-mw-4;      my=state.py
    elseif mpos=='bottom' then mx=state.px;            my=state.py+state.panel_h+4
    else                       mx=state.px;            my=state.py-mh-4 end
    if not map_ctx.created then
        windower.prim.create(MAP_BORDER)
        windower.prim.set_color(MAP_BORDER,240,8,8,15)
        windower.prim.create(MAP_PRIM)
        windower.prim.set_color(MAP_PRIM,255,255,255,255)
        map_ctx.created=true
    end
    windower.prim.set_position(MAP_BORDER, mx-2, my-2)
    windower.prim.set_size(MAP_BORDER, mw+4, mh+4)
    windower.prim.set_visibility(MAP_BORDER, true)
    windower.prim.set_position(MAP_PRIM, mx, my)
    windower.prim.set_visibility(MAP_PRIM, true)
    local size_changed=(map_ctx.last_size~=ms)
    if zkey~=map_ctx.loaded_key then
        map_ctx.loaded_key=zkey
        map_ctx.last_size=ms
        windower.prim.set_texture(MAP_PRIM, windower.addon_path..'maps/'..zm.file..'.bmp')
        windower.prim.set_size(MAP_PRIM, mw, mh)
        coroutine.schedule(function()
            pcall(function() windower.prim.set_size(MAP_PRIM,mw,mh) end)
        end, 0.15)
    elseif size_changed then
        map_ctx.last_size=ms
        windower.prim.set_size(MAP_PRIM, mw, mh)
    else
        windower.prim.set_size(MAP_PRIM, mw, mh)
    end
end

local function destroy_all()
    for _,n in ipairs(all_prims) do pcall(windower.prim.delete,n) end
    for _,t in ipairs(all_texts) do pcall(function() t.obj:destroy() end) end
    all_prims={};all_texts={};hot_zones={};pidx=0;tidx=0
end

--==================================================================================================
-- HELPERS — KI and readiness calculations
--==================================================================================================
local function chain_ki_status(nm)
    local kh,kt=0,0
    for _,e in ipairs(nm.chain) do
        if e.ki and e.ki.id and e.ki.id~=0 then
            kt=kt+1; if has_ki(e.ki.id) then kh=kh+1 end
        end
    end
    return kh,kt
end

local function zone_pop_status(zone)
    -- Returns ready,total where total = bosses that need KIs, ready = those with all KIs obtained
    local ready,total=0,0
    for _,nm in ipairs(zone.nms) do
        local kh,kt=chain_ki_status(nm)
        if kt>0 then  -- Only count bosses that require KIs (T4/T5); skip T2/T3 direct-pops
            total=total+1
            if kh==kt then ready=ready+1 end
        end
    end
    return ready,total
end

local function is_currency(name)
    -- Voyage/Balance/Ardor/Vision currencies drop from multiple bosses
    return name:find('Voyage') or name:find('Balance') or name:find('Ardor')
        or name:find('Vision') or name:find(' Coin') or name:find(' Stone')
        or name:find(' Card') or name:find(' Jewel')
end

--==================================================================================================
-- REFRESH DATA (no rebuild)
--==================================================================================================
local function refresh_data()
    for _,t in ipairs(all_texts) do
        local d=t.dtype
        if d=='item' and t.ref then
            local count=get_count(t.ref.name);local have=count>0
            local col=have and T.GREEN or T.RED
            t.obj:color(col[1],col[2],col[3])
            local src=t.ref.from and (' | '..t.ref.from) or ''
            if t.ref.from_pos then src=src..' ('..t.ref.from_pos..')' end
            t.obj:text(t.ref.name..' ('..count..')'..src)
            if t.fill_prim then
                if have then windower.prim.set_color(t.fill_prim,235,35,185,35)
                else         windower.prim.set_color(t.fill_prim,235,185,35,35) end
            end
        elseif d=='ki' and t.ref then
            local have=has_ki(t.ref.id)
            local col=have and T.GREEN or T.RED
            t.obj:color(col[1],col[2],col[3])
            if t.fill_prim then
                if have then windower.prim.set_color(t.fill_prim,235,35,185,35)
                else         windower.prim.set_color(t.fill_prim,235,185,35,35) end
            end
        elseif d=='farm' and t.ref then
            local count=get_count(t.ref.name)
            local col=drop_color(count)
            t.obj:color(col[1],col[2],col[3])
            t.obj:text(t.ref.name..' ('..count..')')
        elseif d=='ki_summary' and t.ref then
            local kh,kt=0,0
            for _,e in ipairs(t.ref.chain) do
                if e.ki and e.ki.id and e.ki.id~=0 then kt=kt+1;if has_ki(e.ki.id) then kh=kh+1 end end
            end
            t.obj:color((kh==kt and T.GREEN or T.RED)[1],(kh==kt and T.GREEN or T.RED)[2],(kh==kt and T.GREEN or T.RED)[3])
            t.obj:text('Pop KIs: '..kh..'/'..kt)
        end
    end
    update_dbg()
end

--==================================================================================================
-- BUILD UI
--==================================================================================================
local function build_ui()
    destroy_all()
    local px=state.px;local py=state.py;local pw=T.WIDTH;local cy=py

    -- BG created FIRST — renders behind everything
    local bg_prim=prim(px,py+T.HDR_H+T.TITLE_H,pw,2000,settings.display.bg_alpha,T.BG_R,T.BG_G,T.BG_B)

    -- Click shield: a draggable transparent texts object covering the whole panel.
    -- texts lib returns true for type==1 on draggable objects, blocking FFXI clicks.
    -- We position/resize it after we know panel height (see end of build_ui).
    -- Store ref so we can reposition it.
    if state.shield then pcall(function() state.shield:destroy() end) end
    state.shield = texts.new({
        pos={x=px, y=py},
        text={font=T.FONT,size=1,red=0,green=0,blue=0,alpha=0},
        bg={alpha=0,visible=false},
        flags={draggable=false},
        padding=0,
    })
    state.shield:text('')
    state.shield:show()
    all_texts[#all_texts+1]={obj=state.shield,dtype=nil,ref=nil,fill_prim=nil}

    -- TITLE ROW — full row is drag zone; text has no hotzone so prim catches all clicks
    prim(px,cy,pw,T.TITLE_H,T.HDR_A,T.HDR_R,T.HDR_G,T.HDR_B)
    local title_str='Abyssea Tracker'
    local title_sz=T.SZ_H+2
    local title_approx_w=math.floor(#title_str*title_sz*0.55)
    local title_x=px+math.floor((pw-title_approx_w)/2)
    txt(title_x,cy+2,title_approx_w+10,T.TITLE_H-2,T.GOLD,title_sz,true,title_str)
    -- no on_left → no hotzone → prim handles drag across entire title row
    cy=cy+T.TITLE_H

    -- NAV ROW
    prim(px,cy,pw,T.HDR_H,T.HDR_A,math.floor(T.HDR_R*0.7),math.floor(T.HDR_G*0.7),math.floor(T.HDR_B*0.7))
    local by=cy+math.floor((T.HDR_H-T.SZ)/2)-1
    local crumb=''
    if state.view=='zone_menu' then crumb='Select Zone'
    elseif state.view=='overview' then crumb='Drop Overview'
    elseif state.view=='plus1' then crumb='Drop Overview > Armor +1'
    elseif state.view=='plus2' then crumb='Drop Overview > Armor +2'
    elseif state.view=='drop_sources' then crumb='Sources: '..(state.drop_source_item or '?')
    elseif state.view=='chars' then crumb='Link Symbol Picker'
    elseif state.view=='nm_list' and state.zone then crumb=state.zone.zone_name:gsub('Abyssea %- ','')
    elseif state.view=='entity_view' and state.entity then
        crumb=(state.zone and state.zone.zone_name:gsub('Abyssea %- ','') or '')..' > '..state.entity.name
    elseif state.view=='nm_view' and state.zone and state.nm then
        crumb=state.zone.zone_name:gsub('Abyssea %- ','')..' > '..state.nm.name end
    txt(px+T.PAD_X,by,pw-180,T.HDR_H,T.WHITE,T.SZ,false,crumb,
        function()
            if state.view=='nm_view' then state.view='nm_list';state.nm=nil;state.show_footer=false;build_ui()
            elseif state.view=='entity_view' then state.view='nm_list';state.entity=nil;build_ui()
            elseif state.view=='nm_list' then state.view='zone_menu';state.zone=nil;build_ui()
            elseif state.view=='drop_sources' then state.view=state.drop_source_back or 'overview';state.drop_source_item=nil;build_ui()
            elseif state.view=='plus1' or state.view=='plus2' then state.view='overview';build_ui()
            elseif state.view=='chars' then state.view='zone_menu';build_ui()
            elseif state.view=='overview' then state.view='zone_menu';build_ui() end
        end)
    local vlbl=(settings.session.last_view=='tree') and '[Tree]' or '[List]'
    txt(px+pw-158,by,48,T.HDR_H,T.BLUE,T.SZ,false,vlbl,
        function() settings.session.last_view=(settings.session.last_view=='tree') and 'list' or 'tree';save_settings();build_ui() end)
    local map_col=state.map_visible and {80,220,200} or {130,130,150}
    txt(px+pw-106,by,40,T.HDR_H,map_col,T.SZ,true,'[Map]',
        function()
            state.map_visible=not state.map_visible
            if not state.map_visible then destroy_map() end
            save_settings();build_ui()
        end)
    local cfg_col=settings.display.show_cfg and T.YELLOW or T.GREY
    txt(px+pw-62,by,36,T.HDR_H,cfg_col,T.SZ,false,'[Cfg]',
        function() settings.display.show_cfg=not settings.display.show_cfg;save_settings();build_ui() end)
    txt(px+pw-22,by,20,T.HDR_H,T.GREY,T.SZ,false,state.minimized and '[+]' or '[-]',
        function()
            state.minimized=not state.minimized
            if state.minimized then
                pcall(function() windower.prim.set_visibility(MAP_PRIM,false) end)
                pcall(function() windower.prim.set_visibility(MAP_BORDER,false) end)
            end
            save_settings();build_ui()
        end)
    cy=cy+T.HDR_H

    if state.minimized then
        windower.prim.set_size(bg_prim,pw,2);windower.prim.set_position(bg_prim,px,cy)
        state.panel_h=T.HDR_H+T.TITLE_H+2;return
    end

    local content_start=cy;cy=cy+T.PAD_Y

    -- nav_link: renders symbol in NAV_FONT + label in Tahoma, both clickable
    local function nav_link(x,y,w,h,col,label,fn)
        local sym_w=math.floor(T.SZ*1.6)
        -- Register full-width hotzone FIRST so it's checked before any txt hotzones
        if fn then hot_zones[#hot_zones+1]={x=x,y=y,w=w,h=h,fn=fn} end
        -- Symbol in NAV_FONT (no hotzone)
        tidx=tidx+1
        local sobj=texts.new({
            pos={x=x,y=y},
            text={font=NAV_FONT,size=T.SZ,red=col[1],green=col[2],blue=col[3],
                  alpha=255,bold=false,stroke={width=2,alpha=140,red=0,green=0,blue=0}},
            bg={alpha=0,visible=false},flags={draggable=false},padding=0,
        })
        sobj:text(NAV_SYM);sobj:show()
        all_texts[#all_texts+1]={obj=sobj,dtype=nil,ref=nil,fill_prim=nil}
        -- Label in Tahoma (nil fn — hotzone already registered above)
        txt(x+sym_w+2,y,w-sym_w-2,h,col,T.SZ,false,label,nil)
    end

    -- HELPERS
    local function sep() prim(px,cy,pw,1,T.SEP_A,T.SEP_R,T.SEP_G,T.SEP_B);cy=cy+5 end
    local function sec_hdr(lbl) txt(px+T.PAD_X,cy,pw,T.ROW_H,T.GOLD,T.SZ,true,lbl);cy=cy+T.ROW_H end
    local function hovbg(x,y,w,h) prim(x-2,y,w+2,h,T.HOV_A,T.HOV_R,T.HOV_G,T.HOV_B) end

    -- CFG block
    if settings.display.show_cfg then
        prim(px,cy,pw,T.ROW_H*5+16,T.CFG_A,T.CFG_R,T.CFG_G,T.CFG_B)
        txt(px+T.PAD_X,cy+2,pw*0.45,T.ROW_H,T.GOLD,T.SZ,true,'Settings')
        txt(px+pw*0.5,cy+2,pw*0.5,T.ROW_H,T.GREY,T.SZ,false,'Scroll shortcuts:')
        cy=cy+T.ROW_H
        txt(px+T.PAD_X,cy,90,T.ROW_H,T.WHITE,T.SZ,false,'Opacity: '..settings.display.bg_alpha)
        txt(px+T.PAD_X+100,cy,24,T.ROW_H,T.GREEN,T.SZ,true,'[+]',function() settings.display.bg_alpha=math.min(245,settings.display.bg_alpha+20);save_settings();build_ui() end)
        txt(px+T.PAD_X+126,cy,24,T.ROW_H,T.RED,T.SZ,true,'[-]',function() settings.display.bg_alpha=math.max(20,settings.display.bg_alpha-20);save_settings();build_ui() end)
        txt(px+pw*0.5,cy,pw*0.5,T.ROW_H,T.GREY,T.SZ,false,'Scroll = Opacity')
        cy=cy+T.ROW_H
        txt(px+T.PAD_X,cy,90,T.ROW_H,T.WHITE,T.SZ,false,'Font sz: '..T.SZ)
        txt(px+T.PAD_X+100,cy,24,T.ROW_H,T.GREEN,T.SZ,true,'[+]',function() settings.display.font_size=math.min(16,settings.display.font_size+1);T.SZ=settings.display.font_size;T.SZ_H=T.SZ+1;T.ROW_H=T.SZ+6;save_settings();build_ui() end)
        txt(px+T.PAD_X+126,cy,24,T.ROW_H,T.RED,T.SZ,true,'[-]',function() settings.display.font_size=math.max(8,settings.display.font_size-1);T.SZ=settings.display.font_size;T.SZ_H=T.SZ+1;T.ROW_H=T.SZ+6;save_settings();build_ui() end)
        txt(px+pw*0.5,cy,pw*0.5,T.ROW_H,T.GREY,T.SZ,false,'Alt+Scroll = Font Size')
        cy=cy+T.ROW_H
        txt(px+T.PAD_X,cy,90,T.ROW_H,T.WHITE,T.SZ,false,'Width: '..T.WIDTH)
        txt(px+T.PAD_X+100,cy,24,T.ROW_H,T.GREEN,T.SZ,true,'[+]',function() T.WIDTH=math.min(600,T.WIDTH+20);save_settings();build_ui() end)
        txt(px+T.PAD_X+126,cy,24,T.ROW_H,T.RED,T.SZ,true,'[-]',function() T.WIDTH=math.max(300,T.WIDTH-20);save_settings();build_ui() end)
        txt(px+pw*0.5,cy,pw*0.5,T.ROW_H,T.GREY,T.SZ,false,'Ctrl+Scroll = Width')
        cy=cy+T.ROW_H
        local map_pos=settings.map and settings.map.position or 'right'
        local map_sz =settings.map and settings.map.size   or 500
        txt(px+T.PAD_X,cy,90,T.ROW_H,T.WHITE,T.SZ,false,'Map pos: '..map_pos)
        txt(px+T.PAD_X+100,cy,52,T.ROW_H,{80,220,200},T.SZ,true,'[pos]',
            function()
                local p={['right']='bottom',['bottom']='left',['left']='top',['top']='right'}
                settings.map.position=p[settings.map.position] or 'right'
                save_settings();update_map_display()
            end)
        cy=cy+T.ROW_H
        txt(px+T.PAD_X,cy,90,T.ROW_H,T.WHITE,T.SZ,false,'Map sz: '..map_sz..'px')
        txt(px+T.PAD_X+100,cy,24,T.ROW_H,T.GREEN,T.SZ,true,'[+]',function() settings.map.size=math.min(1000,settings.map.size+50);map_ctx.last_size=nil;save_settings();update_map_display() end)
        txt(px+T.PAD_X+126,cy,24,T.ROW_H,T.RED,T.SZ,true,'[-]',function() settings.map.size=math.max(100,settings.map.size-50);map_ctx.last_size=nil;save_settings();update_map_display() end)
        txt(px+pw*0.5,cy,pw*0.5,T.ROW_H,T.GREY,T.SZ,false,'Shift+Scroll')
        cy=cy+T.ROW_H+4;sep()
    end

    -- ITEM ROW
    local function item_row(item,indent)
        indent=indent or 0
        local count=get_count(item.name);local have=count>0
        local fp=checkbox(px+T.PAD_X+indent,cy+3,have)
        local col=have and T.GREEN or T.RED
        local src=item.from and (' | '..item.from) or ''
        if item.from_pos then src=src..' ('..item.from_pos..')' end
        local idx=txt(px+T.PAD_X+14+indent,cy,pw-T.PAD_X-14-indent-4,T.ROW_H,
                      col,T.SZ,false,item.name..' ('..count..')'..src,nil,'item',item)
        all_texts[idx].fill_prim=fp;cy=cy+T.ROW_H
    end

    -- INFO FOOTER BUILDER
    local function show_info_footer(entry_nm, entry_atma)
        -- Show atma effects from db, then trust set with summon button
        sep()
        prim(px,cy,pw,T.ROW_H+2,T.FTR_A,T.FTR_R,T.FTR_G,T.FTR_B)
        txt(px+T.PAD_X,cy+1,pw,T.ROW_H,T.GOLD,T.SZ,true,'-- '..entry_nm..' --');cy=cy+T.ROW_H+2

        -- Atma effects
        local atma_names = entry_atma or {}
        if #atma_names > 0 then
            txt(px+T.PAD_X,cy,pw,T.ROW_H,T.YELLOW,T.SZ,true,'Atma:');cy=cy+T.ROW_H
            for _,aname in ipairs(atma_names) do
                -- Strip leading descriptive text before em dash if any
                local clean=aname:match('^(.-)%s*%-%-') or aname:match('^(.-)%s*$') or aname
                txt(px+T.PAD_X+4,cy,pw-T.PAD_X-8,T.ROW_H,T.WHITE,T.SZ,true,clean);cy=cy+T.ROW_H
                local db=atma_db[clean]
                if db then
                    for _,eff in ipairs(db.effects) do
                        txt(px+T.PAD_X+14,cy,pw-T.PAD_X-18,T.ROW_H,T.LTBLUE,T.SZ,false,eff);cy=cy+T.ROW_H
                    end
                end
            end
        end

        -- Trust set
        local tset=settings.trust_set[entry_nm]
        txt(px+T.PAD_X,cy,pw,T.ROW_H,T.YELLOW,T.SZ,true,'Trust Set:');cy=cy+T.ROW_H
        if tset and tset~='' then
            local nm_copy=entry_nm
            hovbg(px+T.PAD_X,cy,pw-T.PAD_X,T.ROW_H)
            txt(px+T.PAD_X+4,cy,pw-T.PAD_X-60,T.ROW_H,T.WHITE,T.SZ,false,tset)
            txt(px+pw-56,cy,50,T.ROW_H,T.CYAN,T.SZ,true,'[Summon]',
                function()
                    windower.send_command('input /console trust recall '..tset)
                end)
            cy=cy+T.ROW_H
        else
            txt(px+T.PAD_X+4,cy,pw-T.PAD_X-8,T.ROW_H,T.GREY,T.SZ,false,
                'Not set — use: //at trust set '..entry_nm..' <setname>');cy=cy+T.ROW_H
        end
        sep()
    end

    -- CHAIN ENTRY
    local function chain_entry(entry, is_top)
        local ki_name=entry.ki and entry.ki.name or ''
        local nm_copy=entry.nm
        local is_active_footer=(state.show_footer and state.footer_entry==nm_copy)

        -- Info button callback (shared)
        local function toggle_info()
            if state.footer_entry==nm_copy and state.show_footer then
                state.show_footer=false;state.footer_entry=nil
            else
                state.footer_entry=nm_copy;state.show_footer=true
            end
            build_ui()
        end

        if entry.timed then
            -- TIMED: single line — [checkbox] NM (pos) → KI name
            -- No expand, no separate KI line, no notes
            local have_ki=has_ki(entry.ki and entry.ki.id)
            local fp=checkbox(px+T.PAD_X,cy+3,have_ki)
            local ki_col=have_ki and T.GREEN or T.RED
            local ki_ref=entry.ki and {id=entry.ki.id,name=entry.ki.name} or nil
            local lbl=entry.nm..' ('..(entry.pos or '?')..') >> '..ki_name
            local line_w=pw-T.PAD_X-14-(is_top and 50 or 4)
            local idx=txt(px+T.PAD_X+14,cy,line_w,T.ROW_H,ki_col,T.SZ,false,lbl,nil,'ki',ki_ref)
            if ki_ref then all_texts[idx].fill_prim=fp end
            if is_top then
                txt(px+pw-46,cy,40,T.ROW_H,is_active_footer and T.YELLOW or T.GREY,T.SZ,false,'[Info]',toggle_info)
            end
            cy=cy+T.ROW_H

        else
            -- ITEM POP: expandable with [-]/[+] checkbox inline
            local collapsed=settings.collapse[nm_copy]
            local have_ki=has_ki(entry.ki and entry.ki.id)
            local arrow_col=have_ki and T.GREEN or T.RED
            local arrow=(collapsed and '[+] ' or '[-] ')
            local ki_ref=entry.ki and {id=entry.ki.id,name=entry.ki.name} or nil

            -- NMH prim FIRST (renders below checkboxes)
            -- Checkbox AFTER prim (renders on top of it)
            local fp=checkbox(px+T.PAD_X,cy+3,have_ki)
            -- Arrow text (colored green/red for KI status)
            local arr_idx=txt(px+T.PAD_X+14,cy,20,T.ROW_H,arrow_col,T.SZ,true,arrow,
                function()
                    settings.collapse[nm_copy]=not settings.collapse[nm_copy]
                    save_settings();build_ui()
                end,'ki',ki_ref)
            if ki_ref then all_texts[arr_idx].fill_prim=fp end
            -- NM name → KI name — dtype='ki' so refresh_data keeps color in sync with arrow
            local lbl=entry.nm..' ('..(entry.pos or '?')..') >> '..ki_name
            local lbl_w=pw-T.PAD_X-14-20-(is_top and 50 or 4)
            txt(px+T.PAD_X+14+20,cy,lbl_w,T.ROW_H,arrow_col,T.SZ,true,lbl,
                function()
                    settings.collapse[nm_copy]=not settings.collapse[nm_copy]
                    save_settings();build_ui()
                end,'ki',ki_ref)
            if is_top then
                txt(px+pw-46,cy,40,T.ROW_H,is_active_footer and T.YELLOW or T.GREY,T.SZ,false,'[Info]',toggle_info)
            end
            cy=cy+T.ROW_H

            if not collapsed then
                if entry.pop_items then
                    for _,it in ipairs(entry.pop_items) do
                        item_row(it,14)
                        if it.pop_items then
                            for _,sub in ipairs(it.pop_items) do
                                item_row(sub,26)
                                if sub.pop_items then
                                    for _,ss in ipairs(sub.pop_items) do item_row(ss,38) end
                                end
                            end
                        end
                    end
                end
                cy=cy+2
            end
        end

        -- Info footer right after this entry if active
        if is_active_footer then
            local atma_data=settings.atma[nm_copy]
            -- Look up atma in parent nm if not overridden
            if not atma_data and state.nm then
                atma_data=state.nm.atma
            end
            show_info_footer(nm_copy, atma_data)
        end
    end

    -- VIEWS
    if state.view=='zone_menu' then
        -- Overview button
        hovbg(px+T.PAD_X+4,cy,pw-T.PAD_X-4,T.ROW_H)
        nav_link(px+T.PAD_X+8,cy,pw-T.PAD_X-8,T.ROW_H,T.CYAN,'Drop Overview',
            function() state.view='overview';build_ui() end)
        cy=cy+T.ROW_H+4; sep()
        local groups={
            {'Vision of Abyssea',{'Abyssea - La Theine','Abyssea - Konschtat','Abyssea - Tahrongi'}},
            {'Scars of Abyssea', {'Abyssea - Misareaux','Abyssea - Vunkerl','Abyssea - Attohwa'}},
            {'Heroes of Abyssea',{'Abyssea - Grauberg','Abyssea - Altepa','Abyssea - Uleguerand'}},
        }
        for _,grp in ipairs(groups) do
            sec_hdr(grp[1])
            for _,zn in ipairs(grp[2]) do
                local zname=zn; local short=zn:gsub('Abyssea %- ','')
                local z=zones[zname]
                local ready,total=0,0
                if z then ready,total=zone_pop_status(z) end
                local rc=(total>0 and ready==total) and T.GREEN or (ready>0 and T.YELLOW or T.RED)
                hovbg(px+T.PAD_X+4,cy,pw-T.PAD_X-4,T.ROW_H)
                nav_link(px+T.PAD_X+8,cy,pw-T.PAD_X-70,T.ROW_H,T.ORANGE,short,
                    function() state.zone=zones[zname];state.view='nm_list';build_ui() end)
                if total>0 then
                    txt(px+pw-64,cy,58,T.ROW_H,rc,T.SZ,true,'['..ready..'/'..total..' pop]',
                        function() state.zone=zones[zname];state.view='nm_list';build_ui() end)
                end
                cy=cy+T.ROW_H
            end;cy=cy+3
        end

    elseif state.view=='overview' then
        -- ── shared helpers used by multiple views ─────────────────────────────
        local zone_order={'Abyssea - Tahrongi','Abyssea - La Theine','Abyssea - Konschtat',
                          'Abyssea - Misareaux','Abyssea - Vunkerl','Abyssea - Attohwa',
                          'Abyssea - Grauberg','Abyssea - Altepa','Abyssea - Uleguerand'}

        sec_hdr('Boss Drops — All Zones')
        local trial_rows={}; local seen_trial={}
        for _,zn in ipairs(zone_order) do
            local z=zones[zn]
            if z then
                local zs=zn:gsub('Abyssea %- ','')
                for _,nm in ipairs(z.nms) do
                    for _,gd in ipairs(nm.goal_drops or {}) do
                        if gd.name~='TBD' and not is_currency(gd.name) then
                            local key=gd.name..'|'..zs..'|'..nm.name
                            if not seen_trial[key] then
                                seen_trial[key]=true
                                trial_rows[#trial_rows+1]={name=gd.name,zone=zs,nm=nm.name,zfull=zn}
                            end
                        end
                    end
                end
            end
        end
        local hw=math.floor(pw*0.5)-T.PAD_X
        for _,row in ipairs(trial_rows) do
            local count=get_count(row.name)
            local zcol=ZONE_COLORS[row.zfull] or T.GREY
            local icol=drop_color(count)
            local zfull=row.zfull; local nm_name=row.nm; local iname=row.name
            hovbg(px+T.PAD_X,cy,pw-T.PAD_X,T.ROW_H)
            txt(px+T.PAD_X,cy,hw,T.ROW_H,zcol,T.SZ,false,row.zone..' | '..nm_name,
                function()
                    state.zone=zones[zfull]
                    if state.zone then
                        for _,n in ipairs(state.zone.nms) do
                            if n.name==nm_name then state.nm=n;state.view='nm_view';save_settings();build_ui();return end
                        end
                    end
                end)
            txt(px+T.PAD_X+hw,cy,pw-T.PAD_X-hw-4,T.ROW_H,icol,T.SZ,true,
                iname..' ('..count..')',
                function()
                    state.drop_source_item=iname;state.drop_source_back='overview';state.view='drop_sources';build_ui()
                end,'farm',{name=iname,type='item'})
            cy=cy+T.ROW_H
        end
        cy=cy+T.PAD_Y;sep()
        hovbg(px+T.PAD_X,cy,pw-T.PAD_X,T.ROW_H)
        nav_link(px+T.PAD_X,cy,pw-T.PAD_X,T.ROW_H,T.CYAN,'Empyrean Armor +1',
            function() state.view='plus1';build_ui() end)
        cy=cy+T.ROW_H
        hovbg(px+T.PAD_X,cy,pw-T.PAD_X,T.ROW_H)
        nav_link(px+T.PAD_X,cy,pw-T.PAD_X,T.ROW_H,T.CYAN,'Empyrean Armor +2',
            function() state.view='plus2';build_ui() end)
        cy=cy+T.ROW_H

    elseif state.view=='plus1' then
        -- ── EMPYREAN ARMOR +1 — seal tracking by job ─────────────────────────
        if not drops_db or not drops_db.seals then load_drops_db() end
        local db_seals=drops_db and drops_db.seals or {}
        local job_order=drops_db and drops_db.job_display_order or {}
        -- Filter to jobs that have at least one seal entry
        local jobs_with_seals={}; local jobs_seen={}
        for _,jb in ipairs(job_order) do
            for _,s in ipairs(db_seals) do
                if s.job==jb and not jobs_seen[jb] then
                    jobs_seen[jb]=true; jobs_with_seals[#jobs_with_seals+1]=jb; break
                end
            end
        end
        -- Fallback: collect any jobs not in job_order
        for _,s in ipairs(db_seals) do
            if not jobs_seen[s.job] then
                jobs_seen[s.job]=true; jobs_with_seals[#jobs_with_seals+1]=s.job
            end
        end
        -- Active job tab
        if not state.active_job or not jobs_seen[state.active_job] then
            state.active_job=jobs_with_seals[1]
        end
        -- Job tab row
        local tab_w=math.floor((pw-T.PAD_X*2)/math.min(#jobs_with_seals,10))
        local tabs_per_row=math.floor((pw-T.PAD_X*2)/tab_w)
        local row1={}; local row2={}
        for i,jb in ipairs(jobs_with_seals) do
            if i<=tabs_per_row then row1[#row1+1]=jb else row2[#row2+1]=jb end
        end
        prim(px,cy,pw,T.ROW_H+2,T.HDR_A,T.HDR_R,T.HDR_G,T.HDR_B)
        for i,jb in ipairs(row1) do
            local jcol=(jb==state.active_job) and T.YELLOW or T.GREY
            local jb_cap=jb
            txt(px+T.PAD_X+(i-1)*tab_w,cy,tab_w,T.ROW_H,jcol,T.SZ,true,'['..jb..']',
                function() state.active_job=jb_cap;build_ui() end)
        end
        cy=cy+T.ROW_H+2
        if #row2>0 then
            prim(px,cy,pw,T.ROW_H+2,T.HDR_A,T.HDR_R,T.HDR_G,T.HDR_B)
            for i,jb in ipairs(row2) do
                local jcol=(jb==state.active_job) and T.YELLOW or T.GREY
                local jb_cap=jb
                txt(px+T.PAD_X+(i-1)*tab_w,cy,tab_w,T.ROW_H,jcol,T.SZ,true,'['..jb..']',
                    function() state.active_job=jb_cap;build_ui() end)
            end
            cy=cy+T.ROW_H+2
        end
        sep()
        -- Seal rows for active job, in slot order
        local slot_order={'Head','Body','Hands','Legs','Feet'}
        local col1=math.floor(pw*0.22); local col2=pw-T.PAD_X-col1-4
        for _,slot in ipairs(slot_order) do
            for _,s in ipairs(db_seals) do
                if s.job==state.active_job and s.slot==slot then
                    local count=get_count(s.name)
                    local icol=drop_color(count)
                    local iname=s.name
                    hovbg(px+T.PAD_X,cy,pw-T.PAD_X,T.ROW_H)
                    txt(px+T.PAD_X,cy,col1,T.ROW_H,T.GREY,T.SZ,false,slot)
                    txt(px+T.PAD_X+col1,cy,col2,T.ROW_H,icol,T.SZ,true,
                        s.name..' ('..count..')',
                        function()
                            state.drop_source_item=iname;state.drop_source_back='plus1';state.view='drop_sources';build_ui()
                        end,'farm',{name=s.name,type='item'})
                    cy=cy+T.ROW_H
                    break
                end
            end
        end

    elseif state.view=='plus2' then
        -- ── EMPYREAN ARMOR +2 — currency tracking ─────────────────────────────
        if not drops_db or not drops_db.currencies then load_drops_db() end
        local db_currencies=drops_db and drops_db.currencies or {}
        local col_w=math.floor(pw/2)-T.PAD_X
        local lx=px+T.PAD_X; local rx=px+T.PAD_X+col_w+4
        local left_series={}; local right_series={}
        for i,ser in ipairs(db_currencies) do
            if i%2==1 then left_series[#left_series+1]=ser
            else right_series[#right_series+1]=ser end
        end
        local function render_currency_col(series_list, start_x, cy_ref)
            local c=cy_ref
            for _,ser in ipairs(series_list) do
                txt(start_x,c,col_w,T.ROW_H,T.YELLOW,T.SZ,true,ser.series); c=c+T.ROW_H
                for _,itm in ipairs(ser.items or {}) do
                    local iname=type(itm)=='table' and itm.name or itm
                    local count=get_count(iname)
                    local iname_cap=iname
                    txt(start_x+10,c,col_w-10,T.ROW_H,drop_color(count),T.SZ,false,
                        iname..' ('..count..')',
                        function()
                            state.drop_source_item=iname_cap;state.drop_source_back='plus2';state.view='drop_sources';build_ui()
                        end,'farm',{name=iname,type='item'})
                    c=c+T.ROW_H
                end
                c=c+4
            end
            return c
        end
        local cy_l=render_currency_col(left_series,lx,cy)
        local cy_r=render_currency_col(right_series,rx,cy)
        cy=math.max(cy_l,cy_r)

    elseif state.view=='drop_sources' and state.drop_source_item then
        -- ── DROP SOURCES — all NMs that drop this item ────────────────────────
        if not drops_db or not drops_db.seals then load_drops_db() end
        local iname=state.drop_source_item
        sec_hdr('Sources: '..iname)
        sep()

        -- Helper: navigate to an NM by searching all zones
        local function go_entity_any(nm_name, preferred_zone)
            -- Try preferred zone first
            local function try_zone(zn)
                local z=zones[zn]; if not z then return false end
                local ok,flat,rev=pcall(build_zone_index,z)
                if not ok then return false end
                for _,ent in ipairs(flat) do
                    if ent.name==nm_name then
                        state.zone=z
                        if ent.kind=='boss' then state.nm=ent.ref;state.view='nm_view'
                        else state.entity=ent;state.entity_rev=rev;state.view='entity_view' end
                        save_settings();build_ui();return true
                    end
                end
                return false
            end
            if preferred_zone and try_zone(preferred_zone) then return end
            local all_zones={'Abyssea - Tahrongi','Abyssea - La Theine','Abyssea - Konschtat',
                             'Abyssea - Misareaux','Abyssea - Vunkerl','Abyssea - Attohwa',
                             'Abyssea - Grauberg','Abyssea - Altepa','Abyssea - Uleguerand'}
            for _,zn in ipairs(all_zones) do
                if zn~=preferred_zone and try_zone(zn) then return end
            end
        end

        -- Collect sources from seals, currencies, trinkets, goal_drops
        local sources={}; local seen_src={}
        local function add_src(nm_name, zone_name)
            local k=zone_name..'|'..nm_name
            if not seen_src[k] then seen_src[k]=true
                sources[#sources+1]={zone=zone_name,nm=nm_name} end
        end
        -- Seals
        for _,s in ipairs(drops_db and drops_db.seals or {}) do
            if s.name==iname then
                for _,src in ipairs(s.nms or {}) do add_src(src.nm,src.zone) end
            end
        end
        -- Currencies (new per-item nms format)
        for _,ser in ipairs(drops_db and drops_db.currencies or {}) do
            for _,itm in ipairs(ser.items or {}) do
                if type(itm)=='table' and itm.name==iname then
                    for _,src in ipairs(itm.nms or {}) do add_src(src.nm,src.zone) end
                end
            end
        end
        -- Goal drops in all zone files
        local all_zones={'Abyssea - Tahrongi','Abyssea - La Theine','Abyssea - Konschtat',
                         'Abyssea - Misareaux','Abyssea - Vunkerl','Abyssea - Attohwa',
                         'Abyssea - Grauberg','Abyssea - Altepa','Abyssea - Uleguerand'}
        for _,zn in ipairs(all_zones) do
            local z=zones[zn]; if z then
                for _,nm in ipairs(z.nms) do
                    for _,gd in ipairs(nm.goal_drops or {}) do
                        if gd.name==iname then add_src(nm.name,zn) end
                    end
                end
            end
        end

        if #sources==0 then
            txt(px+T.PAD_X,cy,pw,T.ROW_H,T.GREY,T.SZ,false,'No sources found in data.');cy=cy+T.ROW_H
        else
            local hw=math.floor(pw*0.55)-T.PAD_X
            for _,src in ipairs(sources) do
                local zshort=src.zone:gsub('Abyssea %- ','')
                local zcol=ZONE_COLORS[src.zone] or T.GREY
                local zn_cap=src.zone; local nm_cap=src.nm
                local fn_go=function() go_entity_any(nm_cap,zn_cap) end
                hovbg(px+T.PAD_X,cy,pw-T.PAD_X,T.ROW_H)
                -- Full-row hotzone first so entire line is clickable
                hot_zones[#hot_zones+1]={x=px+T.PAD_X,y=cy,w=pw-T.PAD_X,h=T.ROW_H,fn=fn_go}
                -- NM label in Tahoma (nil fn — hotzone already registered above)
                txt(px+T.PAD_X,cy,hw,T.ROW_H,zcol,T.SZ,false,zshort..' | '..src.nm,nil)
                -- Symbol in NAV_FONT (decorative, no separate hotzone)
                tidx=tidx+1
                local sobj=texts.new({pos={x=px+T.PAD_X+hw,y=cy},
                    text={font=NAV_FONT,size=T.SZ,red=T.CYAN[1],green=T.CYAN[2],blue=T.CYAN[3],
                          alpha=255,bold=true,stroke={width=2,alpha=140,red=0,green=0,blue=0}},
                    bg={alpha=0,visible=false},flags={draggable=false},padding=0})
                sobj:text(NAV_SYM);sobj:show()
                all_texts[#all_texts+1]={obj=sobj,dtype=nil,ref=nil,fill_prim=nil}
                cy=cy+T.ROW_H
            end
        end

    elseif state.view=='chars' then
        -- ── CHAR PICKER — full printable spectrum in chosen font ──────────────
        local pick_font=state.chars_font or 'Wingdings'
        sec_hdr('Pick Link Symbol  ['..pick_font..']');sep()
        txt(px+T.PAD_X,cy,pw,T.ROW_H,T.YELLOW,T.SZ,false,
            'Selected: '..NAV_SYM..'   preview: '..NAV_SYM..' Armor +1   Zone | NM  '..NAV_SYM)
        cy=cy+T.ROW_H;sep()

        local cell_w=18
        local cols=math.floor((pw-T.PAD_X*2)/cell_w)
        local col_i=0; local row_y=cy

        local function add_char(c)
            local cx_pos=px+T.PAD_X+col_i*cell_w
            local is_sel=(c==NAV_SYM and pick_font==(state.chars_font or 'Wingdings'))
            if is_sel then prim(cx_pos-1,row_y,cell_w,T.ROW_H,220,40,140,40)
            else hovbg(cx_pos,row_y,cell_w,T.ROW_H) end
            local col=is_sel and T.GREEN or T.CYAN
            local cap=c; local fnt=pick_font
            -- Create text object directly with chosen font
            tidx=tidx+1
            local obj=texts.new({
                pos={x=cx_pos+1,y=row_y},
                text={font=fnt,size=T.SZ,red=col[1],green=col[2],blue=col[3],
                      alpha=255,bold=is_sel,stroke={width=2,alpha=140,red=0,green=0,blue=0}},
                bg={alpha=0,visible=false},flags={draggable=false},padding=0,
            })
            obj:text(c);obj:show()
            all_texts[#all_texts+1]={obj=obj,dtype=nil,ref=nil,fill_prim=nil}
            hot_zones[#hot_zones+1]={x=cx_pos,y=row_y,w=cell_w,h=T.ROW_H,fn=function()
                NAV_SYM=cap
                NAV_FONT=fnt
                settings.session.nav_sym=NAV_SYM
                settings.session.nav_font=NAV_FONT
                config.save(settings)
                build_ui()
            end}
            col_i=col_i+1
            if col_i>=cols then col_i=0;row_y=row_y+T.ROW_H end
        end

        local function section(lbl)
            if col_i>0 then row_y=row_y+T.ROW_H;col_i=0 end
            txt(px+T.PAD_X,row_y,pw,T.ROW_H,T.GOLD,T.SZ,true,lbl)
            row_y=row_y+T.ROW_H
        end

        section('ASCII (33-126)')
        for i=33,126 do add_char(string.char(i)) end
        section('Latin-1 (160-255)')
        for i=160,255 do add_char(string.char(i)) end
        if col_i>0 then row_y=row_y+T.ROW_H end
        cy=row_y+4;sep()

        -- Font switcher row
        txt(px+T.PAD_X,cy,pw,T.ROW_H,T.GOLD,T.SZ,true,'Fonts:')
        cy=cy+T.ROW_H
        local fonts={'Wingdings','Wingdings 2','Wingdings 3','Webdings',
                     'Segoe UI Symbol','Arial Unicode MS','Lucida Sans Unicode','Tahoma'}
        local fw=math.floor((pw-T.PAD_X*2)/#fonts)
        for i,f in ipairs(fonts) do
            local is_cur=(f==pick_font)
            local fx=px+T.PAD_X+(i-1)*fw
            if is_cur then prim(fx-1,cy,fw,T.ROW_H,180,60,100,180)
            else hovbg(fx,cy,fw,T.ROW_H) end
            local fc=is_cur and T.YELLOW or T.GREY
            local fcap=f
            txt(fx+2,cy,fw-4,T.ROW_H,fc,T.SZ-1,is_cur,
                f:gsub(' .*',''):sub(1,8),  -- abbreviated label in Tahoma
                function() state.chars_font=fcap;build_ui() end)
        end
        cy=cy+T.ROW_H

    elseif state.view=='nm_list' and state.zone then
        sec_hdr(state.zone.zone_name);sep()
        local ok_idx,flat,rev
        ok_idx,flat,rev=pcall(build_zone_index,state.zone)
        if not ok_idx then
            -- flat contains the error message when pcall fails
            txt(px+T.PAD_X,cy,pw,T.ROW_H,T.RED,T.SZ,false,'Index error: '..(tostring(flat) or '?'))
            cy=cy+T.ROW_H
        else
            local cur_tier=nil
            for _,ent in ipairs(flat) do
            -- Empty separator row between tier groups
            if cur_tier and ent.tier~=cur_tier then
                cy=cy+T.ROW_H
            end
            cur_tier=ent.tier
            local tcol=TIER_COL[ent.tier] or T.GREY
            local tlbl=TIER_LBL[ent.tier] or '??'
            -- KI status for boss NMs
            local suffix=''
            local suffix_col=T.RED
            if ent.kind=='boss' and ent.ref and ent.ref.chain then
                local kh,kt=chain_ki_status(ent.ref)
                if kt>0 then
                    suffix=' ['..kh..'/'..kt..' KI]'
                    if kh==kt then suffix_col=T.GREEN
                    elseif kh>0 then suffix_col=T.YELLOW
                    else suffix_col=T.RED end
                end
            end
            local pos_str=ent.pos and (' ('..ent.pos..')') or ''
            -- Append conflux # for boss NMs
            local cflx_str=''
            if ent.kind=='boss' and ent.ref then
                local cnum=settings.conflux[ent.name] or ent.ref.conflux
                if cnum then cflx_str=' #'..cnum end
            end
            local ent_ref=ent
            hovbg(px+T.PAD_X,cy,pw-T.PAD_X,T.ROW_H)
            -- Tier label
            txt(px+T.PAD_X,cy,24,T.ROW_H,tcol,T.SZ,false,tlbl)
            -- Name + pos + conflux
            txt(px+T.PAD_X+26,cy,pw-T.PAD_X-100,T.ROW_H,tcol,T.SZ,false,
                ent.name..pos_str..cflx_str,
                function()
                    if ent_ref.kind=='boss' then
                        state.nm=ent_ref.ref; state.view='nm_view'
                    else
                        state.entity=ent_ref; state.entity_rev=rev
                        state.view='entity_view'
                    end
                    save_settings(); build_ui()
                end)
            if suffix~='' then
                txt(px+pw-84,cy,74,T.ROW_H,suffix_col,T.SZ,true,suffix)
            end
            cy=cy+T.ROW_H+1
        end
        end -- close pcall else

    elseif state.view=='entity_view' and state.entity then
        local ent=state.entity
        local rev=state.entity_rev or {}
        local tcol=TIER_COL[ent.tier] or T.GREY
        local tlbl=TIER_LBL[ent.tier] or '??'
        -- Header: Tier + name + pos
        sec_hdr(tlbl..' '..ent.name..' ('..(ent.pos or '?')..')')
        sep()

        -- UPWARD CHAIN: what needs this entity
        local parents=rev[ent.name] or {}
        if #parents>0 then
            txt(px+T.PAD_X,cy,pw,T.ROW_H,T.YELLOW,T.SZ,false,'Needed for:'); cy=cy+T.ROW_H
            for _,p in ipairs(parents) do
                if p.chain then
                    -- This mob's drop is needed to pop a chain NM
                    local ce=p.chain
                    local ct=chain_tier(ce)
                    local ctcol=TIER_COL[ct] or T.GREY
                    local for_str=p.for_item and (' -> '..p.for_item) or ''
                    txt(px+T.PAD_X+8,cy,pw,T.ROW_H,ctcol,T.SZ,false,
                        TIER_LBL[ct]..' '..ce.nm..' ('..(ce.pos or '?')..')'..for_str)
                    cy=cy+T.ROW_H
                    -- And that chain NM's KI feeds the boss
                    if p.boss then
                        local bt=boss_tier(p.boss,state.zone)
                        txt(px+T.PAD_X+20,cy,pw,T.ROW_H,TIER_COL[bt] or T.GOLD,T.SZ,false,
                            '-> '..TIER_LBL[bt]..' '..p.boss.name..' ('..(p.boss.pos or '?')..')')
                        cy=cy+T.ROW_H
                    end
                elseif p.boss then
                    -- This chain NM's KI directly feeds the boss
                    local bt=boss_tier(p.boss,state.zone)
                    local ki_str=p.via_ki and p.via_ki.name and (' -> '..p.via_ki.name) or ''
                    txt(px+T.PAD_X+8,cy,pw,T.ROW_H,TIER_COL[bt] or T.GOLD,T.SZ,false,
                        '-> '..TIER_LBL[bt]..' '..p.boss.name..' ('..(p.boss.pos or '?')..')'..ki_str)
                    cy=cy+T.ROW_H
                elseif p.forced_nm then
                    -- Sub-mob needed to pop an intermediate forced NM
                    txt(px+T.PAD_X+8,cy,pw,T.ROW_H,T.CYAN,T.SZ,false,
                        'T2 '..p.forced_nm..' -> pop for '..p.chain.nm)
                    cy=cy+T.ROW_H
                end
            end
            cy=cy+4
        end

        -- DOWNWARD CHAIN: what this entity needs (for chain NMs)
        if ent.kind=='chain' and ent.ref then
            local ce=ent.ref
            if ce.timed then
                txt(px+T.PAD_X,cy,pw,T.ROW_H,T.CYAN,T.SZ,false,'Timed spawn — no pop required')
                cy=cy+T.ROW_H
            elseif ce.pop_items and #ce.pop_items>0 then
                txt(px+T.PAD_X,cy,pw,T.ROW_H,T.YELLOW,T.SZ,false,'Requires:'); cy=cy+T.ROW_H
                for _,pi in ipairs(ce.pop_items) do
                    local has_sub=pi.pop_items and #pi.pop_items>0
                    local src_tier=has_sub and 2 or 1
                    local have=(get_count(pi.name)>0) and T.GREEN or T.RED
                    txt(px+T.PAD_X+8,cy,pw,T.ROW_H,have,T.SZ,false,
                        pi.name..' ('..get_count(pi.name)..') from '..
                        TIER_LBL[src_tier]..' '..(pi.from or '?')..' ('..(pi.from_pos or '?')..')')
                    cy=cy+T.ROW_H
                    for _,sub in ipairs(pi.pop_items or {}) do
                        local sh=(get_count(sub.name)>0) and T.GREEN or T.RED
                        txt(px+T.PAD_X+20,cy,pw,T.ROW_H,sh,T.SZ,false,
                            '  '..sub.name..' ('..get_count(sub.name)..') from T1 '..(sub.from or '?')..' ('..(sub.from_pos or '?')..')')
                        cy=cy+T.ROW_H
                    end
                end
            end
            -- KI it drops
            if ce.ki and ce.ki.id and ce.ki.id~=0 then
                cy=cy+4
                local kc=has_ki(ce.ki.id) and T.GREEN or T.RED
                txt(px+T.PAD_X,cy,pw,T.ROW_H,kc,T.SZ,false,
                    'Drops KI: '..ce.ki.name..(has_ki(ce.ki.id) and ' [HAVE]' or ' [MISSING]'))
                cy=cy+T.ROW_H
            end
        elseif ent.kind=='mob' and ent.ref then
            -- For a T1/T2 mob: show what item it drops
            local pi=ent.ref
            local have=(pi.name and get_count(pi.name)>0) and T.GREEN or T.RED
            if pi.name then
                txt(px+T.PAD_X,cy,pw,T.ROW_H,have,T.SZ,false,
                    'Drops: '..pi.name..' ('..get_count(pi.name)..')')
                cy=cy+T.ROW_H
            end
            -- Conflux hint
            if pi.from_conflux then
                txt(px+T.PAD_X,cy,pw,T.ROW_H,T.GREY,T.SZ,false,
                    'Farm at conflux #'..pi.from_conflux)
                cy=cy+T.ROW_H
            end
        end

    elseif state.view=='nm_view' and state.nm then
        local nm=state.nm

        -- Farm items: support goal_drops array (up to 2 tracked items per boss)
        local goal_list = nm.goal_drops or (nm.goal_drop and {nm.goal_drop}) or {}
        if #goal_list > 0 then
            local is_boss_footer=(state.show_footer and state.footer_entry==nm.name)
            local g1=goal_list[1]; local c1=get_count(g1.name)
            txt(px+T.PAD_X,cy,pw-60,T.ROW_H,c1>0 and T.GREEN or T.GOLD,T.SZ,true,
                g1.name..' ('..c1..')',nil,'farm',g1)
            txt(px+pw-46,cy,40,T.ROW_H,is_boss_footer and T.YELLOW or T.GREY,T.SZ,false,'[Info]',
                function()
                    if state.footer_entry==nm.name and state.show_footer then
                        state.show_footer=false;state.footer_entry=nil
                    else state.footer_entry=nm.name;state.show_footer=true end
                    build_ui()
                end)
            cy=cy+T.ROW_H
            if goal_list[2] then
                local g2=goal_list[2]; local c2=get_count(g2.name)
                txt(px+T.PAD_X,cy,pw-T.PAD_X,T.ROW_H,c2>0 and T.GREEN or T.GOLD,T.SZ,true,
                    g2.name..' ('..c2..')',nil,'farm',g2)
                cy=cy+T.ROW_H
            end
            cy=cy+2
        end

        -- Boss info footer (if active for boss)
        if state.show_footer and state.footer_entry==nm.name then
            show_info_footer(nm.name, settings.atma[nm.name] or nm.atma)
        end

        -- Conflux
        local cnum=settings.conflux[nm.name] or nm.conflux
        if cnum and state.zone and state.zone.confluxes[cnum] then
            txt(px+T.PAD_X,cy,pw,T.ROW_H,T.GREY,T.SZ,false,
                'Conflux #'..cnum..' at '..state.zone.confluxes[cnum].pos)
            cy=cy+T.ROW_H
        end
        sep()

        if settings.session.last_view=='tree' then
            if #nm.chain==0 then
                txt(px+T.PAD_X,cy,pw,T.ROW_H,T.GREY,T.SZ,false,'(No pop chain)');cy=cy+T.ROW_H
            else
                -- Timed NMs first
                local timed_entries = {}
                local item_entries  = {}
                for _,entry in ipairs(nm.chain) do
                    if entry.timed then timed_entries[#timed_entries+1]=entry
                    else                item_entries[#item_entries+1]=entry end
                end
                for _,entry in ipairs(timed_entries) do chain_entry(entry,true) end
                if #timed_entries>0 and #item_entries>0 then cy=cy+T.ROW_H end
                for _,entry in ipairs(item_entries) do chain_entry(entry,true) end
            end
        else
            -- Checklist view
            local inv_have,inv_total=0,0;local miss_items,miss_kis={},{}
            local kh2,kt2=0,0
            local function walk(chain)
                for _,e in ipairs(chain) do
                    if e.ki and e.ki.id and e.ki.id~=0 then
                        kt2=kt2+1
                        if has_ki(e.ki.id) then kh2=kh2+1 else miss_kis[#miss_kis+1]=e end
                    end
                    if e.pop_items then
                        for _,it in ipairs(e.pop_items) do
                            inv_total=inv_total+1
                            if get_count(it.name)>0 then inv_have=inv_have+1
                            else miss_items[#miss_items+1]={item=it,nm=e.nm} end
                            if it.pop_items then
                                for _,sub in ipairs(it.pop_items) do
                                    inv_total=inv_total+1
                                    if get_count(sub.name)>0 then inv_have=inv_have+1
                                    else miss_items[#miss_items+1]={item=sub,nm=it.from} end
                                end
                            end
                        end
                    end
                end
            end
            walk(nm.chain)
            local ic=(inv_have==inv_total) and T.GREEN or T.RED
            local kc=(kh2==kt2) and T.GREEN or T.RED
            txt(px+T.PAD_X,cy,100,T.ROW_H,ic,T.SZ,true,'Inv ['..inv_have..'/'..inv_total..']')
            txt(px+T.PAD_X+110,cy,100,T.ROW_H,kc,T.SZ,true,'Key ['..kh2..'/'..kt2..']')
            cy=cy+T.ROW_H+4
            if #miss_items>0 then
                sec_hdr('STILL NEEDED')
                for _,m in ipairs(miss_items) do
                    checkbox(px+T.PAD_X,cy+3,false)
                    local src=m.item.from and (' | '..m.item.from) or ''
                    if m.item.from_pos then src=src..' ('..m.item.from_pos..')' end
                    txt(px+T.PAD_X+14,cy,pw-T.PAD_X-18,T.ROW_H,T.RED,T.SZ,false,m.item.name..src)
                    cy=cy+T.ROW_H
                end;cy=cy+4
            end
            if #miss_kis>0 then
                sec_hdr('KEY ITEMS MISSING')
                for _,e in ipairs(miss_kis) do
                    checkbox(px+T.PAD_X,cy+3,false)
                    txt(px+T.PAD_X+14,cy,pw-T.PAD_X-18,T.ROW_H,T.RED,T.SZ,false,
                        e.ki.name..' | '..e.nm..' ('..(e.pos or '?')..')')
                    cy=cy+T.ROW_H
                end;cy=cy+4
            end
            if #miss_items==0 and kh2==kt2 then
                prim(px,cy,pw,T.ROW_H+2,T.RDY_A,T.RDY_R,T.RDY_G,T.RDY_B)
                txt(px+T.PAD_X,cy+1,pw,T.ROW_H,T.CYAN,T.SZ,true,'*** READY TO POP ***')
                cy=cy+T.ROW_H+4
            end
        end
    end

    cy=cy+T.PAD_Y
    windower.prim.set_size(bg_prim,pw,cy-content_start)
    state.panel_h=T.HDR_H+T.TITLE_H+(cy-content_start)
    -- Resize shield to cover full panel so texts lib blocks all FFXI clicks
    if state.shield then
        state.shield:pos(state.px, state.py)
        -- texts lib uses extents to determine hover — set via a space-padded string
        -- Actually we use pos+size via a workaround: set the text to spaces
        -- wide enough to cover the panel. Each char ~6px at size 11.
        local cols = math.ceil(T.WIDTH / 6)
        local rows = math.ceil(state.panel_h / T.ROW_H)
        local line = string.rep(' ', cols)
        local lines = {}
        for _=1,rows do lines[#lines+1]=line end
        state.shield:text(table.concat(lines,'\n'))
    end
    if dbg_obj then dbg_obj:pos(state.px,state.py+state.panel_h+2) end
    if not state.minimized then update_map_display() end
end

--==================================================================================================
-- MOUSE — ALL in-panel clicks consumed before FFXI sees them
--==================================================================================================
windower.register_event('mouse', function(type,x,y,delta,blocked)
    if blocked then return false end
    local in_panel=(x>=state.px and x<=state.px+T.WIDTH and y>=state.py and y<=state.py+state.panel_h)

    if type==0 then  -- move
        if drag.active then
            state.px=drag.ox+(x-drag.sx);state.py=drag.oy+(y-drag.sy)
            build_ui();return true
        end
        return false
    end

    if type==1 then  -- left down — consume ALL in-panel clicks first
        if not in_panel then return false end
        -- Fire hotzone handlers
        for _,hz in ipairs(hot_zones) do
            if x>=hz.x and x<=hz.x+hz.w and y>=hz.y and y<=hz.y+hz.h then
                if hz.fn then hz.fn() end
                return true
            end
        end
        -- Start drag anywhere on header top strip (no buttons there)
        if y<=state.py+T.HDR_H+T.TITLE_H then
            drag.active=true;drag.sx=x;drag.sy=y;drag.ox=state.px;drag.oy=state.py
        end
        return true  -- consume regardless
    end

    if type==2 then  -- left up
        if drag.active then drag.active=false;save_settings();return true end
        return false
    end

    -- type 3 (right click) intentionally NOT handled — cannot be blocked from FFXI
    -- Use [Ref] button in header to refresh instead

    if type==10 then  -- scroll
        if in_panel then
            local up=delta and delta>0
            if key_state.shift then
                settings.map.size=math.max(100,math.min(1000,settings.map.size+(up and 50 or -50)))
                map_ctx.last_size=nil
                save_settings();update_map_display();return true
            elseif key_state.ctrl then
                T.WIDTH=math.max(300,math.min(600,T.WIDTH+(up and -20 or 20)))
                settings.display.width=T.WIDTH
            elseif key_state.alt then
                local fs=math.max(8,math.min(16,settings.display.font_size+(up and -1 or 1)))
                settings.display.font_size=fs;T.SZ=fs;T.SZ_H=fs+1;T.ROW_H=fs+6
            else
                settings.display.bg_alpha=math.max(20,math.min(245,settings.display.bg_alpha+(up and -20 or 20)))
            end
            save_settings();build_ui();return true
        end
        return false
    end

    return false
end)

--==================================================================================================
-- COMMANDS
--==================================================================================================
local C={HAVE=160,WARN=167,HEADER=122,INFO=001,GUIDE=160}
local function show_guide()
    local function ln(c,t) windower.add_to_chat(c,t) end
    ln(C.HEADER,'[AbyssTracker] ====== COMMAND GUIDE ======')
    ln(C.GUIDE, '[AbyssTracker]   //at zone <name>              e.g. //at zone tahrongi')
    ln(C.GUIDE, '[AbyssTracker]   //at nm <name>                e.g. //at nm chloris')
    ln(C.INFO,  '[AbyssTracker]   //at tree / //at list         Switch view')
    ln(C.INFO,  '[AbyssTracker]   //at show / //at hide')
    ln(C.INFO,  '[AbyssTracker]   //at refresh')
    ln(C.GUIDE, '[AbyssTracker]   //at alpha <0-255>            e.g. //at alpha 180')
    ln(C.GUIDE, '[AbyssTracker]   //at cflx <nm> <id>          e.g. //at cflx chloris 3')
    ln(C.GUIDE, '[AbyssTracker]   //at trust set <nm> <set>    Set trust set name  e.g. //at trust set Chloris glavoid')
    ln(C.GUIDE, '[AbyssTracker]   //at atma add <nm> <text>    Add atma override')
    ln(C.INFO,  '[AbyssTracker]   //at atma clear <nm>         Clear atma override')
    ln(C.INFO,  '[AbyssTracker]   //at debug                   Toggle debug overlay')
    ln(C.HEADER,'[AbyssTracker] ===========================')
end

local debug_on=false
windower.register_event('addon command', function(cmd,...)
    cmd=(cmd or ''):lower();local args={...}
    if cmd=='show' then build_ui()
    elseif cmd=='hide' then destroy_all()
    elseif cmd=='guide' then show_guide()
    elseif cmd=='debug' then
        debug_on=not debug_on
        if debug_on then init_debug();dbg('Debug ON') else if dbg_obj then dbg_obj:hide() end end
        windower.add_to_chat(C.HAVE,'[AbyssTracker] Debug: '..(debug_on and 'ON' or 'OFF'))
    elseif cmd=='tree' then settings.session.last_view='tree';save_settings();build_ui()
    elseif cmd=='list' then settings.session.last_view='list';save_settings();build_ui()
    elseif cmd=='refresh' then refresh_inventory();refresh_key_items();refresh_data()
    elseif cmd=='chars' then
        if args[1] then state.chars_font=table.concat(args,' ') end
        state.view='chars';build_ui()
    elseif cmd=='map' then
        state.map_visible=not state.map_visible
        if not state.map_visible then destroy_map() end
        save_settings();build_ui();chat('Map '..(state.map_visible and 'ON' or 'OFF'))
    elseif cmd=='pos' then
        local p={['right']='bottom',['bottom']='left',['left']='top',['top']='right'}
        settings.map.position=p[settings.map.position] or 'right'
        save_settings();update_map_display();chat('Map position: '..settings.map.position)
    elseif cmd=='size' then
        local v=tonumber(args[1])
        if v then settings.map.size=math.max(100,math.min(1000,v));map_ctx.last_size=nil;save_settings();update_map_display()
             chat('Map size: '..settings.map.size..'px')
        else warn('Usage: //at size <100-1000>') end
        windower.add_to_chat(C.HAVE,'[AbyssTracker] Refreshed.')
    elseif cmd=='alpha' then
        local v=tonumber(args[1]);if v then settings.display.bg_alpha=math.floor(math.max(20,math.min(245,v)));save_settings();build_ui() end
    elseif cmd=='zone' then
        local name=table.concat(args,' ')
        for _,zn in ipairs(zone_list) do
            if zn:lower():find(name:lower(),1,true) then state.zone=zones[zn];state.nm=nil;state.view='nm_list';save_settings();build_ui();return end
        end
        windower.add_to_chat(C.WARN,'[AbyssTracker] Zone not found: '..name)
    elseif cmd=='nm' then
        local name=table.concat(args,' ')
        if not state.zone then windower.add_to_chat(C.WARN,'[AbyssTracker] Select a zone first.');return end
        for _,nm in ipairs(state.zone.nms) do
            if nm.name:lower():find(name:lower(),1,true) then state.nm=nm;state.view='nm_view';save_settings();build_ui();return end
        end
        windower.add_to_chat(C.WARN,'[AbyssTracker] NM not found: '..name)
    elseif cmd=='cflx' then
        local nm_name,cid=args[1],tonumber(args[2])
        if nm_name and cid then settings.conflux[nm_name]=cid;save_settings();build_ui()
            windower.add_to_chat(C.HAVE,'[AbyssTracker] Conflux #'..cid..' set for '..nm_name) end
    elseif cmd=='trust' then
        local sub=(args[1] or ''):lower()
        if sub=='set' and args[2] and args[3] then
            local nm_name=args[2];local tset=table.concat(args,' ',3)
            settings.trust_set[nm_name]=tset;save_settings();build_ui()
            windower.add_to_chat(C.HAVE,'[AbyssTracker] Trust set "'..tset..'" assigned to '..nm_name)
        end
    elseif cmd=='atma' then
        local sub=(args[1] or ''):lower()
        if sub=='add' and args[2] then
            local nm_name=args[2];local note=table.concat(args,' ',3)
            if not settings.atma[nm_name] then settings.atma[nm_name]={} end
            table.insert(settings.atma[nm_name],note);save_settings();build_ui()
            windower.add_to_chat(C.HAVE,'[AbyssTracker] Atma added for '..nm_name)
        elseif sub=='clear' and args[2] then
            settings.atma[args[2]]={};save_settings();build_ui() end
    else show_guide() end
end)

--==================================================================================================
-- LOOPS & EVENTS
--==================================================================================================
local function inv_loop() refresh_inventory();refresh_data();coroutine.schedule(inv_loop,5) end
local function ki_loop()  refresh_key_items();refresh_data();coroutine.schedule(ki_loop,10) end

windower.register_event('zone change', function()
    coroutine.schedule(function() refresh_inventory();refresh_key_items();refresh_data() end,2)
end)
windower.register_event('load', function()
    load_zones();load_atma_db();load_drops_db();load_settings();init_debug()
    refresh_inventory();refresh_key_items();build_ui()
    coroutine.schedule(inv_loop,5);coroutine.schedule(ki_loop,10)
    windower.add_to_chat(C.HAVE,'[AbyssTracker] Loaded. Type //at guide for help.')
end)
windower.register_event('unload', function()
    save_settings();destroy_all();destroy_map()
    if dbg_obj then pcall(function() dbg_obj:destroy() end) end
end)
windower.register_event('login', function()
    coroutine.schedule(function() refresh_inventory();refresh_key_items();build_ui() end,3)
end)
windower.register_event('keyboard', function(key,down)
    if key==29 or key==157 then key_state.ctrl=down end  -- Left/Right Ctrl
    if key==56 or key==184 then key_state.alt=down end   -- Left/Right Alt
    if key==42 or key==54  then key_state.shift=down end -- Left/Right Shift
end)
