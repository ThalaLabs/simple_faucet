# Simple Faucet

A simple faucet contract that allows anyone to easily create a FA
and mint to anyone.

## Deployment

Testnet: [0xc17534bb2466c0a276d3efc5f619977220b485f4ae46ebeac48c749f31cc402b](https://explorer.aptoslabs.com/object/0xc17534bb2466c0a276d3efc5f619977220b485f4ae46ebeac48c749f31cc402b/modules/code/faucet?network=testnet)

Mainnet: [0xfe8b531598a7e77a0aff1e80b245b4b461807aaf30c8b6191b952825de00457c](https://explorer.aptoslabs.com/object/0xfe8b531598a7e77a0aff1e80b245b4b461807aaf30c8b6191b952825de00457c/modules/code/faucet?network=mainnet)

## Development

Compile

```
aptos move compile --dev
```

Deploy

```
aptos move deploy-object --address-name simple_faucet --profile <profile>
```
