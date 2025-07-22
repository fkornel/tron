# AGENTS.md

## Project Overview

This repository contains the source code of **Tron**, a WebGL-based, Pyodide-powered, peer-to-peer game tracker for the Chia blockchain. All logic is implemented in Python and runs in-browser using Pyodide (WASM). The user interface is drawn entirely in WebGL on a single `<canvas>` element. No DOM manipulation, JavaScript frameworks, or backend services are used.

## Folder Structure

/
├─ index.html # Pyodide bootstraps here
├─ app.py # Main game loop and UI controller (WebGL, asyncio)
├─ calpoker/ # Game module: CalPoker logic
│ └─ ui.py # Card rendering and selection logic
├─ clvm/ # CLVM puzzle templates and Offer builders
├─ static/ # Texture atlas, font atlas, manifest, icons
├─ sw.js # PWA service worker
├─ manifest.json # PWA manifest
└─ AGENTS.md # You are here

## Agent Scope

You may modify or create code within:

- `app.py`
- `calpoker/`
- `clvm/`
- `sw.js`, `manifest.json`
- `README.md`, `AGENTS.md`

You **should not** modify:

- `index.html` (unless explicitly instructed)
- `static/` (assets like textures or icons)

## Dev Environment

- Python version: **3.12**
- Use Pyodide-compatible packages only (no C extensions)
- Internet access is **enabled**
- Packages installed via `pip` in `setup.sh`
- Use `asyncio`, `js` interop (`pyodide.ffi`) for browser APIs

## How to Validate

There is no automated test suite yet. Validate changes by:

1. Ensuring `app.py` compiles and runs in Pyodide context
2. WebGL state updates visually work (no blank canvas)
3. `clvm/` modules produce correct hex puzzle programs for royalty logic
4. Manual test vectors for SpendBundle/Offer generation pass (TBD)

> Add comments in your PRs if a test script is included or output examples are provided.

## Contribution Style

- Python code should be type-annotated and cleanly formatted (PEP8)
- No JS frameworks or React – only `pyodide`, `js`, `WebGL` interop allowed
- Focus on modularity: each game (CalPoker, Krunk, etc.) should be separable in its own subfolder
- Favor clarity over optimization (this is a reference implementation)

## Prompting and PRs

Codex prompts may use these phrases to target this environment:

- "Add a WebGL-rendered component to display a 4-card poker hand"
- "Update the royalty puzzle to add 3-level referral payout"
- "Create a SpendBundle generator for a CalPoker game outcome"
- "Draw an installable PWA with offline fallback using Workbox"
