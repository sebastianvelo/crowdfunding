// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {
    //Members
    address id;
    mapping(string => Project) public projects;
    mapping(string => Contribution[]) public contributions;

    constructor() {
        id = msg.sender;
    }

    //Enums
    enum FundraisingState {
        Opened,
        Closed
    }

    //Structs
    struct Project {
        string id;
        string name;
        string description;
        address payable author;
        FundraisingState state;
        uint256 funds;
        uint256 fundraisingGoal;
    }

    struct Contribution {
        address contributor;
        uint256 value;
    }

    //Events
    event ProjectFunded(string id, uint256 funds);

    event StateChanged(string id, FundraisingState state);

    event ProjectAdded(Project project);

    //Modifiers
    modifier projectExists(string calldata projectId) {
        require(
            bytes(projects[projectId].id).length != 0,
            "The project doesn't exist."
        );
        _;
    }
    modifier isValidFundProject(string calldata projectId, uint256 funds) {
        require(
            projects[projectId].author != msg.sender,
            "As author you can not fund your own project."
        );
        require(
            projects[projectId].state == FundraisingState.Closed,
            "You can't fund a closed project."
        );
        require(funds > 0, "Fund must be greather than ");
        _;
    }

    modifier isValidChangeState(
        string calldata projectId,
        FundraisingState newState
    ) {
        require(
            projects[projectId].author == msg.sender,
            "You need to be the project author."
        );
        require(
            projects[projectId].state != newState,
            "New state must be different."
        );
        _;
    }

    modifier isValidAddProject() {
        require(id == msg.sender, "You need to be the contract author.");
        _;
    }

    //Public functions
    function fundProject(string calldata projectId)
        public
        payable
        projectExists(projectId)
        isValidFundProject(projectId, msg.value)
    {
        projects[projectId].author.transfer(msg.value);
        projects[projectId].funds += msg.value;
        contributions[projectId].push(Contribution(msg.sender, msg.value));
        emit ProjectFunded(projectId, msg.value);
    }

    function changeState(string calldata projectId, FundraisingState newState)
        public
        projectExists(projectId)
        isValidChangeState(projectId, newState)
    {
        projects[projectId].state = newState;
        emit StateChanged(projectId, newState);
    }

    function addProject(
        string calldata projectId,
        string calldata name,
        string calldata description,
        uint256 fundraisingGoal
    ) public isValidAddProject {
        projects[projectId] = Project(
            projectId,
            name,
            description,
            payable(msg.sender),
            FundraisingState.Opened,
            0,
            fundraisingGoal
        );
        emit ProjectAdded(projects[projectId]);
    }
}
