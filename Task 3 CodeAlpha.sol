 //SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;
contract Task3{
    uint256 public pollCount;

    struct Poll{
        string title;
        string[] options;
        uint256 endTime;
        mapping(uint256 => uint256) votes;
        mapping (address => bool) hasVoted;
        bool exists;
    }

    mapping(uint256 => Poll) private polls;

    event PollCreated(uint256 pollId , string title , uint256 endTime);
    event Voted(uint256 pollId , uint256 optionIndex , address voter);

    function createPoll (string memory _title , string[] memory _options , uint256 _durationInSeconds) external {
        require ( _options.length >= 2, "Two Options Required");
        require ( _durationInSeconds > 0 , "Duration should be greater than 0");

        pollCount++;
        Poll storage newPoll = polls[pollCount];
        newPoll.title = _title;
        newPoll.options = _options;
        newPoll.endTime = block.timestamp + _durationInSeconds;
        newPoll.exists = true;

        emit PollCreated (pollCount , _title , newPoll.endTime);
    }

    function vote(uint256 _pollId , uint256 _optionIndex) external {
        Poll storage poll = polls[_pollId];
        require(poll.exists , "Poll dosen't exist");
        require(block.timestamp < poll.endTime , "Poll has Ended");
        require(_optionIndex < poll.options.length , "Invalid option index");
        require(!poll.hasVoted[msg.sender],"Already voted");

        poll.votes[_optionIndex]++;
        poll.hasVoted[msg.sender] = true;

        emit Voted(_pollId , _optionIndex , msg.sender);
    }

    function getWinningOptions (uint256 _pollId) external view returns (uint256 winningOptionIndex , string memory winningOption){
        Poll storage poll = polls[_pollId];
        require (poll.exists , "Poll does not exist");
        require(block.timestamp >= poll.endTime , "Poll is still ongoing");

        uint256 highestVotes = 0;

        for (uint256 i = 0 ; i < poll.options.length ; i++ ) {
            uint256 optionVotes = poll.votes[i];
            if(optionVotes > highestVotes){
                highestVotes = optionVotes;
                winningOptionIndex = i;
            }
            }
            winningOption = poll.options[winningOptionIndex];
        }

        function getPoll(uint256 _pollId) external view returns(string memory title,string[] memory options,uint256 endTime,bool isEnded) {
            Poll storage poll = polls[_pollId];
            require (poll.exists , "Poll does not exist");

            title = poll.title;
            options = poll.options;
            endTime = poll.endTime;
            isEnded = block.timestamp >= endTime ;
        }

        function getVotes (uint256 _pollId) external view returns (uint256[] memory voteCounts){
            Poll storage poll = polls[_pollId];
            require(poll.exists , "Poll does not exist");
            uint256 numOptions = poll.options.length;
            voteCounts = new uint256[] (numOptions);

            for (uint256 i = 0 ; i < numOptions ; i++){
                voteCounts[i] = poll.votes[i];
            }
        }
 }
