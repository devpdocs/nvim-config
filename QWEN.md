# Neovim Configuration (QWEN.md)

## Overview

This is a personal **Neovim (>=0.9)** configuration written in **Lua**, managed with the [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager. It is designed as a full-featured development environment with strong support for **Python, JavaScript/TypeScript, Lua, Rust, Go, C/C++, C#, HTML/CSS, Astro, Markdown**, and more.

The configuration emphasizes:
- **LSP-driven workflow** via `nvim-lspconfig` + `mason.nvim`
- **Fuzzy finding** with Telescope + fzf-native
- **Completion** with nvim-cmp + LuaSnip
- **Git integration** with gitsigns, fugitive, and Telescope git pickers
- **AI chat integration** with a custom `mbt-chatcode` plugin supporting Qwen, Gemini CLI, Codex, and Claude

---

## Directory Structure

```
nvim/
├── init.lua                    # Entry point — require("config")
├── lazy-lock.json              # lazy.nvim lockfile for reproducible installs
├── package.json / pnpm-lock    # NPM/pnpm metadata (likely for tooling, not core nvim)
├── lua/
│   ├── config/                 # Core configuration modules
│   │   ├── init.lua            # Loads all config modules
│   │   ├── settings.lua        # Basic vim options (number, relativenumber, leader=space)
│   │   ├── keymapsettings.lua  # Global keymappings
│   │   ├── lazy.lua            # lazy.nvim bootstrap and plugin spec
│   │   ├── scripts.lua         # Custom commands (Django/Angular server management)
│   │   ├── jinja2.lua          # Jinja2 template support
│   │   ├── parse_lua.lua       # Custom Lua parsing utilities
│   │   ├── tabsettings.lua     # Tab/indent settings
│   │   └── plugins/            # Plugin config modules (cmp, luasnip)
│   ├── plugins/                # Plugin declarations + setup
│   │   ├── lsp.lua             # LSP servers config (pyright, ts_ls, gopls, rust_analyzer, etc.)
│   │   ├── cmp.lua             # Autocompletion (nvim-cmp)
│   │   ├── telescope.lua       # Fuzzy finder (telescope.nvim)
│   │   ├── tree-sitter.lua     # Syntax highlighting + text objects
│   │   ├── colorscheme.lua     # onedarkpro theme
│   │   ├── mason.lua           # LSP/DAP/Formatter package manager
│   │   ├── gitsigns.lua        # Git hunks in signcolumn
│   │   ├── noice.lua           # UI improvements for cmdline/messages
│   │   ├── notify.lua          # Notification system
│   │   ├── oil.lua             # File explorer
│   │   ├── luasnip.lua         # Snippet engine
│   │   ├── markdown.lua        # Markdown enhancements
│   │   ├── comment.lua         # Comment toggling
│   │   ├── fugitive.lua        # Git integration
│   │   ├── lualine.lua         # Status line
│   │   ├── nvim-autopairs.lua  # Auto-closing brackets
│   │   ├── nvim-web-devicons.lua # File icons
│   │   └── venv-selector.lua   # Python virtual environment selector
│   └── my-plugins/             # Custom in-house plugins
│       └── lua/mbt-chatcode/   # AI chat terminal (qwen, gemini, codex, claude)
│       └── lua/mbt-floaterminal/ # Floating terminal utility
└── ftplugin/                   # Filetype-specific configurations
    ├── javascript.lua, typescript.lua, python.lua, etc.
```

---

## Key Plugins

| Category | Plugins |
|----------|---------|
| **Plugin Manager** | `folke/lazy.nvim` |
| **LSP** | `neovim/nvim-lspconfig`, `williamboman/mason.nvim`, `folke/neodev.nvim` |
| **Completion** | `hrsh7th/nvim-cmp`, `L3MON4D3/LuaSnip`, `saadparwaiz1/cmp_luasnip` |
| **Navigation** | `nvim-telescope/telescope.nvim` + fzf-native + file-browser |
| **Syntax** | `nvim-treesitter/nvim-treesitter` + textobjects |
| **Git** | `lewis6991/gitsigns.nvim`, `tpope/vim-fugitive` |
| **UI** | `olimorris/onedarkpro.nvim` (theme), `nvim-lualine/lualine.nvim`, `folke/noice.nvim`, `rcarriga/nvim-notify` |
| **File Management** | `stevearc/oil.nvim`, `nvim-tree/nvim-web-devicons` |
| **Python** | `linux-cultist/venv-selector.nvim` |
| **Utility** | `windwp/nvim-autopairs`, `numToStr/Comment.nvim` |
| **Custom** | `mbt-chatcode` (AI chat), `mbt-floaterminal` (floating terminal) |

---

## Configured LSP Servers

The following LSP servers are configured in `lua/plugins/lsp.lua`:

| Server | Language |
|--------|----------|
| `lua_ls` | Lua |
| `pyright` | Python |
| `ruff` | Python (linting/formatting) |
| `ts_ls` | JavaScript / TypeScript / TSX |
| `omnisharp` | C# |
| `astro` | Astro |
| `html` | HTML |
| `cssls` | CSS |
| `jsonls` | JSON / JSONC |
| `rust_analyzer` | Rust (with inlay hints) |
| `clangd` | C / C++ |
| `gopls` | Go |
| `markdown_oxide` | Markdown |

LSP servers are installed/managed via **Mason**. Run `:Mason` inside Neovim to install missing LSP servers.

---

## Key Mappings

### Global Mappings (`lua/config/keymapsettings.lua`)

| Keys | Mode | Description |
|------|------|-------------|
| `<leader>bd` | Normal | Close current buffer |
| `<leader>rr` | Normal | Source current file |
| `>` / `<` | Visual | Indent/outdent and re-select |
| `\|` | Normal | Vertical split |
| `<leader>\|` | Normal | Horizontal split |
| `<leader>h/j/k/l` | Normal | Navigate between windows |
| `n` / `N` | Normal | Search next/prev, centered |
| `<C-fs>` | Normal | Format JSON with jq |
| `<C-so>` | Visual | Sort selected lines |
| `<Tab>,` | Normal | Paste from system clipboard |

### LSP Mappings (`lua/plugins/lsp.lua`)

| Keys | Mode | Description |
|------|------|-------------|
| `<leader>e` | Normal | Open diagnostic float |
| `[d` / `]d` | Normal | Previous/next diagnostic (with float) |
| `<leader>q` | Normal | Add diagnostics to loclist |
| `\` | Normal | Hover documentation |
| `K` | Normal | Hover documentation |
| `gD` | Normal | Go to declaration |
| `gd` | Normal | Go to definition |
| `gi` | Normal | Go to implementation |
| `<C-K>` | Normal | Signature help |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>ca` | Normal/Visual | Code action |
| `gr` | Normal | Find references |
| `<leader>f` | Normal | Format buffer |
| `<leader>D` | Normal | Type definition |

### Telescope (`lua/plugins/telescope.lua`)

| Keys | Description |
|------|-------------|
| `<leader><CR>` | Git files |
| `<leader>pe` | Buffers |
| `<leader>gs` | Git status |
| `<leader>gc` | Git bcommits |
| `<leader>gb` | Git branches |
| `<leader>rp` | Plugin files browser |
| `<leader>pf` | Find files |
| `<leader>ph` | Help tags |
| `<leader>bb` | File browser |

### AI Chat (`mbt-chatcode`)

| Keys | Description |
|------|-------------|
| `<leader>cc` | Toggle AI chat terminal |
| `<leader>cl` | Focus chat window |
| `<leader><Right>` | Increase chat width |
| `<leader><Left>` | Decrease chat width |
| `:ChatCode` | Toggle chat via command |
| `:ChatCodeTool <name>` | Switch provider (qwen, gemini, codex, claude) |

### Django/Angular (`lua/config/scripts.lua`)

| Keys | Command | Description |
|------|---------|-------------|
| `<leader><leader>dr` | `:DjangoServerStart` | Start Django dev server |
| `<leader><leader>ds` | `:DjangoServerStop` | Stop Django dev server |
| `<leader><leader>ngr` | `:NgServe` | Start Angular dev server |
| `<leader><leader>ngo` | `:NgServe -o` | Start Angular with auto-open |
| `<leader><leader>ngs` | `:NgStop` | Stop Angular dev server |

### Other

| Keys | Description |
|------|-------------|
| `-` | Open Oil.nvim file browser |
| `<Space>-` | Toggle Oil floating window |
| `<leader>vs` | Select Python venv |
| `<leader>vc` | Use cached venv |

---

## Leader Key

The **leader key** is set to **Space** (`" "`).

---

## Colorscheme

**onedarkpro.nvim** with the `onedark` theme and transparency enabled.

---

## Tree-sitter Languages

Ensured on install: `c`, `php`, `javascript`, `lua`, `luadoc`, `markdown`, `markdown_inline`, `python`, `rust`, `typescript`, `html`, `css`, `scss`, `cpp`, `c_sharp`, `json`, `jsonc`, `astro`, `go`.

---

## Filetype Plugins (`ftplugin/`)

Filetype-specific configurations exist for: `astro`, `c`, `cpp`, `cs`, `css`, `dosini`, `go`, `html`, `java`, `javascript`, `javascriptreact`, `json`, and more.

---

## How to Use

### First-Time Setup

1. Ensure **Neovim >= 0.9** is installed.
2. Clone or copy this config into `~/.config/nvim/`.
3. Launch `nvim`. The `lazy.nvim` plugin manager will auto-install itself and all plugins on first run.
4. Run `:Mason` to install LSP servers, formatters, and linters.
5. Run `:TSInstall all` (or specific languages) to install Tree-sitter parsers.

### Common Commands

| Command | Description |
|---------|-------------|
| `:Lazy` | Manage plugins (update, sync, etc.) |
| `:Mason` | Install/manage LSP servers and tools |
| `:TSInstall <lang>` | Install Tree-sitter parser for a language |
| `:VenvSelect` | Select a Python virtual environment |
| `:ChatCode` | Toggle AI chat terminal |
| `:Oil` / `-` | Open file browser |
| `:DjangoServerStart` / `:NgServe` | Start dev servers |

---

## Custom Plugins

### mbt-chatcode

A custom plugin that opens a floating terminal running an AI CLI tool. Supports:
- **qwen** (`qwen`)
- **gemini** (`gemini` — auto-installs via npm if missing)
- **codex** (`codex` — with `--dangerously-bypass-approvals-and-sandbox` flag)
- **claude** (`claude`)

### mbt-floaterminal

A floating terminal utility (see `lua/my-plugins/lua/mbt-floaterminal/init.lua`).

---

## Notes

- The `package.json` and `pnpm-lock.yaml` appear to be auxiliary and are not central to the Neovim configuration. They may be used for external tooling or npm-based CLI tools (e.g., gemini-cli).
- Servers and processes (Django, Angular) are automatically killed on `VimLeavePre`.
- `clangd` has its `signatureHelpProvider` disabled to avoid conflicts.
- `rust_analyzer` enables inlay hints automatically.
