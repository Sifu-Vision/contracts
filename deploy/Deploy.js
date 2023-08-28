const hre = require("hardhat")

async function setTrustRemote(wonderland) {
    const oftAddr = "0x9b06F3C5de42D4623D7A2Bd940EC735103c68A76"
    await (
        await wonderland.setTrustedRemote(
            // ethereum
            101,
            hre.ethers.utils.solidityPack(["address", "address"], [oftAddr, oftAddr])
        )
    ).wait(4)
    await (
        await wonderland.setTrustedRemote(
            // avalanche
            106,
            hre.ethers.utils.solidityPack(["address", "address"], [oftAddr, oftAddr])
        )
    ).wait(4)
    await (
        await wonderland.setTrustedRemote(
            // fantom
            112,
            hre.ethers.utils.solidityPack(["address", "address"], [oftAddr, oftAddr])
        )
    ).wait(4)
    await (
        await wonderland.setTrustedRemote(
            // arbitrum
            110,
            hre.ethers.utils.solidityPack(["address", "address"], [oftAddr, oftAddr])
        )
    ).wait(4)
}

async function deploy() {
    const wonderland = await hre.ethers.getContractAt("Wonderland", oftAddr)

    await setTrustRemote(wonderland)

    // await sifu.addMinter("0x6674Bc65Df8Bd4F5b495c1dAD35543Eb6c4eb674", true)
    // await sifu.mint("0x0835000d3Fba5F24A0f7F1f91A711BF6eBBa3793", "100000000000000000000000")
    // const ERC20Mock = await hre.ethers.getContractFactory("ERC20Mock")
    // const erc20Mock = await ERC20Mock.deploy("Old Wonderland Token", "OWT")
    // await erc20Mock.deployed()
    // console.log("Old Wonderland Token: ", erc20Mock.address)

    // const Wonderland = await hre.ethers.getContractFactory("Wonderland")
    // const wonderland = await Wonderland.deploy("0x3c2269811836af69497E5F486A85D7316753cf62", "Volta Club", "Volta")
    // await wonderland.deployed()
    // console.log("Wonderland contract: ", wonderland.address)

    // const Migration = await hre.ethers.getContractFactory("Migration")
    // const migration = await Migration.deploy("0xecf2adaff1de8a512f6e8bfe67a2c836edb25da3", wonderland.address, "330000000000000000000")
    // await migration.deployed()
    // console.log("Migration contract: ", migration.address)
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
