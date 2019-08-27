local SmartCast_Res=nil;
local SmartCast_MassRes=nil;
local tonumber=tonumber
local strmatch=strmatch
local _
local MANA_COST_PATTERN = gsub(MANA_COST, "%%d", "([%%d%.,]+)")

function HealBot_Init_retSmartCast_Res()
    return SmartCast_Res
end

function HealBot_Init_retSmartCast_MassRes()
    return SmartCast_MassRes
end

local cRank=false
local function HealBot_FindSpellRangeCast(id, spellName, spellBookId)

    if ( not id ) then return nil; end

    local spell, _, _, msCast, _, _ = GetSpellInfo(id);
    if HEALBOT_GAME_VERSION==1 then 
        local rank = GetSpellSubtext(id)
        if rank and string.sub(rank,1,4)=="Rank" then
            cRank=rank
        else
            cRank=false
        end
    end
    if ( not spell ) then return nil; end
    if not spellName then spellName=spell end
   
    local hbMana=nil
    if spellBookId then
        HealBot_TooltipInit();
        HealBot_ScanTooltip:SetSpellBookItem(spellBookId, BOOKTYPE_SPELL);
        local ttText = getglobal("HealBot_ScanTooltipTextLeft2");
        if (ttText:GetText()) then
            line = ttText:GetText();
            if line then 
                hbMana = tonumber((gsub(line, "%D", "")))
            end
        end
        
    end

    local hbCastTime=tonumber(msCast or 0);
    if hbCastTime>999 then hbCastTime=HealBot_Comm_round(hbCastTime/1000,2) end
    
    HealBot_Spell_IDs[id]={}
    HealBot_Spell_IDs[id].CastTime=hbCastTime;
    HealBot_Spell_IDs[id].Mana=hbMana or 0

    return true
end

local function HealBot_Init_Spells_addSpell(spellId, spellName, spellBookId)
    local skipSpells={ [HEALBOT_BLESSING_OF_MIGHT]=true}
    if not skipSpells[spellName] then
        if HealBot_FindSpellRangeCast(spellId, spellName, spellBookId) then
            --if cRank then spellName=strtrim(spellName).."("..cRank..")" end
            HealBot_Spell_IDs[spellId].name=spellName
            HealBot_Spell_IDs[spellId].known=IsSpellKnown(spellId)
            HealBot_Spell_Names[spellName]=spellId
        end
    end
end

function HealBot_Init_Spells_Defaults()
    HealBot_Spell_IDs={}
    HealBot_Spell_Names={}
    local nTabs=GetNumSpellTabs()
    for j=1,nTabs do
        local _, _, offset, numEntries, _, offspecID = GetSpellTabInfo(j)
        if offspecID==0 then
            for s=offset+1,offset+numEntries do
                local sName = GetSpellBookItemName(s, BOOKTYPE_SPELL)
                local sType, sId = GetSpellBookItemInfo(s, BOOKTYPE_SPELL)
                if sType == "SPELL" and not IsPassiveSpell(sId) then
                    HealBot_Init_Spells_addSpell(sId, sName, s)
                elseif sType == "FLYOUT" then
                    local _, _, numFlyoutSlots, flyoutKnown = GetFlyoutInfo(sId)
                    if flyoutKnown then
                        for f=1,numFlyoutSlots do
                            local fId, _, fKnown, fName = GetFlyoutSlotInfo(sId, f)
                            if fKnown and not IsPassiveSpell(fId) then
                                HealBot_Init_Spells_addSpell(fId, fName, s)
                            end
                        end
                    end
                end
            end
        end
    end
end

function HealBot_Init_SmartCast()
    if HealBot_Data["PCLASSTRIM"]=="PRIE" then
        if HealBot_Spell_IDs[HEALBOT_MASS_RESURRECTION] then SmartCast_MassRes=HealBot_Spell_IDs[HEALBOT_MASS_RESURRECTION].name end
        if HealBot_Spell_IDs[HEALBOT_RESURRECTION] then SmartCast_Res=HealBot_Spell_IDs[HEALBOT_RESURRECTION].name end
    elseif HealBot_Data["PCLASSTRIM"]=="DRUI" then
        if HealBot_Spell_IDs[HEALBOT_REVITALIZE] then SmartCast_MassRes=HealBot_Spell_IDs[HEALBOT_REVITALIZE].name end
        if HealBot_Spell_IDs[HEALBOT_REVIVE] then SmartCast_Res=HealBot_Spell_IDs[HEALBOT_REVIVE].name end
    elseif HealBot_Data["PCLASSTRIM"]=="MONK" then
        if HealBot_Spell_IDs[HEALBOT_REAWAKEN] then SmartCast_MassRes=HealBot_Spell_IDs[HEALBOT_REAWAKEN].name end
        if HealBot_Spell_IDs[HEALBOT_RESUSCITATE] then SmartCast_Res=HealBot_Spell_IDs[HEALBOT_RESUSCITATE].name end
    elseif HealBot_Data["PCLASSTRIM"]=="PALA" then
        if HealBot_Spell_IDs[HEALBOT_ABSOLUTION] then SmartCast_MassRes=HealBot_Spell_IDs[HEALBOT_ABSOLUTION].name end
        if HealBot_Spell_IDs[HEALBOT_REDEMPTION] then SmartCast_Res=HealBot_Spell_IDs[HEALBOT_REDEMPTION].name end
    elseif HealBot_Data["PCLASSTRIM"]=="SHAM" then
        if HealBot_Spell_IDs[HEALBOT_ANCESTRAL_VISION] then SmartCast_MassRes=HealBot_Spell_IDs[HEALBOT_ANCESTRAL_VISION].name end
        if HealBot_Spell_IDs[HEALBOT_ANCESTRALSPIRIT] then SmartCast_Res=HealBot_Spell_IDs[HEALBOT_ANCESTRALSPIRIT].name end
    end
end
