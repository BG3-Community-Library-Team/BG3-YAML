--- Wrapper function for Ext.Utils.Print, prefixing message with [INFO]
---@param message string
---@param override boolean|nil
function Utils.Info(message, override)
  if Globals.Debug or override then
    Ext.Utils.Print(Strings.INFO_TAG .. message)
  end
end

--- Wrapper function for Ext.Utils.PrintWarning, prefixing message with [WARN]
---@param message string
---@param override boolean|nil
function Utils.Warn(message, override)
  if Globals.ShowWarnings or override then
    Ext.Utils.PrintWarning(Strings.WARNING_TAG .. message)
  end
end

--- Wrapper function for Ext.Utils.PrintError, prefixing message with [ERROR]
---@param message string
function Utils.Error(message)
  Ext.Utils.PrintError(Strings.ERROR_TAG .. message)
end

--- Builds and returns a string identifying a mod's Name and Author from a given Guid.
---@param guid string
---@return string
function Utils.RetrieveModHandleAndAuthor(guid)
  Utils.Info("Entering Utils.RetrieveModHandleAndAuthor")
  if guid and Ext.Mod.IsModLoaded(guid) then
    return Utils.RetrieveModHandle(guid) .. " (" .. Utils.RetrieveModAuthor(guid) .. ")"
  elseif guid then
    return guid
  else
    return Strings.WARN_GUID_NOT_DEFINED
  end
end

--- Builds and returns a string identifying a mod's Name from a given Guid.
---@param guid string
---@return string
function Utils.RetrieveModHandle(guid)
  if guid and Ext.Mod.IsModLoaded(guid) then
    return Ext.Mod.GetMod(guid).Info.Name
  elseif guid then
    return DictUtils.RetrieveModInfoFromDict(guid).Name
  else
    return Strings.WARN_GUID_NOT_DEFINED
  end
end

--- Builds and returns a string identifying a mod's Author from a given Guid.
---@param guid string
---@return string
function Utils.RetrieveModAuthor(guid)
  if guid and Ext.Mod.IsModLoaded(guid) then
    return Ext.Mod.GetMod(guid).Info.Author
  else
    return Strings.WARN_GUID_NOT_DEFINED
  end
end

Strings.PREFIX                    = "[YAML Parser] "
Strings.INFO_TAG                  = "[INFO]: "
Strings.WARNING_TAG               = "[WARN]: "
Strings.ERROR_TAG                 = "[ERROR]: "
Strings.ERR_YAML_PARSE_FAIL       = "Couldn't parse CF YAML Configuration File from "
Strings.ERR_YAML_TAB_INDENT       = "Tabs are not allowed for YAML indentation, use spaces"
Strings.ERR_YAML_UNTERMINATED_STR  = "Unterminated quoted string in YAML config"
Strings.ERR_YAML_BAD_INDENT       = "Inconsistent indentation in YAML config"
Strings.ERR_YAML_EXPECTED_MAP_KEY = "Expected mapping key in YAML config"
Strings.ERR_YAML_UNDEFINED_ALIAS  = "Undefined YAML alias: "
Strings.WARN_YAML_ANCHOR_REDEF    = "YAML anchor redefined: "
Strings.WARN_GUID_NOT_DEFINED     = " unknown - guid not defined"
