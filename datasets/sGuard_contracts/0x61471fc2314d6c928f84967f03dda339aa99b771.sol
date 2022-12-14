pragma solidity ^0.5.9;




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

    
    function stake(Members storage members, address account, uint256 amount) internal {
        require(isMember(members, account));

        Member storage member = members.list[members.addressMap[account]];

        member.stakedTokens = member.stakedTokens.add(amount);
        members.totalStakedTokens = members.totalStakedTokens.add(amount);
    }

    
    function unstake(Members storage members, address account, uint256 amount) internal {
        require(isMember(members, account));

        Member storage member = members.list[members.addressMap[account]];

        require(member.stakedTokens >= amount);

        member.stakedTokens = member.stakedTokens.sub(amount);
        members.totalStakedTokens = members.totalStakedTokens.sub(amount);
    }

    
    function use(Members storage members, address account, uint256 amount) internal {
        require(isMember(members, account));

        Member storage member = members.list[members.addressMap[account]];

        require(member.stakedTokens >= amount);

        member.stakedTokens = member.stakedTokens.sub(amount);
        members.totalStakedTokens = members.totalStakedTokens.sub(amount);

        member.usedTokens = member.usedTokens.add(amount);
        members.totalUsedTokens = members.totalUsedTokens.add(amount);
    }

    
    function setApproved(Members storage members, address account, bool status) internal {
        require(isMember(members, account));

        Member storage member = members.list[members.addressMap[account]];

        member.approved = status;
    }

    
    function setData(Members storage members, address account, bytes32 data) internal {
        require(isMember(members, account));

        Member storage member = members.list[members.addressMap[account]];

        member.data = data;
    }

    
    function getFingerprint(address account, uint256 memberId) private pure returns (bytes9) {
        return bytes9(keccak256(abi.encodePacked(account, memberId)));
    }
}




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

    constructor (IERC1363 acceptedToken) public ERC1363Payable(acceptedToken) {} 

    
    function () external payable { 
        require(msg.value == 0);

        _newMember(msg.sender);
    }

    
    function join() external {
        _newMember(msg.sender);
    }

    
    function newMember(address account) external onlyOperator {
        _newMember(account);
    }

    
    function setApproved(address account, bool status) external onlyOperator {
        _members.setApproved(account, status);

        emit MemberStatusChanged(account, status);
    }

    
    function setData(address account, bytes32 data) external onlyOperator {
        _members.setData(account, data);
    }

    
    function use(address account, uint256 amount) external onlyDapp {
        _members.use(account, amount);

        IERC20(acceptedToken()).transfer(msg.sender, amount);

        emit TokensUsed(account, msg.sender, amount);
    }

    
    function unstake(uint256 amount) public {
        _members.unstake(msg.sender, amount);

        IERC20(acceptedToken()).transfer(msg.sender, amount);

        emit TokensUnstaked(msg.sender, amount);
    }

    
    function membersNumber() public view returns (uint256) {
        return _members.count;
    }

    
    function totalStakedTokens() public view returns (uint256) {
        return _members.totalStakedTokens;
    }

    
    function totalUsedTokens() public view returns (uint256) {
        return _members.totalUsedTokens;
    }

    
    function isMember(address account) public view returns (bool) {
        return _members.isMember(account);
    }

    
    function creationDateOf(address account) public view returns (uint256) {
        return _members.creationDateOf(account);
    }

    
    function stakedTokensOf(address account) public view returns (uint256) {
        return _members.stakedTokensOf(account);
    }

    
    function usedTokensOf(address account) public view returns (uint256) {
        return _members.usedTokensOf(account);
    }

    
    function isApproved(address account) public view returns (bool) {
        return _members.isApproved(account);
    }

    
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

    
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        if (tokenAddress == address(acceptedToken())) {
            uint256 currentBalance = IERC20(acceptedToken()).balanceOf(address(this));
            require(currentBalance.sub(_members.totalStakedTokens) >= tokenAmount);
        }

        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }

    
    function _transferReceived(
        address operator, 
        address from,
        uint256 value,
        bytes memory data 
    )
        internal
    {
        _stake(from, value);
    }

    
    function _approvalReceived(
        address owner,
        uint256 value,
        bytes memory data 
    )
        internal
    {
        IERC20(acceptedToken()).transferFrom(owner, address(this), value);

        _stake(owner, value);
    }

    
    function _newMember(address account) internal {
        uint256 memberId = _members.addMember(account);

        emit MemberAdded(account, memberId);
    }

    
    function _stake(address account, uint256 amount) internal {
        if (!isMember(account)) {
            _newMember(account);
        }

        _members.stake(account, amount);

        emit TokensStaked(account, amount);
    }
}