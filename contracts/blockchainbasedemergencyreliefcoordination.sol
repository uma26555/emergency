// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EmergencyRelief {
    address public owner;
    uint256 public totalDonations;
    
    struct ReliefFund {
        string name;
        uint256 amount;
        address recipient;
        bool isAllocated;
    }
    
    mapping(address => uint256) public donations;
    mapping(uint256 => ReliefFund) public reliefFunds;
    
    uint256 public fundCounter;

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    event DonationReceived(address indexed donor, uint256 amount);
    event FundAllocated(uint256 indexed fundId, string name, address indexed recipient, uint256 amount);

    constructor() {
        owner = msg.sender;
        fundCounter = 0;
    }

    // Allow people to donate to the relief fund
    function donate() public payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        
        donations[msg.sender] += msg.value;
        totalDonations += msg.value;
        
        emit DonationReceived(msg.sender, msg.value);
    }

    // Allow the owner to create a relief fund
    function createReliefFund(string memory name, address recipient, uint256 amount) public onlyOwner {
        require(amount <= totalDonations, "Not enough funds available");

        reliefFunds[fundCounter] = ReliefFund(name, amount, recipient, false);
        fundCounter++;
    }

    // Allow the owner to allocate funds to the relief efforts
    function allocateFunds(uint256 fundId) public onlyOwner {
        require(fundId < fundCounter, "Fund ID does not exist");
        require(!reliefFunds[fundId].isAllocated, "Fund already allocated");

        ReliefFund storage fund = reliefFunds[fundId];
        require(fund.amount <= totalDonations, "Not enough funds available");

        totalDonations -= fund.amount;
        fund.isAllocated = true;

        payable(fund.recipient).transfer(fund.amount);
        
        emit FundAllocated(fundId, fund.name, fund.recipient, fund.amount);
    }

    // View the amount of donations made by an address
    function viewDonations(address donor) public view returns (uint256) {
        return donations[donor];
    }
}

