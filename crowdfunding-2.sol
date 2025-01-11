// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MilestoneBasedCrowdfunding {
    address public creator; 
    uint256 public goal;
    uint256 public deadline;
    mapping(address => uint256) public contributions; 
    uint256 public totalContributions;
    bool public isFunded;
    bool public isCompleted;

    struct Milestone {
        string description;
        uint256 amount;
        bool isValidated;
        uint256 approvals;
    }

    Milestone[] public milestones;
    uint256 public currentMilestoneIndex;

    address[] public approvers;
    mapping(address => mapping(uint256 => bool)) public hasApprovedMilestone; 

    uint256 public requiredApprovals;

    event GoalReached(uint256 totalContributions);
    event FundTransfer(address backer, uint256 amount);
    event DeadlineReached(uint256 totalContributions);
    event MilestoneValidated(uint256 milestoneIndex, uint256 amountReleased);
    event ApproverAdded(address approver);
    event ApproverRemoved(address approver);

    constructor(uint256 fundingGoalInEther, uint256 durationInMinutes, address[] memory _approvers, uint256 _requiredApprovals) {
        creator = msg.sender;
        goal = fundingGoalInEther * 1 ether;
        deadline = block.timestamp + durationInMinutes * 1 minutes;
        isFunded = false;
        isCompleted = false;
        currentMilestoneIndex = 0;
        
        approvers = _approvers;
        requiredApprovals = _requiredApprovals;

        
        for (uint256 i = 0; i < _approvers.length; i++) {
            for (uint256 j = 0; j < milestones.length; j++) {
                hasApprovedMilestone[_approvers[i]][j] = false;
            }
        }
    }

    modifier onlyCreator() { 
        require(msg.sender == creator, "Only the creator can call this function.");
        _;
    }

    modifier milestoneExists(uint256 milestoneIndex) {
        require(milestoneIndex < milestones.length, "Milestone does not exist.");
        _;
    }

    modifier onlyApprover() {
        require(isApprover(msg.sender), "Only an approver can call this function.");
        _;
    }

    
    function isApprover(address approver) public view returns (bool) {
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == approver) {
                return true;
            }
        }
        return false;
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "Funding period has ended.");
        require(!isCompleted, "Crowdfunding is already completed.");

        uint256 contribution = msg.value;
        contributions[msg.sender] += contribution;
        totalContributions += contribution;
        if (totalContributions >= goal) {
            isFunded = true;
            emit GoalReached(totalContributions);
        }

        emit FundTransfer(msg.sender, contribution);
    }

    function defineMilestones(string[] memory descriptions, uint256[] memory amounts) public onlyCreator {
        require(milestones.length == 0, "Milestones are already defined.");
        require(descriptions.length == amounts.length, "Descriptions and amounts must match.");
        require(totalContributions == 0, "Cannot define milestones after contributions.");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            milestones.push(Milestone(descriptions[i], amounts[i] * 1 ether, false, 0));
            totalAmount += amounts[i] * 1 ether;
        }

        require(totalAmount == goal, "Total milestone amounts must equal the funding goal.");
    }

    function approveMilestone(uint256 milestoneIndex) public milestoneExists(milestoneIndex) onlyApprover {
        require(isFunded, "Goal has not been reached.");
        require(!isCompleted, "Crowdfunding is already completed.");
        require(!milestones[milestoneIndex].isValidated, "Milestone already validated.");

        
        require(!hasApprovedMilestone[msg.sender][milestoneIndex], "You have already approved this milestone.");
        hasApprovedMilestone[msg.sender][milestoneIndex] = true;

        milestones[milestoneIndex].approvals++;

        if (milestones[milestoneIndex].approvals >= requiredApprovals) {
            
            milestones[milestoneIndex].isValidated = true;
            uint256 amountToRelease = milestones[milestoneIndex].amount;
            payable(creator).transfer(amountToRelease);
            emit MilestoneValidated(milestoneIndex, amountToRelease);

            
            currentMilestoneIndex++;

            if (currentMilestoneIndex == milestones.length) {
                isCompleted = true;
            }
        }
    }

    function getRefund() public {
        require(block.timestamp >= deadline, "Funding period has not ended.");
        require(!isFunded, "Goal has been reached.");
        require(contributions[msg.sender] > 0, "No contribution to refund.");

        uint256 contribution = contributions[msg.sender];
        contributions[msg.sender] = 0;
        totalContributions -= contribution;
        payable(msg.sender).transfer(contribution);
        emit FundTransfer(msg.sender, contribution);
    }

    function getCurrentBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function extendDeadline(uint256 durationInMinutes) public onlyCreator {
        deadline += durationInMinutes * 1 minutes;
    }

    function getMilestone(uint256 index) public view milestoneExists(index) returns (string memory, uint256, bool) {
        Milestone memory milestone = milestones[index];
        return (milestone.description, milestone.amount, milestone.isValidated);
    }

    
    function addApprover(address newApprover) public onlyCreator {
        approvers.push(newApprover);
        
        for (uint256 i = 0; i < milestones.length; i++) {
            hasApprovedMilestone[newApprover][i] = false;
        }
        emit ApproverAdded(newApprover);
    }

    
    function removeApprover(address approverToRemove) public onlyCreator {
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == approverToRemove) {
                approvers[i] = approvers[approvers.length - 1];
                approvers.pop();
                emit ApproverRemoved(approverToRemove);
                break;
            }
        }
    }
}