
local checkVersion = function(err, response, headers)
    local versionNumber = response:match("version%s*'([%d%.]+)'") 
    local resourceName = "f-humainelabsraid ("..GetCurrentResourceName()..")" -- the resource name
    local curVersion = GetResourceMetadata(GetCurrentResourceName(), 'version') -- make sure the "version" file actually exists in your resource root!
    if tostring(curVersion) == tostring(versionNumber) then
        return print("^0[^2INFO^0] " .. resourceName .. " is up to date! (^2" .. curVersion .."^7)")
    end

    local errStr = "^3----------------------------------------------------^0\n"
    errStr = errStr .. "^3| ^0 " .. resourceName .. " is ^1NOT ^0up to date! ^0^3|\n"
    errStr = errStr .. "^3|\t^7\t ^0Your Version:   ^1" .. curVersion .. "^0\t\t\t   ^3|\n"
    errStr = errStr .. "^3|\t^7\t ^0Latest Version:   ^2" .. versionNumber .. "^0\t\t   ^3|\n"
    errStr = errStr .. "^3-------------------------------------------------------------^0"
    warn(errStr)
end
 
AddEventHandler('onResourceStart', function(resource)
   if resource ~= GetCurrentResourceName() then return end
   local path = "https://raw.githubusercontent.com/Friskky1/f-humainelabsraid/main/fxmanifest.lua" -- your git user/repo path
   PerformHttpRequest(path, checkVersion)
end)