const hre = require("hardhat");

async function main() {
  try {
    // Ensure ethers object is imported correctly
    // if (!ethers) {
    //   throw new Error("Hardhat ethers object not found.");
    // }

    // We get the contract to deploy
    // const CrowdTank = await hre.ethers.getContractFactory("CrowdTank");


    const CrowdTank = await hre.ethers.getContractFactory("CrowdTank");

    if (!CrowdTank) {
      throw new Error("Contract factory not found.");
    }

    // Define gas price and gas limit
    const gasPrice = hre.ethers.utils.parseUnits('20', 'gwei'); // Example gas price in gwei
    const gasLimit = 3000000; // Example gas limit

    // Deploy the contract with gas price and gas limit
    const crowdTank = await CrowdTank.deploy({ gasPrice, gasLimit });

    // Check if deployment failed
    if (!crowdTank) {
      throw new Error("Deployment failed.");
    }

    // Wait for deployment to be confirmed
    await crowdTank.deployed();

    console.log("CrowdTank deployed to:", crowdTank.address);

    // Additional functionality...

  } catch (error) {
    console.error("Error deploying contract:", error);
    process.exit(1); // Exit with non-zero status to indicate failure
  }
}

// Execute the deploy function
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Uncaught error:", error);
    process.exit(1);
  });
