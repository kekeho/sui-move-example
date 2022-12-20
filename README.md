# Fund

A simple crowdfunding contract implemented as an introduction to Sui and Move.

- Project owner creates a new project with a title and target amount
- Money is transferred to the project from any account
- Project owner can withdraw money once the target amount is exceeded


## Build

```sh
$ sui move build
```

## Publish

```sh
$ sui client publish --gas-budget 1000
```
