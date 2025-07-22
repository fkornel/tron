# Tron – A WebGL-based Chia Game Tracker in Python (Pyodide)

**Tron** is a fully client-side, Python-based game tracker for peer-to-peer games running on the Chia blockchain. It leverages [Pyodide](https://pyodide.org/) for Python in the browser, and renders a complete user interface via WebGL canvas — with no HTML DOM manipulation or JavaScript framework.

## 🔹 Features

- 🕹️ **Game UI in WebGL** – All visuals (cards, interactions, animations) are drawn directly on a `<canvas>` using Python → WebGL2 calls.
- 🔐 **DID Authentication** – Users are identified by auto-generated Chia DIDs; WalletConnect upgrade available for power users.
- 🔄 **State Channels & Offers** – CalPoker and other turn-based games run with on-chain-secured outcomes via SpendBundles and Offers, built directly in-browser.
- 🌍 **Decentralized Matchmaking** – Uses [Nostr](https://nostr.com/) for peer discovery; optional Matrix bridging supported.
- 🛰️ **DIG Network Hosting** – Fully static assets hosted on the decentralized [DIG Network](https://github.com/DIG-Network), versioned and verifiable.
- 🪙 **Referral-Based Incentives** – Built-in royalty-splitting puzzle for game referrers, infrastructure hosts (gateway peers), and affiliate NFTs.
- 📲 **Offline-capable PWA** – Installable app with service worker support and local caching. No servers required.

## 🧩 Architecture Highlights

- Built entirely in **Python**, compiled to WebAssembly using **Pyodide**.
- UI logic and rendering handled via `js.WebGL2RenderingContext` from within Python.
- Game states, peer connections, and messaging managed with `asyncio` + Nostr/WebSocket bridges.
- Royalty and referral logic implemented with custom CLVM puzzles built in Python.

## 🏗️ Project Goals

- Deliver a reference frontend for Chia-compatible P2P games like CalPoker and Krunk.
- Serve as a boilerplate for new Web3 games built with a serverless-first, decentralization-friendly mindset.
- Showcase tokenomics mechanics (GameCoin, affiliate NFTs, host rewards) in a fully transparent way.

## 🚧 Status

Development is ongoing. This is an experimental PWA—use at your own discretion.

## 📄 License

[MIT License](LICENSE)
