// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdTank {
    address public owner; // Add a state variable to store the contract owner

    // Add a constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // struct to store project details
    struct Project {
        address creator;
        string name;
        string description;
        uint fundingGoal;
        uint deadline;
        uint amountRaised;
        bool funded;
        mapping(address => uint) contributions; // Mapping to store contributions for each project
    }

    // projectId => project details
    mapping(uint => Project) public projects;

    // projectId => whether the id is used or not
    mapping(uint => bool) public isIdUsed;

    // Total number of projects created
    uint public totalProjects;

    // Total number of funded projects
    uint public totalFundedProjects;

    // Total commission collected by the system
    uint public systemCommission;

    // events
    event ProjectCreated(uint indexed projectId, address indexed creator, string name, string description, uint fundingGoal, uint deadline);
    event ProjectFunded(uint indexed projectId, address indexed contributor, uint amount);
    event FundsWithdrawn(uint indexed projectId, address indexed withdrawer, uint amount, string withdrawerType);
    // withdrawerType = "user" ,= "admin"

    // create project by a creator
    function createProject(string memory _name, string memory _description, uint _fundingGoal, uint _durationSeconds, uint _id) external {
        require(!isIdUsed[_id], "Project Id is already used");
        isIdUsed[_id] = true;
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

    // Function to fund a project
    function fundProject(uint _projectId) external payable {
        Project storage project = projects[_projectId];
        require(block.timestamp <= project.deadline, "Project deadline is already passed");
        require(!project.funded, "Project is already funded");
        require(msg.value > 0, "Must send some value of ether");

        // Calculate commission
        uint commission = (msg.value * 5) / 100;
        systemCommission += commission;

        // Deduct commission from the contributed amount
        uint contributionAmount = msg.value - commission;

        project.amountRaised += contributionAmount;
        project.contributions[msg.sender] += contributionAmount; // Update user contributions
        emit ProjectFunded(_projectId, msg.sender, contributionAmount);
        
        if (project.amountRaised >= project.fundingGoal) {
            project.funded = true;
            totalFundedProjects++;
        }
    }

    // Function to withdraw funds by the project creator
    function userWithdrawFunds(uint _projectId) external payable {
        Project storage project = projects[_projectId];
        require(!project.funded && project.deadline <= block.timestamp, "Funding goal is reached or deadline not passed");
        uint fundContributed = project.contributions[msg.sender]; // Retrieve user's contribution
        payable(msg.sender).transfer(fundContributed);
        emit FundsWithdrawn(_projectId, msg.sender, fundContributed, "user");
    }

    // Function to withdraw funds by the admin
    function adminWithdrawFunds(uint _projectId) external payable {
        Project storage project = projects[_projectId];
        require(project.funded, "Project is not funded yet");
        require(project.creator == msg.sender, "Only project admin can withdraw");
        require(project.deadline <= block.timestamp, "Deadline for project is not reached");
        payable(msg.sender).transfer(project.amountRaised);
        emit FundsWithdrawn(_projectId, msg.sender, project.amountRaised, "admin");
    }

    // Function to enhance deadline for a project
    function enhanceDeadline(uint _projectId, uint _additionalSeconds) external {
        Project storage project = projects[_projectId];
        require(project.creator == msg.sender, "Only project creator can enhance deadline");
        project.deadline += _additionalSeconds;
    }

    // Function to get remaining time for project funding deadline
    function getRemainingTime(uint _projectId) external view returns(uint) {
        if (block.timestamp > projects[_projectId].deadline) {
            return 0;
        } else {
            return projects[_projectId].deadline - block.timestamp;
        }
    }

    // Function to get the total number of successful projects
    function getSuccessfulProjects() external view returns(uint) {
        return totalFundedProjects;
    }

    // Function to get the total number of failed projects
    function getFailedProjects() external view returns(uint) {
        return totalProjects - totalFundedProjects;
    }

    // Function to charge a 5% commission on each funding and allow the system admin to withdraw the commission collected
    function chargeCommission() external payable {
       require(msg.value > 0, "Must send some value of ether");
       systemCommission += (msg.value * 5) / 100;
    }

    // Function to get the total commission collected by the system
    function commissionCollected() external view returns(uint) {
        return systemCommission;
    }

    // Function to allow the system admin to withdraw the commission collected
    function withdrawCommission() external {
        require(msg.sender == owner, "Only owner can withdraw commission");
        payable(msg.sender).transfer(systemCommission);
        systemCommission = 0;
    }

    // Function to get the total number of projects created
    function getTotalProjects() external view returns (uint) {
        return totalProjects;
    }
}
