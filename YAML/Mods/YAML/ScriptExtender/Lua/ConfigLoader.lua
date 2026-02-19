local configBasePattern = string.gsub("Mods/%s/ScriptExtender/%s.", "'", "\'")
local yamlFormat = { "yaml", "yml"}
local loadedConfigs = {}

local function BuildConfigPattern(modName, fileName)
  return "Mods/" .. modName .. "/ScriptExtender/" .. fileName .. "."
end

---@param configStr string The YAML config as a string.
---@param modGUID GUIDSTRING The GUID of the mod the config belongs to.
local function TryLoadConfig(configStr, modGUID)
  local success, data
  success, data = pcall(YamlParser.parse, configStr)

  if success then
    if data ~= nil then
      loadedConfigs[modGUID] = data
    end
  else
    Utils.Error(Strings.PREFIX .. Strings.ERR_YAML_PARSE_FAIL .. Utils.RetrieveModHandleAndAuthor(modGUID))
  end
end

--- Search ScriptExtender directory for YAML configs with names matching the mod's name, parses them into
--- lua tables, and returns.
---@param modName string The name of the mod to search for configs for.
---@return table loadedConfigs A table of successfully parsed YAML configs, indexed by mod GUID.
function LoadConfigFiles(modName, fileName)
  Utils.Info(Strings.PREFIX .. "Entering LoadConfigFiles")
  for _, uuid in pairs(Ext.Mod.GetLoadOrder()) do
    local modData = Ext.Mod.GetMod(uuid)
    local modName = modData.Info.Name
    local found = false

    for _, ext in ipairs(yamlFormat) do
      if found then break end
        local filePath = (BuildConfigPattern(modName) .. ext):format(modData.Info.Directory)
        local config = Ext.IO.LoadFile(filePath, "data")
        if config ~= nil and config ~= "" then
          Utils.Info(Strings.PREFIX .. "Found " .. ext .. " config for Mod: " .. modName)
          local b, err = xpcall(TryLoadConfig, debug.traceback, config, uuid)
          if not b then
            Utils.Error(Strings.PREFIX .. err)
          end
          found = true
          break
      end
    end

    return loadedConfigs
  end
end