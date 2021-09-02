// File: contracts/v1-mining/interface/IGameFiInviteV1.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

interface IGameFiInviteV1 {

    struct UserInfo {
        address upper;
        address[] lowers;
        uint256 startBlock;
    }

    event InviteV1(address indexed owner, address indexed upper, uint256 indexed height);

    function inviteCount() external view returns (uint256);

    function inviteUpper1(address) external view returns (address);

    function inviteLower1(address) external view returns (address[] memory);

    function register() external returns (bool);

    function acceptInvitation(address) external returns (bool);
    

}

// File: contracts/v1-mining/library/ErrorCode.sol


pragma solidity 0.7.4;

library ErrorCode {

    string constant FORBIDDEN = 'GameFi:FORBIDDEN';
    string constant IDENTICAL_ADDRESSES = 'GameFi:IDENTICAL_ADDRESSES';
    string constant ZERO_ADDRESS = 'GameFi:ZERO_ADDRESS';
    string constant INVALID_ADDRESSES = 'GameFi:INVALID_ADDRESSES';
    string constant BALANCE_INSUFFICIENT = 'GameFi:BALANCE_INSUFFICIENT';
    string constant REWARDTOTAL_LESS_THAN_REWARDPROVIDE = 'GameFi:REWARDTOTAL_LESS_THAN_REWARDPROVIDE';
    string constant PARAMETER_TOO_LONG = 'GameFi:PARAMETER_TOO_LONG';
    string constant REGISTERED = 'GameFi:REGISTERED';
    string constant MINING_NOT_STARTED = 'GameFi:MINING_NOT_STARTED';
    string constant END_OF_MINING = 'GameFi:END_OF_MINING';
    string constant POOL_NOT_EXIST_OR_END_OF_MINING = 'GameFi:POOL_NOT_EXIST_OR_END_OF_MINING';
    
}

// File: contracts/v1-mining/implement/GameFiInviteV1.sol


pragma solidity 0.7.4;



contract GameFiInviteV1 is IGameFiInviteV1 {

    address public constant ZERO = address(0);
    uint256 public startBlock;
    address[] public inviteUserInfoV1;
    mapping(address => UserInfo) public inviteUserInfoV2;

    constructor () {
        startBlock = block.number;
    }
    
    function inviteCount() override external view returns (uint256) {
        return inviteUserInfoV1.length;
    }

    function inviteUpper1(address _owner) override external view returns (address) {
        return inviteUserInfoV2[_owner].upper;
    }


    function inviteLower1(address _owner) override external view returns (address[] memory) {
        return inviteUserInfoV2[_owner].lowers;
    }

    function register() override external returns (bool) {
        UserInfo storage user = inviteUserInfoV2[tx.origin];
        require(0 == user.startBlock, ErrorCode.REGISTERED);
        user.upper = ZERO;
        user.startBlock = block.number;
        inviteUserInfoV1.push(tx.origin);
        
        emit InviteV1(tx.origin, user.upper, user.startBlock);
        
        return true;
    }

    function acceptInvitation(address _inviter) override external returns (bool) {
        require(msg.sender != _inviter, ErrorCode.FORBIDDEN);
        UserInfo storage user = inviteUserInfoV2[msg.sender];
        require(0 == user.startBlock, ErrorCode.REGISTERED);
        UserInfo storage upper = inviteUserInfoV2[_inviter];
        if (0 == upper.startBlock) {
            upper.upper = ZERO;
            upper.startBlock = block.number;
            inviteUserInfoV1.push(_inviter);
            
            emit InviteV1(_inviter, upper.upper, upper.startBlock);
        }
        user.upper = _inviter;
        upper.lowers.push(msg.sender);
        user.startBlock = block.number;
        inviteUserInfoV1.push(msg.sender);
        
        emit InviteV1(msg.sender, user.upper, user.startBlock);

        return true;
    }


}
