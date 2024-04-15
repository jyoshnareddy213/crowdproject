const { ethers } = require("hardhat");

// Update the contract address with the deployed address
const contractAddr = "0x39a858E90F8F65f3e85bb441ce06DDd92EC41e7c"; // Update with deployed contract address

async function main() {
  const CrowdTank = await ethers.getContractFactory("CrowdTank");
  const crowdTank = await CrowdTank.attach(contractAddr);

  // Get the project ID from command-line arguments
  const projectId = process.argv[2];

  // Call the getRemainingTime function with the provided project ID
  const remainingTime = await crowdTank.getRemainingTime(2335);

  // Log the result to the console
  console.log("Remaining Time:", remainingTime.toString());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
