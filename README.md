# nav

A fuzzy file browser for the terminal. Type to filter, navigate directories without leaving the TUI, preview files inline.

Built on [fzf](https://github.com/junegunn/fzf).

```
  ┌──────────────────────────────────────────────────────────────────────┐
  │ nav> _                                                              │
  │ /home/user/projects/myapp                                           │
  │──────────────────────┬─────────────────────────────────────────────  │
  │  src/               │ import express from 'express'                │
  │  tests/             │ import { db } from './db'                    │
  │  docs/              │                                              │
  │  index.ts           │ const app = express()                        │
  │  config.toml        │ const port = process.env.PORT ?? 3000        │
  │  Makefile           │                                              │
  │  README.md          │ app.get('/', (req, res) => {                 │
  │  package.json       │   res.send('ok')                             │
  │  .gitignore         │ })                                           │
  └──────────────────────┴─────────────────────────────────────────────  │
```

## Features

- **Fuzzy filtering** — type to narrow results instantly
- **File preview** — right pane shows file contents as you browse
- **Image preview** — renders images inline (kitty terminal)
- **Nerd Font icons** — file type icons for directories and common extensions
- **Binary detection** — skips binary files in preview, shows file type and size instead
- **Directory navigation** — move through directories without leaving nav
- **Shell integration** — `cd` into your final directory when you exit

## Requirements

- [fzf](https://github.com/junegunn/fzf)
- bash
- [Nerd Font](https://www.nerdfonts.com/) (for icons)
- [kitty](https://sw.kovidgoyal.net/kitty/) (optional, for image preview)

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/fattarsi/nav/main/install.sh | bash
```

Or clone and run locally:

```sh
git clone https://github.com/fattarsi/nav.git
cd nav
./install.sh
```

This copies `nav` to `~/bin` and adds a shell wrapper (`n`) to your `.bashrc` or `.zshrc`.

To install somewhere else:

```sh
INSTALL_DIR=/usr/local/bin curl -fsSL https://raw.githubusercontent.com/fattarsi/nav/main/install.sh | bash
```

### Manual install

1. Copy `nav` somewhere in your `PATH` and make it executable
2. Add the wrapper function to your shell config:

```sh
n() {
    local result dest
    result=$(nav)
    if [[ "$result" == *$'\n'* ]]; then
        local last_line="${result##*$'\n'}"
        local first_line="${result%%$'\n'*}"
        if [[ "$first_line" == OPEN:* ]]; then
            ${EDITOR:-vim} "${first_line#OPEN:}"
            return
        fi
        dest="$last_line"
    else
        dest="$result"
    fi
    if [ -n "$dest" ] && [ "$dest" != "$PWD" ]; then
        builtin cd -- "$dest"
    fi
}
```

## Usage

Run `n` to start browsing from the current directory.

### Keybindings

| Key | Action |
|---|---|
| Type | Filter files and directories |
| `Enter` | Enter directory / open file in `$EDITOR` |
| `Tab` | Enter directory |
| `Backspace` | Delete filter text; go up a directory when empty |
| `Left` | Go up a directory |
| `Right` | Enter directory |
| `Shift+Tab` | Exit nav, `cd` to current directory |
| `Ctrl+L` | Toggle hidden files |
| `Esc` | Quit without changing directory |

### Examples

Browse from the current directory:

```sh
n
```

Filter by typing — results narrow as you type:

```
  nav> main
  ──────────────────────
   src/main.rs
   tests/test_main.py
```

Enter a directory with `Enter` or `Tab`, then keep browsing. When you find where you want to be, hit `Shift+Tab` to drop into that directory in your shell.

Open a file by pressing `Enter` on it — opens in `$EDITOR` (defaults to `vim`).

### Preview

- **Directories** show their contents
- **Text files** show the first 100 lines
- **Images** render inline (kitty terminal with icat)
- **Binary files** show file type and size

## License

MIT
