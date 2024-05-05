// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdTank {
    address public owner; // Contract owner
    address public admin; // Admin address
    mapping(address => bool) public creators; // Mapping to store creators
    uint public systemCommission; // Total commission collected by the system
    uint public initialBalance;

    // Modifier to check if the caller is the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    } 

    // Modifier to check if the caller is the project creator
    modifier onlyCreator(uint _projectId) {
        require(projects[_projectId].creator == msg.sender, "Only project creator can perform this action");
        _;
    }

    struct Project {
        address creator;
        string name;
        string description;
        uint fundingGoal;
        uint deadline;
        uint amountRaised;
        bool funded;
        address highestFunder;
        mapping(address => uint) contributions;
    }

    mapping(uint => Project) public projects;
    mapping(uint => bool) public isIdUsed;
    uint public totalProjects;
    uint public totalFundedProjects;
    // Review info: variable not used
    uint public totalFailedProjects;

    event ProjectCreated(uint indexed projectId, address indexed creator, string name, string description, uint fundingGoal, uint deadline);
    event ProjectFunded(uint indexed projectId, address indexed contributor, uint amount);
    event FundsWithdrawn(uint indexed projectId, address indexed withdrawer, uint amount, string withdrawerType);
    event CreatorAdded(address indexed creator);
    event CreatorRemoved(address indexed creator);
    event DeadlineEnhanced(uint indexed projectId, uint additionalSeconds);
    event FundingSuccessful(uint indexed projectId);
    event FundingFailed(uint indexed projectId);
    event ContractBalanceIncreased(address indexed sender, uint amount); // Event to log the increase in contract balance

    constructor() payable {
        owner = msg.sender;
        admin = msg.sender;
        initialBalance = msg.value;
    }

    // Function to create a new project

    // Review info: onlyCreator modifier not used here,it is mentioned to use that in tasks list
    function createProject(string memory _name, string memory _description, uint _fundingGoal, uint _durationSeconds, uint _id) external {
        require(!isIdUsed[_id], "Project Id is already used");
        isIdUsed[_id] = true;
        require(creators[msg.sender], "Only added creators can create a project");
        projects[_id].creator = msg.sender;
        projects[_id].name = _name;
        projects[_id].description = _description;
        projects[_id].fundingGoal = _fundingGoal;
        projects[_id].deadline = block.timestamp + _durationSeconds;
        projects[_id].amountRaised = 0;
        projects[_id].funded = false;

        emit ProjectCreated(_id, msg.sender, _name, _description, _fundingGoal, block.timestamp + _durationSeconds);
        totalProjects++;
    }

    // Function to set contributions manually for testing purposes
    // Review info: this function is not required 
    function setContribution(uint _projectId, address _backer, uint _amount) external onlyCreator(_projectId) {
        projects[_projectId].contributions[_backer] = _amount;
    }

    // Function to fund a project
    function fundProject(uint _projectId) external payable {
        Project storage project = projects[_projectId];
        require(!project.funded, "Project is already funded");
        require(msg.value > 0, "Must send some value of ether");
        require(project.deadline > block.timestamp, "Project deadline has passed");

        // Review Info: not necessary feature
        require(project.contributions[msg.sender] > 0, "Only backers can fund the project");

        // Calculate commission
        uint256 commission = (msg.value * 5) / 100; // 5% commission
        uint256 contributionAmount = msg.value - commission;

        // Add commission to system commission
        systemCommission += commission;

        // Update amountRaised for the project
        project.amountRaised += contributionAmount;
        emit ProjectFunded(_projectId, msg.sender, contributionAmount);

        // Check if funding goal is reached
        if (project.amountRaised >= project.fundingGoal) {
            project.funded = true;
            totalFundedProjects++;
            emit FundingSuccessful(_projectId);
        }

        // Update highest funder if applicable
        if (project.contributions[msg.sender] > project.contributions[project.highestFunder]) {
            project.highestFunder = msg.sender;
        }
    }

    // Function for backers to withdraw their funds if the project is not funded and the deadline has passed
    function userWithdrawFunds(uint _projectId) external {
        Project storage project = projects[_projectId];
        require(!project.funded, "Project is already funded");
        require(project.deadline <= block.timestamp, "Project deadline has not passed yet");
        uint fundContributed = project.contributions[msg.sender];
        require(fundContributed > 0, "You have not contributed to this project");

        // Ensure that the contract has enough balance to cover the withdrawal
        require(address(this).balance >= fundContributed, "Contract balance is insufficient");

        // Transfer the funds to the user
        project.contributions[msg.sender] = 0; // Clear the user's contribution
        payable(msg.sender).transfer(fundContributed);

        emit FundsWithdrawn(_projectId, msg.sender, fundContributed, "user");
    }

    // Function for the admin to withdraw the raised funds for a project after it has been successfully funded
    function adminWithdrawFunds(uint _projectId) external onlyAdmin {
        Project storage project = projects[_projectId];
        require(project.funded, "Project is not funded yet");
        uint raisedFunds = project.amountRaised;
        payable(admin).transfer(raisedFunds);
        emit FundsWithdrawn(_projectId, admin, raisedFunds, "admin");
        project.amountRaised = 0; // Clear the project's raised funds
    }

    // Function to add a creator by admin
    function addCreator(address _creator) external onlyAdmin {
        creators[_creator] = true;
        emit CreatorAdded(_creator);
    }

    // Function to remove a creator by admin
    function removeCreator(address _creator) external onlyAdmin {
        creators[_creator] = false;
        emit CreatorRemoved(_creator);
    }

    // Function to enhance deadline by project creator
    function enhanceDeadline(uint _projectId, uint _additionalSeconds) external onlyCreator(_projectId) {
        projects[_projectId].deadline += _additionalSeconds;
        emit DeadlineEnhanced(_projectId, _additionalSeconds);
    }

    // Function to get remaining time for funding deadline
    function getRemainingTime(uint _projectId) external view returns (uint) {
        if (block.timestamp > projects[_projectId].deadline) {
            return 0;
        } else {
            return projects[_projectId].deadline - block.timestamp;
        }
    }

    // Function to get count of successful projects
    function getSuccessfulProjectsCount() external view returns (uint) {
        return totalFundedProjects;
    }

    // Function to get count of failed projects
    function getFailedProjectsCount() external view returns (uint) {
        return totalProjects - totalFundedProjects;
    }

    // Function to get total system commission
    function getTotalSystemCommission() external view returns (uint) {
        return systemCommission;
    }

    // Function for admin to withdraw system commission
    function withdrawCommission() external onlyAdmin {
        payable(admin).transfer(systemCommission);
        systemCommission = 0;
    }

    // Function to check the current balance of the contract
    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    // Function to check the initial balance of the contract
    function getInitialBalance() external view returns (uint) {
        return initialBalance;
    }

    // Function to increase the contract balance
    // Review Info:not required
    function increaseContractBalance() external payable onlyAdmin {
        // Ensure that Ether is sent along with the transaction
        require(msg.value > 0, "No Ether sent with the transaction");

        // Log the increase in contract balance
        emit ContractBalanceIncreased(msg.sender, msg.value);
    }
    
    // Function to get the address of the highest funder for a project
    function getHighestFunder(uint _projectId) external view returns (address) {
        return projects[_projectId].highestFunder;
    }
}

