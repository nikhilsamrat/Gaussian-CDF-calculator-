const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");


async function main() {
    const CDF = await ethers.getContractFactory("CDF");

    const cdf = await CDF.deploy();
    await cdf.deployed();

    console.log("CDF deployed to:", cdf.address);

    try {
        let cdfVal;
        cdfVal = await cdf.gaussianCDF(BigNumber.from("100000000000000000000000000000000000000000"), 0, BigNumber.from("1000000000000000000"));
        console.log("cdfVal x=e23, mu=0, sigma=1:", cdfVal);
        cdfVal = await cdf.gaussianCDF(BigNumber.from("-100000000000000000000000000000000000000000"), 0, BigNumber.from("1000000000000000000"));
        console.log("cdfVal x=e-23, mu=0, sigma=1:", cdfVal);
       	cdfVal = await cdf.gaussianCDF(BigNumber.from("0"), 0, BigNumber.from("1000000000000000000"));
        console.log("cdfVal x=0, mu=0, sigma=1:", cdfVal);
        cdfVal = await cdf.gaussianCDF(BigNumber.from("1000000000000000000"), 0, BigNumber.from("1000000000000000000"));
        console.log("cdfVal x=1, mu=0, sigma=1:", cdfVal);
        cdfVal = await cdf.gaussianCDF(BigNumber.from("-1000000000000000000"), 0, BigNumber.from("1000000000000000000"));
        console.log("cdfVal x=-1, mu=0, sigma=1:", cdfVal);
        cdfVal = await cdf.gaussianCDF(BigNumber.from("10000000000000000000"), 0, BigNumber.from("1000000000000000000"));
        console.log("cdfVal x=10, mu=0, sigma=1:", cdfVal);
        cdfVal = await cdf.gaussianCDF(BigNumber.from("-10000000000000000000"), 0, BigNumber.from("1000000000000000000"));
        console.log("cdfVal x=-10, mu=0, sigma=1:", cdfVal);
    } catch (error) {
        console.error("Error:", error);
    }

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
