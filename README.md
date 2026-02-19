# BG3-YAML

A utility mod that provides YAML parsing for the BG3 modding community. It exposes a simple API to parse or Discover (and then Parse) YAML configuration files loaded within their mod or other's mods.

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
  - [Mods.YAML.Parse()](#modsyamlparse)
  - [Mods.YAML.LoadConfigFiles()](#modsyamlloadconfigfiles)
- [YAML Feature Support](#yaml-feature-support)
- [Examples](#examples)
  - [Loading Configs Across Mods](#loading-configs-across-mods)
  - [Example YAML Config File](#example-yaml-config-file)
- [Config File Location](#config-file-location)
- [Common Errors](#common-errors)

---

## Installation

Install the **YAML** mod like any other BG3 mod — place it in your mod folder/load order and ensure it loads **before** any mods that depend on it.

> **Mod UUID:** `5a8efd52-0d42-48b4-a97c-cdd9cbfe1eec`

---

## Quick Start

Once YAML is installed and in your load order, you can immediately call its API from your own mod's Lua scripts via the `Mods.YAML` table.

```lua
-- Parse a YAML string directly
local yamlString = [[
name: My Mod
version: 1
enabled: true
]]

local config = Mods.YAML.Parse(yamlString)
print(config.name)    -- "My Mod"
print(config.version) -- 1
print(config.enabled) -- true
```
> **Note**: Your YAML will probably be a bit more in depth than just displaying information about your mod. When using this, you'll most > likely want to be loading the YAML string from a `.yaml` file in some way. BG3-YAML has a method to do that automatically, but you might
> want your own way of handling the yaml files.

```lua
-- Automatically find and load YAML config files from all installed mods
local configs = Mods.YAML.LoadConfigFiles("MyModName", "MyConfigFileName")

for modGUID, configTable in pairs(configs) do
  print("Loaded config from mod: " .. modGUID)
end
```

---

## API Reference

### `Mods.YAML.Parse()`

```lua
Mods.YAML.Parse(yamlString) -> table
```

Parses a YAML-formatted string into a Lua table.

| Parameter    | Type     | Description                              |
|--------------|----------|------------------------------------------|
| `yamlString` | `string` | A string containing valid YAML content.  |

**Returns:** A Lua `table` representing the parsed YAML structure.

**Errors:** Throws an error if the YAML is malformed (e.g. tab indentation, unterminated strings, undefined aliases).

#### Typical Usage

Use this when you want full control over how and when you load a file. For example, you might load a YAML file from disk using Script Extender's `Ext.IO.LoadFile()` and then parse it:

```lua
local fileContents = Ext.IO.LoadFile("Mods/MyMod/ScriptExtender/config.yaml", "data")
if fileContents then
  local config = Mods.YAML.Parse(fileContents)
  -- Use config table...
end
```

---

### `Mods.YAML.LoadConfigFiles()`

```lua
Mods.YAML.LoadConfigFiles(modName, fileName) -> table
```

A convenience method that automatically scans **every installed mod** (in load order) for a YAML configuration file matching the given filename pattern, parses each one, and returns all successfully parsed configs in a single table.

| Parameter  | Type     | Description                                                        |
|------------|----------|--------------------------------------------------------------------|
| `modName`  | `string` | The name of the mod initiating the search.                         |
| `fileName` | `string` | The base filename (without extension) to look for in each mod.     |

**Returns:** A Lua `table` of parsed configs, **keyed by each mod's UUID**. Only mods that contained a matching YAML file will have entries.

#### How It Works

1. Iterates through the active mod load order via `Ext.Mod.GetLoadOrder()`.
2. For each mod, checks for a file at:
   ```
   Mods/<ModFolder>/ScriptExtender/<fileName>.yaml
   Mods/<ModFolder>/ScriptExtender/<fileName>.yml
   ```
3. If a matching file is found, it loads and parses the contents.
4. Successfully parsed configs are added to the results table, indexed by the mod's UUID.
5. If parsing fails for a given mod, an error is logged and that mod is skipped.

---

## YAML Feature Support

The parser supports a practical subset of the YAML specification — enough for configuration files, but not the full spec.

### Supported

| Feature                  | Example                                      |
|--------------------------|----------------------------------------------|
| Block mappings           | `key: value`                                 |
| Block sequences          | `- item`                                     |
| Nested structures        | Mappings and sequences at any depth          |
| Flow sequences           | `[a, b, c]`                                  |
| Flow mappings            | `{key: value, key2: value2}`                 |
| Quoted strings           | `"hello world"`, `'single quoted'`           |
| Unquoted / bare strings  | `hello`                                      |
| Integers                 | `42`, `-7`                                   |
| Booleans                 | `true`, `false`                              |
| Null                     | `~`, `null`, or empty value                  |
| Comments                 | `# This is a comment`                        |
| Inline comments          | `key: value # comment`                       |
| Anchors & Aliases        | `&anchor_name` / `*anchor_name`              |
| Compact mappings         | `- key: value` (mapping inside a sequence)   |
| Escape sequences         | `\\`, `\"`, `\n`, `\t` in double-quoted strings |

### Not Supported

- Multi-line strings (literal `|` and folded `>` blocks)
- YAML tags (`!!str`, `!!int`, etc.)
- Directives (`%YAML`, `%TAG`)
- Multi-document streams (`---` / `...` separators)
- `yes`/`no`/`on`/`off` as booleans (use `true`/`false`)
- Floating-point numbers (parsed as strings)
- Tab indentation (will produce an error — use spaces)

---

## Examples

### Loading Configs Across Mods

Suppose you are building a mod called **SpellTweaks** and you want other mods to provide spell override configs. In your mod's bootstrap script:

```lua
-- In your BootstrapServer.lua
Ext.Events.SessionLoaded:Add(function()
  local spellConfigs = Mods.YAML.LoadConfigFiles("SpellTweaks", "SpellOverrides")

  for modGUID, overrides in pairs(spellConfigs) do
    local modName = Ext.Mod.GetMod(modGUID).Info.Name
    print("[SpellTweaks] Loaded overrides from: " .. modName)

    -- Process the overrides table
    if overrides.spells then
      for _, spell in ipairs(overrides.spells) do
        print("  Applying override for: " .. spell.name)
      end
    end
  end
end)
```

Another mod author who wants to provide overrides simply places a file at:

```
Mods/<TheirModFolder>/ScriptExtender/SpellOverrides.yaml
```

### Example YAML Config File

```yaml
# SpellOverrides.yaml — Provided by a third-party mod
spells:
  - name: Fireball
    damage: 36
    radius: 6
    school: Evocation

  - name: MagicMissile
    damage: 10
    auto_hit: true

settings:
  allow_upcast: true
  log_changes: false
```

### Using Anchors and Aliases

Anchors (`&name`) let you define a reusable value or block, and aliases (`*name`) insert a copy of it elsewhere. This is useful when multiple entries share the same nested structure.

```yaml
# A shared loot table defined once with an anchor
common_loot: &goblin_drops
  - name: Gold
    quantity: 15
  - name: Healing Potion
    quantity: 1

encounters:
  goblin_ambush:
    location: Blighted Village
    enemies:
      - name: Goblin Warrior
        hp: 12
        loot: *goblin_drops
      - name: Goblin Archer
        hp: 8
        loot: *goblin_drops

  goblin_camp:
    location: Shattered Sanctum
    enemies:
      - name: Goblin Boss
        hp: 30
        loot:
          - name: Gold
            quantity: 50
          - name: Rare Amulet
            quantity: 1
      - name: Goblin Guard
        hp: 14
        loot: *goblin_drops
```

In this example, the `&goblin_drops` anchor defines a loot table once, and `*goblin_drops` reuses it across multiple enemies — keeping the config DRY without duplicating the same block. 

---

## Config File Location

When using `LoadConfigFiles()`, the mod searches for YAML files in each mod's Script Extender directory:

```
Mods/
  <ModFolderName>/
    ScriptExtender/
      <FileName>.yaml    <-- Checked first
      <FileName>.yml     <-- Fallback
```

- Both `.yaml` and `.yml` extensions are supported.
- Only the first match per mod is loaded (`.yaml` takes priority).
- The file is loaded using `Ext.IO.LoadFile()` with the `"data"` context.

---

## Common Errors:

| Error | Cause |
|-------|-------|
| Tab indentation | YAML requires spaces for indentation, not tabs |
| Unterminated quoted string | A `"` or `'` string was opened but never closed |
| Undefined alias | An `*alias` was used before defining the anchor with `&alias` |
| Inconsistent indentation | Indentation levels don't align properly |

When using `LoadConfigFiles()`, parse errors are caught internally and logged — a single mod's bad config will not break loading for other mods.