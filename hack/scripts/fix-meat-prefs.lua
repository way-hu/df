-- Replaces non-muscle meat preferences with muscle meat preferences for units
-- Vanilla does not report the exact meat type, so we default it to muscle.
-- By way
--@ module = true
--[====[

fix-meat-prefs
=============
Replaces non-muscle meat preferences with muscle meat preferences.
Use with the `repeat` command for regular updates.

]====]
local replaceCount = {}
local my_civ = df.global.world.world_data.active_site[0].entity_links[0].entity_id
for i, unit in ipairs (df.global.world.units.all) do
    if unit.civ_id == my_civ and unit.status.current_soul then
        for i, preference in ipairs (unit.status.current_soul.preferences) do
            if preference.active and preference.type == df.unit_preference.T_type.LikeFood then
                local material = dfhack.matinfo.decode(preference.mattype, preference.matindex)
                if material and material.mode=="creature" then 
                    local token = material:getToken()
                    local new = token:gsub(":[^:]*$",":MUSCLE")
                    local meat = dfhack.matinfo.find(new)
                    if meat then
                        local _, _, old = token:find(":([^:]*)$")
                        old = old:lower()
                        if old~= "muscle" then 
                            replaceCount[old] = (replaceCount[old] or 0) + 1
                        end
                        preference.mattype = meat.type
                        preference.matindex = meat.index
                    end
                end
            end
        end
    end
end
local report = {}
for item, count in pairs(replaceCount) do
    report[#report+1] = tostring(count).." "..item..((count>1) and "s" or "")
end    
if #report>0 then dfhack.println(table.concat(report,", ").." preferences fixed") end
