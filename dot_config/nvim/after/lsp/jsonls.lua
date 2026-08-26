-- SchemaStore matches Claude Code's schemas on applied paths (**/.claude/*.json), which
-- never match chezmoi's dot_claude/ sources -- so the files get no validation where they're
-- actually edited. Re-point the same schemas at the source paths. settings.local.json isn't
-- in SchemaStore's fileMatch at all, but takes the settings schema.
local claude_settings = "https://www.schemastore.org/claude-code-settings.json"

return {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas({
        extra = {
          {
            name = "Claude Code Settings (chezmoi source)",
            url = claude_settings,
            fileMatch = { "**/dot_claude/settings.json" },
          },
          {
            name = "Claude Code Settings (local overrides)",
            url = claude_settings,
            fileMatch = { "**/.claude/settings.local.json" },
          },
          {
            name = "Claude Code Keybindings (chezmoi source)",
            url = "https://www.schemastore.org/claude-code-keybindings.json",
            fileMatch = { "**/dot_claude/keybindings.json" },
          },
        },
      }),
      validate = { enable = true },
    },
  },
}
