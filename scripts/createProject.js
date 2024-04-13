// Import the ethers library
const { ethers } = require("ethers");

// Contract ABI (Application Binary Interface)
const contractABI = [
    // Read-only method to get remaining time for project funding deadline
    "function getRemainingTime(uint _projectId) view returns(uint)",
    // Variable to track total projects created
    "uint public totalProjects",
    // Function to enhance the deadline for a project
    "function enhanceDeadline(uint _projectId, uint _additionalSeconds)",
    // Function to return the number of projects which raised successful funding
    "function getSuccessfulProjects() view returns(uint)",
    // Function to return the number of projects which failed to raise enough funds
    "function getFailedProjects() view returns(uint)",
    // Function to fund a project
    "function fundProject(uint _projectId) payable",
    // Function to withdraw system commission
    "function withdrawCommission()"
];

// Contract address
const contractAddress = "YOUR_CONTRACT_ADDRESS";

// Provider (Infura, Alchemy, etc.)
const provider = new ethers.providers.JsonRpcProvider("YOUR_JSON_RPC_PROVIDER_URL");

// Wallet connected to provider (Can be replaced with private key if needed)
const wallet = new ethers.Wallet("YOUR_PRIVATE_KEY", provider);

// Contract instance
const contract = new ethers.Contract(contractAddress, contractABI, wallet);

// Function to get remaining time for project funding deadline
async function getRemainingTime(projectId) {
    try {
        const remainingTime = await contract.getRemainingTime(projectId);
        console.log("Remaining time for project ID", projectId, ":", remainingTime);
    } catch (error) {
        console.error("Error getting remaining time:", error);
    }
}

// Function to enhance the deadline for a project
async function enhanceDeadline(projectId, additionalSeconds) {
    try {
        await contract.enhanceDeadline(projectId, additionalSeconds);
        console.log("Deadline for project ID", projectId, "enhanced successfully");
    } catch (error) {
        console.error("Error enhancing deadline:", error);
    }
}

// Function to fund a project
async function fundProject(projectId, amountInEth) {
    try {
        // Convert amount to wei
        const amountInWei = ethers.utils.parseEther(amountInEth);
        const tx = await contract.fundProject(projectId, { value: amountInWei });
        await tx.wait();
        console.log("Funded project ID", projectId, "with", amountInEth, "ETH successfully");
    } catch (error) {
        console.error("Error funding project:", error);
    }
}

// Function to withdraw system commission
async function withdrawCommission() {
    try {
        const tx = await contract.withdrawCommission();
        await tx.wait();
        console.log("Commission withdrawn successfully");
    } catch (error) {
        console.error("Error withdrawing commission:", error);
    }
}

// Example function calls
// Replace with actual project ID, amount, and additional seconds
getRemainingTime(1);
enhanceDeadline(1, 3600); // Add 1 hour to project ID 1's deadline
fundProject(1, "1"); // Fund project ID 1 with 1 ETH
withdrawCommission();
