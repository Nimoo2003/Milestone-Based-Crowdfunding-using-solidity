# Milestone-Based Crowdfunding

A decentralized crowdfunding platform on Ethereum that supports milestone-based fund release. The contract allows a creator to set up a funding goal, a deadline, and define milestones with conditions for fund release. Approvers validate the milestones before the funds are transferred to the creator.

## Features

- **Funding Goal and Deadline**: Set a specific funding goal (in Ether) and a deadline (in minutes) for the campaign.
- **Contributions**: Anyone can contribute funds until the deadline is reached.
- **Milestones**: Define multiple milestones, each with an associated amount of funds to be released.
- **Approvals**: A predefined set of approvers validate each milestone. A milestone is only validated and funds are released after receiving enough approvals.
- **Refunds**: If the goal isn't reached by the deadline, contributors can request a refund.
- **Creator Controls**: The creator can add or remove approvers, extend the campaign deadline, and define the milestones before contributions are allowed.

## Contract Overview

### Main Functions

1. **contribute()**: Allows users to contribute funds to the campaign.
2. **defineMilestones()**: The creator sets up milestones for the campaign.
3. **approveMilestone()**: Approvers validate milestones, triggering fund transfers to the creator.
4. **getRefund()**: Allows contributors to request a refund if the goal is not met.
5. **extendDeadline()**: The creator can extend the deadline for the campaign.
6. **addApprover()**: Adds a new approver to validate milestones.
7. **removeApprover()**: Removes an existing approver from the campaign.

### Modifiers

- **onlyCreator**: Restricts a function to be called by the contract creator only.
- **milestoneExists**: Ensures that the specified milestone exists.
- **onlyApprover**: Ensures that only approvers can call certain functions.

### Events

- **GoalReached**: Emitted when the funding goal is reached.
- **FundTransfer**: Emitted when a contribution or refund occurs.
- **DeadlineReached**: Emitted when the deadline has passed.
- **MilestoneValidated**: Emitted when a milestone is validated, and funds are released.
- **ApproverAdded**: Emitted when an approver is added.
- **ApproverRemoved**: Emitted when an approver is removed.

## Contract Deployment

### Constructor Parameters

- `fundingGoalInEther`: The funding goal for the campaign in Ether.
- `durationInMinutes`: The duration of the campaign in minutes.
- `_approvers`: List of initial approvers who will validate milestones.
- `requiredApprovals`: The number of approvals required to validate a milestone.

## Example Usage

1. **Deploy Contract**: Deploy the contract with the desired funding goal, duration, approvers, and required approvals.
2. **Define Milestones**: The creator defines milestones once contributions begin.
3. **Contribute**: Backers can contribute funds to the campaign.
4. **Approve Milestones**: Approvers validate each milestone once enough contributions are gathered.
5. **Release Funds**: Funds are released to the creator after the milestone is validated by enough approvers.
6. **Get Refund**: If the funding goal is not met by the deadline, contributors can get a refund.

## Security Considerations

- Only the contract creator can define the milestones before contributions begin.
- Only approvers can validate milestones, ensuring a decentralized decision-making process for fund releases.
- The contract allows contributors to receive a refund if the funding goal is not met by the deadline.

## Limitations

- The contract requires a minimum number of approvers to validate milestones, so if there are not enough approvers, the milestones cannot be validated.
- The contract is designed for use cases where funds are disbursed after specific milestones are reached. It is not suitable for campaigns without milestone validation.

## Photos

![WhatsApp Image 2025-01-11 at 05 58 36_153f43de](https://github.com/user-attachments/assets/4e3f03d0-671e-4ef1-94f4-ae3558c308a7)

