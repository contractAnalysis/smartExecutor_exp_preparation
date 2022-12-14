pragma solidity ^0.5.10;




library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}




interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}




library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




contract ReentrancyGuard {
    
    uint256 private _guardCounter;

    constructor () internal {
        
        
        _guardCounter = 1;
    }

    
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}




library ERC165Checker {
    
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    
    function _supportsERC165(address account) internal view returns (bool) {
        
        
        return _supportsERC165Interface(account, _INTERFACE_ID_ERC165) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    
    function _supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        
        return _supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    
    function _supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        
        if (!_supportsERC165(account)) {
            return false;
        }

        
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        
        return true;
    }

    
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        
        
        (bool success, bool result) = _callERC165SupportsInterface(account, interfaceId);

        return (success && result);
    }

    
    function _callERC165SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool success, bool result)
    {
        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_ERC165, interfaceId);

        
        assembly {
            let encodedParams_data := add(0x20, encodedParams)
            let encodedParams_size := mload(encodedParams)

            let output := mload(0x40)    
            mstore(output, 0x0)

            success := staticcall(
                30000,                   
                account,                 
                encodedParams_data,
                encodedParams_size,
                output,
                0x20                     
            )

            result := mload(output)      
        }
    }
}




interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}




contract ERC165 is IERC165 {
    
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        
        
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}




contract IERC1363 is IERC20, ERC165 {
    

    

    
    function transferAndCall(address to, uint256 value) public returns (bool);

    
    function transferAndCall(address to, uint256 value, bytes memory data) public returns (bool);

    
    function transferFromAndCall(address from, address to, uint256 value) public returns (bool);


    
    function transferFromAndCall(address from, address to, uint256 value, bytes memory data) public returns (bool);

    
    function approveAndCall(address spender, uint256 value) public returns (bool);

    
    function approveAndCall(address spender, uint256 value, bytes memory data) public returns (bool);
}




contract IERC1363Receiver {
    

    
    function onTransferReceived(address operator, address from, uint256 value, bytes memory data) public returns (bytes4); 
}




contract IERC1363Spender {
    

    
    function onApprovalReceived(address owner, uint256 value, bytes memory data) public returns (bytes4);
}




contract ERC1363Payable is IERC1363Receiver, IERC1363Spender, ERC165 {
    using ERC165Checker for address;

    
    bytes4 internal constant _INTERFACE_ID_ERC1363_RECEIVER = 0x88a7ca5c;

    
    bytes4 internal constant _INTERFACE_ID_ERC1363_SPENDER = 0x7b04a2d0;

    
    bytes4 private constant _INTERFACE_ID_ERC1363_TRANSFER = 0x4bbee2df;

    
    bytes4 private constant _INTERFACE_ID_ERC1363_APPROVE = 0xfb9ec8ce;

    event TokensReceived(
        address indexed operator,
        address indexed from,
        uint256 value,
        bytes data
    );

    event TokensApproved(
        address indexed owner,
        uint256 value,
        bytes data
    );

    
    IERC1363 private _acceptedToken;

    
    constructor(IERC1363 acceptedToken) public {
        require(address(acceptedToken) != address(0));
        require(
            acceptedToken.supportsInterface(_INTERFACE_ID_ERC1363_TRANSFER) &&
            acceptedToken.supportsInterface(_INTERFACE_ID_ERC1363_APPROVE)
        );

        _acceptedToken = acceptedToken;

        
        _registerInterface(_INTERFACE_ID_ERC1363_RECEIVER);
        _registerInterface(_INTERFACE_ID_ERC1363_SPENDER);
    }

    
    function onTransferReceived(address operator, address from, uint256 value, bytes memory data) public returns (bytes4) { 
        require(msg.sender == address(_acceptedToken));

        emit TokensReceived(operator, from, value, data);

        _transferReceived(operator, from, value, data);

        return _INTERFACE_ID_ERC1363_RECEIVER;
    }

    
    function onApprovalReceived(address owner, uint256 value, bytes memory data) public returns (bytes4) {
        require(msg.sender == address(_acceptedToken));

        emit TokensApproved(owner, value, data);

        _approvalReceived(owner, value, data);

        return _INTERFACE_ID_ERC1363_SPENDER;
    }

    
    function acceptedToken() public view returns (IERC1363) {
        return _acceptedToken;
    }

    
    function _transferReceived(address operator, address from, uint256 value, bytes memory data) internal {
        

        
    }

    
    function _approvalReceived(address owner, uint256 value, bytes memory data) internal {
        

        
    }
}




contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}




contract DAORoles is Ownable {
    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    event DappAdded(address indexed account);
    event DappRemoved(address indexed account);

    Roles.Role private _operators;
    Roles.Role private _dapps;

    constructor () internal {} 

    modifier onlyOperator() {
        require(isOperator(msg.sender));
        _;
    }

    modifier onlyDapp() {
        require(isDapp(msg.sender));
        _;
    }

    
    function isOperator(address account) public view returns (bool) {
        return _operators.has(account);
    }

    
    function isDapp(address account) public view returns (bool) {
        return _dapps.has(account);
    }

    
    function addOperator(address account) public onlyOwner {
        _addOperator(account);
    }

    
    function addDapp(address account) public onlyOperator {
        _addDapp(account);
    }

    
    function removeOperator(address account) public onlyOwner {
        _removeOperator(account);
    }

    
    function removeDapp(address account) public onlyOperator {
        _removeDapp(account);
    }

    function _addOperator(address account) internal {
        _operators.add(account);
        emit OperatorAdded(account);
    }

    function _addDapp(address account) internal {
        _dapps.add(account);
        emit DappAdded(account);
    }

    function _removeOperator(address account) internal {
        _operators.remove(account);
        emit OperatorRemoved(account);
    }

    function _removeDapp(address account) internal {
        _dapps.remove(account);
        emit DappRemoved(account);
    }
}




library Organization {
    using SafeMath for uint256;

    
    struct Member {
        uint256 id;
        address account;
        bytes9 fingerprint;
        uint256 creationDate;
        uint256 stakedTokens;
        uint256 usedTokens;
        bytes32 data;
        bool approved;
    }

    
    struct Members {
        uint256 count;
        uint256 totalStakedTokens;
        uint256 totalUsedTokens;
        mapping(address => uint256) addressMap;
        mapping(uint256 => Member) list;
    }

    
    function isMember(Members storage members, address account) internal view returns (bool) {
        return members.addressMap[account] != 0;
    }

    
    function creationDateOf(Members storage members, address account) internal view returns (uint256) {
        Member storage member = members.list[members.addressMap[account]];

        return member.creationDate;
    }

    
    function stakedTokensOf(Members storage members, address account) internal view returns (uint256) {
        Member storage member = members.list[members.addressMap[account]];

        return member.stakedTokens;
    }

    
    function usedTokensOf(Members storage members, address account) internal view returns (uint256) {
        Member storage member = members.list[members.addressMap[account]];

        return member.usedTokens;
    }

    
    function isApproved(Members storage members, address account) internal view returns (bool) {
        Member storage member = members.list[members.addressMap[account]];

        return member.approved;
    }

    
    function getMember(Members storage members, uint256 memberId) internal view returns (Member storage) {
        Member storage structure = members.list[memberId];

        require(structure.account != address(0));

        return structure;
    }

    
    function addMember(Members storage members, address account) internal returns (uint256) {
        require(account != address(0));
        require(!isMember(members, account));

        uint256 memberId = members.count.add(1);
        bytes9 fingerprint = getFingerprint(account, memberId);

        members.addressMap[account] = memberId;
        members.list[memberId] = Member(
            memberId,
            account,
            fingerprint,
            block.timestamp, 
            0,
            0,
            "",
            false
        );

        members.count = memberId;

        return memberId;
    }

    /**
     * @dev Add tokens to member stack
     * @param members Current members struct
     * @param account Address you want to stake tokens
     * @param amount Number of tokens to stake
     */
    function stake(Members storage members, address account, uint256 amount) internal {
        require(isMember(members, account));

        Member storage member = members.list[members.addressMap[account]];

        member.stakedTokens = member.stakedTokens.add(amount);
        members.totalStakedTokens = members.totalStakedTokens.add(amount);
    }

    /**
     * @dev Remove tokens from member stack
     * @param members Current members struct
     * @param account Address you want to unstake tokens
     * @param amount Number of tokens to unstake
     */
    function unstake(Members storage members, address account, uint256 amount) internal {
        require(isMember(members, account));

        Member storage member = members.list[members.addressMap[account]];

        require(member.stakedTokens >= amount);

        member.stakedTokens = member.stakedTokens.sub(amount);
        members.totalStakedTokens = members.totalStakedTokens.sub(amount);
    }

    /**
     * @dev Use tokens from member stack
     * @param members Current members struct
     * @param account Address you want to use tokens
     * @param amount Number of tokens to use
     */
    function use(Members storage members, address account, uint256 amount) internal {
        require(isMember(members, account));

        Member storage member = members.list[members.addressMap[account]];

        require(member.stakedTokens >= amount);

        member.stakedTokens = member.stakedTokens.sub(amount);
        members.totalStakedTokens = members.totalStakedTokens.sub(amount);

        member.usedTokens = member.usedTokens.add(amount);
        members.totalUsedTokens = members.totalUsedTokens.add(amount);
    }

    /**
     * @dev Set the approved status for a member
     * @param members Current members struct
     * @param account Address you want to update
     * @param status Bool the new status for approved
     */
    function setApproved(Members storage members, address account, bool status) internal {
        require(isMember(members, account));

        Member storage member = members.list[members.addressMap[account]];

        member.approved = status;
    }

    /**
     * @dev Set data for a member
     * @param members Current members struct
     * @param account Address you want to update
     * @param data bytes32 updated data
     */
    function setData(Members storage members, address account, bytes32 data) internal {
        require(isMember(members, account));

        Member storage member = members.list[members.addressMap[account]];

        member.data = data;
    }

    /**
     * @dev Generate a member fingerprint
     * @param account Address you want to make member
     * @param memberId The member id
     * @return bytes9 It represents member fingerprint
     */
    function getFingerprint(address account, uint256 memberId) private pure returns (bytes9) {
        return bytes9(keccak256(abi.encodePacked(account, memberId)));
    }
}

// File: dao-smartcontracts/contracts/dao/DAO.sol

/**
 * @title DAO
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev It identifies the DAO and Organization logic
 */
contract DAO is ERC1363Payable, DAORoles {
    using SafeMath for uint256;

    using Organization for Organization.Members;
    using Organization for Organization.Member;

    event MemberAdded(
        address indexed account,
        uint256 id
    );

    event MemberStatusChanged(
        address indexed account,
        bool approved
    );

    event TokensStaked(
        address indexed account,
        uint256 value
    );

    event TokensUnstaked(
        address indexed account,
        uint256 value
    );

    event TokensUsed(
        address indexed account,
        address indexed dapp,
        uint256 value
    );

    Organization.Members private _members;

    constructor (IERC1363 acceptedToken) public ERC1363Payable(acceptedToken) {} // solhint-disable-line no-empty-blocks

    /**
     * @dev fallback. This function will create a new member
     */
    function () external payable { // solhint-disable-line no-complex-fallback
        require(msg.value == 0);

        _newMember(msg.sender);
    }

    /**
     * @dev Generate a new member and the member structure
     */
    function join() external {
        _newMember(msg.sender);
    }

    /**
     * @dev Generate a new member and the member structure
     * @param account Address you want to make member
     */
    function newMember(address account) external onlyOperator {
        _newMember(account);
    }

    /**
     * @dev Set the approved status for a member
     * @param account Address you want to update
     * @param status Bool the new status for approved
     */
    function setApproved(address account, bool status) external onlyOperator {
        _members.setApproved(account, status);

        emit MemberStatusChanged(account, status);
    }

    /**
     * @dev Set data for a member
     * @param account Address you want to update
     * @param data bytes32 updated data
     */
    function setData(address account, bytes32 data) external onlyOperator {
        _members.setData(account, data);
    }

    /**
     * @dev Use tokens from a specific account
     * @param account Address to use the tokens from
     * @param amount Number of tokens to use
     */
    function use(address account, uint256 amount) external onlyDapp {
        _members.use(account, amount);

        IERC20(acceptedToken()).transfer(msg.sender, amount);

        emit TokensUsed(account, msg.sender, amount);
    }

    /**
     * @dev Remove tokens from member stack
     * @param amount Number of tokens to unstake
     */
    function unstake(uint256 amount) public {
        _members.unstake(msg.sender, amount);

        IERC20(acceptedToken()).transfer(msg.sender, amount);

        emit TokensUnstaked(msg.sender, amount);
    }

    /**
     * @dev Returns the members number
     * @return uint256
     */
    function membersNumber() public view returns (uint256) {
        return _members.count;
    }

    /**
     * @dev Returns the total staked tokens number
     * @return uint256
     */
    function totalStakedTokens() public view returns (uint256) {
        return _members.totalStakedTokens;
    }

    /**
     * @dev Returns the total used tokens number
     * @return uint256
     */
    function totalUsedTokens() public view returns (uint256) {
        return _members.totalUsedTokens;
    }

    /**
     * @dev Returns if an address is member or not
     * @param account Address of the member you are looking for
     * @return bool
     */
    function isMember(address account) public view returns (bool) {
        return _members.isMember(account);
    }

    /**
     * @dev Get creation date of a member
     * @param account Address you want to check
     * @return uint256 Member creation date, zero otherwise
     */
    function creationDateOf(address account) public view returns (uint256) {
        return _members.creationDateOf(account);
    }

    /**
     * @dev Check how many tokens staked for given address
     * @param account Address you want to check
     * @return uint256 Member staked tokens
     */
    function stakedTokensOf(address account) public view returns (uint256) {
        return _members.stakedTokensOf(account);
    }

    /**
     * @dev Check how many tokens used for given address
     * @param account Address you want to check
     * @return uint256 Member used tokens
     */
    function usedTokensOf(address account) public view returns (uint256) {
        return _members.usedTokensOf(account);
    }

    /**
     * @dev Check if an address has been approved
     * @param account Address you want to check
     * @return bool
     */
    function isApproved(address account) public view returns (bool) {
        return _members.isApproved(account);
    }

    /**
     * @dev Returns the member structure
     * @param memberAddress Address of the member you are looking for
     * @return array
     */
    function getMemberByAddress(address memberAddress)
        public
        view
        returns (
            uint256 id,
            address account,
            bytes9 fingerprint,
            uint256 creationDate,
            uint256 stakedTokens,
            uint256 usedTokens,
            bytes32 data,
            bool approved
        )
    {
        return getMemberById(_members.addressMap[memberAddress]);
    }

    /**
     * @dev Returns the member structure
     * @param memberId Id of the member you are looking for
     * @return array
     */
    function getMemberById(uint256 memberId)
        public
        view
        returns (
            uint256 id,
            address account,
            bytes9 fingerprint,
            uint256 creationDate,
            uint256 stakedTokens,
            uint256 usedTokens,
            bytes32 data,
            bool approved
        )
    {
        Organization.Member storage structure = _members.getMember(memberId);

        id = structure.id;
        account = structure.account;
        fingerprint = structure.fingerprint;
        creationDate = structure.creationDate;
        stakedTokens = structure.stakedTokens;
        usedTokens = structure.usedTokens;
        data = structure.data;
        approved = structure.approved;
    }

    /**
     * @dev Allow to recover tokens from contract
     * @param tokenAddress address The token contract address
     * @param tokenAmount uint256 Number of tokens to be sent
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        if (tokenAddress == address(acceptedToken())) {
            uint256 currentBalance = IERC20(acceptedToken()).balanceOf(address(this));
            require(currentBalance.sub(_members.totalStakedTokens) >= tokenAmount);
        }

        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }

    /**
     * @dev Called after validating a `onTransferReceived`
     * @param operator address The address which called `transferAndCall` or `transferFromAndCall` function
     * @param from address The address which are token transferred from
     * @param value uint256 The amount of tokens transferred
     * @param data bytes Additional data with no specified format
     */
    function _transferReceived(
        address operator, // solhint-disable-line no-unused-vars
        address from,
        uint256 value,
        bytes memory data // solhint-disable-line no-unused-vars
    )
        internal
    {
        _stake(from, value);
    }

    /**
     * @dev Called after validating a `onApprovalReceived`
     * @param owner address The address which called `approveAndCall` function
     * @param value uint256 The amount of tokens to be spent
     * @param data bytes Additional data with no specified format
     */
    function _approvalReceived(
        address owner,
        uint256 value,
        bytes memory data // solhint-disable-line no-unused-vars
    )
        internal
    {
        IERC20(acceptedToken()).transferFrom(owner, address(this), value);

        _stake(owner, value);
    }

    /**
     * @dev Generate a new member and the member structure
     * @param account Address you want to make member
     * @return uint256 The new member id
     */
    function _newMember(address account) internal {
        uint256 memberId = _members.addMember(account);

        emit MemberAdded(account, memberId);
    }

    /**
     * @dev Add tokens to member stack
     * @param account Address you want to stake tokens
     * @param amount Number of tokens to stake
     */
    function _stake(address account, uint256 amount) internal {
        if (!isMember(account)) {
            _newMember(account);
        }

        _members.stake(account, amount);

        emit TokensStaked(account, amount);
    }
}

// File: eth-token-recover/contracts/TokenRecover.sol

/**
 * @title TokenRecover
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Allow to recover any ERC20 sent into the contract for error
 */
contract TokenRecover is Ownable {

    /**
     * @dev Remember that only owner can call so be careful when use on contracts generated from other contracts.
     * @param tokenAddress The token contract address
     * @param tokenAmount Number of tokens to be sent
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
}

// File: contracts/access/roles/OperatorRole.sol

contract OperatorRole {
    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    Roles.Role private _operators;

    constructor() internal {
        _addOperator(msg.sender);
    }

    modifier onlyOperator() {
        require(isOperator(msg.sender));
        _;
    }

    function isOperator(address account) public view returns (bool) {
        return _operators.has(account);
    }

    function addOperator(address account) public onlyOperator {
        _addOperator(account);
    }

    function renounceOperator() public {
        _removeOperator(msg.sender);
    }

    function _addOperator(address account) internal {
        _operators.add(account);
        emit OperatorAdded(account);
    }

    function _removeOperator(address account) internal {
        _operators.remove(account);
        emit OperatorRemoved(account);
    }
}

// File: contracts/utils/Contributions.sol

/**
 * @title Contributions
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Utility contract where to save any information about Crowdsale contributions
 */
contract Contributions is OperatorRole, TokenRecover {
    using SafeMath for uint256;

    struct Contributor {
        uint256 weiAmount;
        uint256 tokenAmount;
        bool exists;
    }

    // the number of sold tokens
    uint256 private _totalSoldTokens;

    // the number of wei raised
    uint256 private _totalWeiRaised;

    // list of addresses who contributed in crowdsales
    address[] private _addresses;

    // map of contributors
    mapping(address => Contributor) private _contributors;

    constructor() public {} // solhint-disable-line no-empty-blocks

    /**
     * @return the number of sold tokens
     */
    function totalSoldTokens() public view returns (uint256) {
        return _totalSoldTokens;
    }

    /**
     * @return the number of wei raised
     */
    function totalWeiRaised() public view returns (uint256) {
        return _totalWeiRaised;
    }

    /**
     * @return address of a contributor by list index
     */
    function getContributorAddress(uint256 index) public view returns (address) {
        return _addresses[index];
    }

    /**
     * @dev return the contributions length
     * @return uint representing contributors number
     */
    function getContributorsLength() public view returns (uint) {
        return _addresses.length;
    }

    /**
     * @dev get wei contribution for the given address
     * @param account Address has contributed
     * @return uint256
     */
    function weiContribution(address account) public view returns (uint256) {
        return _contributors[account].weiAmount;
    }

    /**
     * @dev get token balance for the given address
     * @param account Address has contributed
     * @return uint256
     */
    function tokenBalance(address account) public view returns (uint256) {
        return _contributors[account].tokenAmount;
    }

    /**
     * @dev check if a contributor exists
     * @param account The address to check
     * @return bool
     */
    function contributorExists(address account) public view returns (bool) {
        return _contributors[account].exists;
    }

    /**
     * @dev add contribution into the contributions array
     * @param account Address being contributing
     * @param weiAmount Amount of wei contributed
     * @param tokenAmount Amount of token received
     */
    function addBalance(address account, uint256 weiAmount, uint256 tokenAmount) public onlyOperator {
        if (!_contributors[account].exists) {
            _addresses.push(account);
            _contributors[account].exists = true;
        }

        _contributors[account].weiAmount = _contributors[account].weiAmount.add(weiAmount);
        _contributors[account].tokenAmount = _contributors[account].tokenAmount.add(tokenAmount);

        _totalWeiRaised = _totalWeiRaised.add(weiAmount);
        _totalSoldTokens = _totalSoldTokens.add(tokenAmount);
    }

    /**
     * @dev remove the `operator` role from address
     * @param account Address you want to remove role
     */
    function removeOperator(address account) public onlyOwner {
        _removeOperator(account);
    }
}

// File: contracts/dealer/TokenDealer.sol

/**
 * @title TokenDealer
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev TokenDealer is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether.
 */
contract TokenDealer is ReentrancyGuard, TokenRecover {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    uint256 private _rate;

    // Address where funds are collected
    address payable private _wallet;

    // The token being sold
    IERC20 private _token;

    // the DAO smart contract
    DAO private _dao;

    // reference to Contributions contract
    Contributions private _contributions;

    /**
     * Event for token purchase logging
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * @param rate Number of token units a buyer gets per wei
     * @param wallet Address where collected funds will be forwarded to
     * @param token Address of the token being sold
     * @param contributions Address of the contributions contract
     * @param dao DAO the decentralized organization address
     */
    constructor(
        uint256 rate,
        address payable wallet,
        address token,
        address contributions,
        address payable dao
    )
        public
    {
        require(rate > 0, "TokenDealer: rate is 0");
        require(wallet != address(0), "TokenDealer: wallet is the zero address");
        require(token != address(0), "TokenDealer: token is the zero address");
        require(contributions != address(0), "TokenDealer: contributions is the zero address");
        require(dao != address(0), "TokenDealer: dao is the zero address");

        _rate = rate;
        _wallet = wallet;
        _token = IERC20(token);
        _contributions = Contributions(contributions);
        _dao = DAO(dao);
    }

    
    function () external payable {
        buyTokens();
    }

    
    function buyTokens() public nonReentrant payable {
        address beneficiary = msg.sender;
        uint256 weiAmount = msg.value;

        require(weiAmount != 0, "TokenDealer: weiAmount is 0");

        
        uint256 tokenAmount = _getTokenAmount(beneficiary, weiAmount);

        _token.safeTransfer(beneficiary, tokenAmount);

        emit TokensPurchased(beneficiary, weiAmount, tokenAmount);

        _contributions.addBalance(beneficiary, weiAmount, tokenAmount);

        _wallet.transfer(weiAmount);
    }

    
    function setRate(uint256 newRate) public onlyOwner {
        require(newRate > 0, "TokenDealer: rate is 0");
        _rate = newRate;
    }

    
    function rate() public view returns (uint256) {
        return _rate;
    }

    
    function wallet() public view returns (address payable) {
        return _wallet;
    }

    
    function token() public view returns (IERC20) {
        return _token;
    }

    
    function contributions() public view returns (Contributions) {
        return _contributions;
    }

    
    function dao() public view returns (DAO) {
        return _dao;
    }

    
    function expectedTokenAmount(address beneficiary, uint256 weiAmount) public view returns (uint256) {
        return _getTokenAmount(beneficiary, weiAmount);
    }

    
    function _getTokenAmount(address beneficiary, uint256 weiAmount) internal view returns (uint256) {
        uint256 tokenAmount = weiAmount.mul(_rate);

        if (_dao.isMember(beneficiary)) {
            tokenAmount = tokenAmount.mul(2);

            if (_dao.stakedTokensOf(beneficiary) > 0) {
                tokenAmount = tokenAmount.mul(2);
            }

            if (_dao.usedTokensOf(beneficiary) > 0) {
                tokenAmount = tokenAmount.mul(2);
            }
        }

        return tokenAmount;
    }
}