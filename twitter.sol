// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Twitter {

    struct Tweet {
        uint tweetId;
        address author;
        string content;
        uint createdAt;
    }

    struct Message {
        uint messageId;
        string content;
        address from;
        address to;
    }

    struct User {
        address wallet;
        string name;
        uint[] userTweets;
        address[] following;
        address[] followers;
        mapping(address => Message[]) conversations;
    }

    mapping(address => User) public users;
    mapping(uint => Tweet) public tweets;

    uint256 public nextTweetId;
    uint256 public nextMessageId;

    // Codes for all functions
    
    function registerAccount(string calldata _name) external {
        bytes memory name = bytes(_name);
        require(name.length !=0 ,"Name cannot be an empty string");
        User storage newUser = users[msg.sender];
        newUser.wallet = msg.sender;
        newUser.name = _name;
    }

    function postTweet(string calldata _content) external accountExists(msg.sender) {     
        Tweet storage newTweet = tweets[nextTweetId];
        newTweet.tweetId = nextTweetId;
        newTweet.content  = _content;
        newTweet.author = msg.sender;
        newTweet.createdAt = block.timestamp;
        User storage newUser1 = users[msg.sender];
        newUser1.userTweets.push(nextTweetId);
        nextTweetId +=1;
    }

    function readTweets(address _user) view external returns(Tweet[] memory) {
        User storage newUser2 = users[_user];
        uint[] memory userTweetIds = newUser2.userTweets;
        Tweet[] memory userTweets = new Tweet[] (userTweetIds.length);
        for(uint i=0; i<userTweetIds.length; i++){
            userTweets[i]= tweets[userTweetIds[i]];
        }
        return userTweets;
    }

    modifier accountExists(address _user) {
        User storage newUser3 = users[_user];
        bytes memory newUserBytesStr = bytes(newUser3.name);
        require(newUserBytesStr.length !=0 , "This wallet does not belong to any account.");
        _;
    }

    function followUser(address _user) external {
        User storage newUser = users[msg.sender];
        newUser.following.push(_user);
        User storage newUser1 = users[_user];
        newUser1.followers.push(msg.sender);
    }

    function getFollowing() external view returns(address[] memory)  {
        return users[msg.sender].following;
    }

    function getFollowers() external view returns(address[] memory) {
        return users[msg.sender].followers;
    }

    function getTweetFeed() view external returns(Tweet[] memory) {
        Tweet[] memory feedTweets = new Tweet[] (nextTweetId);
        for(uint i=0; i<nextTweetId; i++){
            feedTweets[i] = tweets[i];
        }
        return feedTweets;
    }

    function sendMessage(address _recipient, string calldata _content) external {
        Message memory newMessage = Message(nextMessageId,_content,msg.sender,_recipient);
        User storage sender = users[msg.sender];
        sender.conversations[_recipient].push(newMessage);
        User storage recipient = users[_recipient];
        recipient.conversations[msg.sender].push(newMessage);
        nextMessageId++;
    }

    function getConversationWithUser(address _user) external view returns(Message[] memory) {
        User storage messages = users[msg.sender];
        return messages.conversations[_user];
        
    }
    
}