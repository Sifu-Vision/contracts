# Sifu Vision Contracts

### Install & Run tests

```shell
yarn install
npx hardhat test
```

- The code in the `/contracts` folder demonstrates LayerZero behaviours.
- `NonblockingLzApp` is a great contract to extend. Take a look at how `OmniCounter` overrides `_nonblockingLzReceive` and `_LzReceive` to easily handle messaging. There are also example for `OFT` and `ONFT` which illustrate erc20 and erc721 cross chain functionality.
- Always audit your own code and test extensively on `testnet` before going to mainnet 🙏

> The examples below use two chains, however you could substitute any LayerZero supported chain!

# OmnichainFungibleToken (OFT)

## About OFTV2

```shell
NOTE: the OFTV2 uses uint64 to encode value transfer for compatability of aptos and solana.

The deployer is expected to set a lower decimal points like 6 or 8.

If the decimal point is 18, then uint64 can only represent approximately 18 tokens (uint64.max ~= 18 * 10^18).
```

## Deploy Setup

1. Add a .env file (to the root project directory) with your MNEMONIC="" and fund your wallet in order to deploy!
2. Follow any of the tutorials below

## OFTV2.sol - an omnichain ERC20

> WARNING: **You must perform the setTrustedRemote() (step 2).**

1. Deploy two contracts:

```angular2html
npx hardhat --network goerli deploy --tags ExampleOFTV2
npx hardhat --network fuji deploy --tags ExampleOFTV2
```

2. Set the "trusted remotes" (ie: your contracts) so each of them can receive messages from one another, and `only` one another.

```angular2html
npx hardhat --network goerli setTrustedRemote --target-network fuji --contract ExampleOFTV2
npx hardhat --network fuji setTrustedRemote --target-network goerli --contract ExampleOFTV2
```

3. Send tokens from goerli to fuji

```angular2html
npx hardhat --network goerli oftv2Send --target-network fuji --qty 42 --contract ExampleOFTV2
```

Pro-tip: Check the ERC20 transactions tab of the destination chain block explorer and await your tokens!

# OmniCounter.sol

OmniCounter is a simple contract with a counter. You can only _remotely_ increment the counter!

1. Deploy both OmniCounters:

```
npx hardhat --network bsc-testnet deploy --tags OmniCounter
npx hardhat --network fuji deploy --tags OmniCounter
```

2. Set the remote addresses, so each contract can receive messages

```angular2html
npx hardhat --network bsc-testnet setTrustedRemote --target-network fuji --contract OmniCounter
npx hardhat --network fuji setTrustedRemote --target-network bsc-testnet --contract OmniCounter
```

3. Send a cross chain message from `bsc-testnet` to `fuji` !

```angular2html
npx hardhat --network bsc-testnet incrementCounter --target-network fuji
```

Optionally use this command in a separate terminal to watch the counter increment in real-time.

```
npx hardhat --network fuji ocPoll
```

# Check your setTrustedRemote's are wired up correctly

Just use our checkWireUpAll task to check if your contracts are wired up correctly. You can use it on the example contracts deployed above.

1. ExampleBasedOFT and ExampleOFT

```angular2html
npx hardhat checkWireUpAll --e testnet --contract ExampleOFT --proxy-contract ExampleBasedOFT --proxy-chain goerli
```

2. UniversalONFT

```angular2html
npx hardhat checkWireUpAll --e testnet --contract ExampleUniversalONFT721
```

3. OmniCounter

```angular2html
npx hardhat checkWireUpAll --e testnet --contract OmniCounter
```
