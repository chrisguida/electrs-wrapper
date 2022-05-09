# Instructions for electrs

## Why electrs?

Electrs is an "Electrum Server."  This is a tool that allows for deeper insight into the Bitcoin blockchain, by keeping an index that allows querying of UTXOs by address.  This is extremely useful if you are running your own block explorer (such as mempool.space on your Embassy), and electrum servers can also be used to link wallets to your Bitcoin full node.  In order to link a wallet, check out the guides at https://github.com/chrisguida/electrs-wrapper/tree/master/docs/wallets.md.

## Setup

To use electrs, you will require at minimum Bitcoin Core, and you may optionally use Bitcoin Proxy.  Upon install, electrs will require an auto-configuration of Bitcoin/Proxy.  Depending on your existing configuration, a resync of Bitcoin may be required (a full archival node with txindex turned on is necessary).  Following this, electrs will have its own sync, followed by a compaction of data.  You are then ready to use electrs!