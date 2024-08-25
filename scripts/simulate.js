const { ethers } = require("hardhat");

async function main() {
    const SimpleStorage = await ethers.getContractFactory("SimpleStorage");

    const simpleStorage = await SimpleStorage.deploy();
    await simpleStorage.deployed();

    console.log("SimpleStorage deployed to:", simpleStorage.address);

    const tx = await simpleStorage.setData(42);
    await tx.wait(); 

    console.log("Data set to 42");

    const data = await simpleStorage.getData();
    console.log("Data in contract:", data.toString());

    const trace = await ethers.provider.send("debug_traceTransaction", [tx.hash]);
    console.log("Transaction Trace:", JSON.stringify(trace, null, 2));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
