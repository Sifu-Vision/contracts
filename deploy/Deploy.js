const hre = require("hardhat")
const lzEndpoints = require("../constants/layerzeroEndpoints.json")
const chainIds = require("../constants/chainIds.json")

async function setTrustRemote(sifu, oftAddr) {
    const chains = ["ethereum", "avalanche", "fantom", "arbitrum"]

    for (let i = 0; i < chains.length; i++) {
        if (chains[i] !== hre.network.name)
            await (
                await sifu.setTrustedRemote(chainIds[chains[i]], hre.ethers.utils.solidityPack(["address", "address"], [oftAddr, oftAddr]))
            ).wait(4)
    }
}

async function deploy() {
    const oldTokenAddress = process.env.OLD_TOKEN_ADDRESS
    const tokenName = "Sifu Vision"
    const tokenSymbol = "Sifu"
    const exchangeRate = "1000000000000000000"

    if (oldTokenAddress) {
        const Sifu = await hre.ethers.getContractFactory("Sifu")
        const sifu = await Sifu.deploy(lzEndpoints[hre.network.name], tokenName, tokenSymbol)
        await sifu.deployed()
        console.log("Sifu contract: ", sifu.address)

        // set trusted remote
        await setTrustRemote(sifu, sifu.address)

        // deploy migration
        const Migration = await hre.ethers.getContractFactory("Migration")
        const migration = await Migration.deploy(oldTokenAddress, sifu.address, exchangeRate)
        await migration.deployed()
        console.log("Migration contract: ", migration.address)
    } else {
        throw "OLD_TOKEN_ADDRESS NOT SET"
    }
}

async function main() {
    await deploy()
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
