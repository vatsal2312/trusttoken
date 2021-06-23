/*
    .'''''''''''..     ..''''''''''''''''..       ..'''''''''''''''..
    .;;;;;;;;;;;'.   .';;;;;;;;;;;;;;;;;;,.     .,;;;;;;;;;;;;;;;;;,.
    .;;;;;;;;;;,.   .,;;;;;;;;;;;;;;;;;;;,.    .,;;;;;;;;;;;;;;;;;;,.
    .;;;;;;;;;,.   .,;;;;;;;;;;;;;;;;;;;;,.   .;;;;;;;;;;;;;;;;;;;;,.
    ';;;;;;;;'.  .';;;;;;;;;;;;;;;;;;;;;;,. .';;;;;;;;;;;;;;;;;;;;;,.
    ';;;;;,..   .';;;;;;;;;;;;;;;;;;;;;;;,..';;;;;;;;;;;;;;;;;;;;;;,.
    ......     .';;;;;;;;;;;;;,'''''''''''.,;;;;;;;;;;;;;,'''''''''..
              .,;;;;;;;;;;;;;.           .,;;;;;;;;;;;;;.
             .,;;;;;;;;;;;;,.           .,;;;;;;;;;;;;,.
            .,;;;;;;;;;;;;,.           .,;;;;;;;;;;;;,.
           .,;;;;;;;;;;;;,.           .;;;;;;;;;;;;;,.     .....
          .;;;;;;;;;;;;;'.         ..';;;;;;;;;;;;;'.    .',;;;;,'.
        .';;;;;;;;;;;;;'.         .';;;;;;;;;;;;;;'.   .';;;;;;;;;;.
       .';;;;;;;;;;;;;'.         .';;;;;;;;;;;;;;'.    .;;;;;;;;;;;,.
      .,;;;;;;;;;;;;;'...........,;;;;;;;;;;;;;;.      .;;;;;;;;;;;,.
     .,;;;;;;;;;;;;,..,;;;;;;;;;;;;;;;;;;;;;;;,.       ..;;;;;;;;;,.
    .,;;;;;;;;;;;;,. .,;;;;;;;;;;;;;;;;;;;;;;,.          .',;;;,,..
   .,;;;;;;;;;;;;,.  .,;;;;;;;;;;;;;;;;;;;;;,.              ....
    ..',;;;;;;;;,.   .,;;;;;;;;;;;;;;;;;;;;,.
       ..',;;;;'.    .,;;;;;;;;;;;;;;;;;;;'.
          ...'..     .';;;;;;;;;;;;;;,,,'.
                       ...............
*/

// https://github.com/trusttoken/smart-contracts
// Dependency file: @openzeppelin/contracts/GSN/Context.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// Dependency file: contracts/common/Initializable.sol

// Copied from https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package/blob/v3.0.0/contracts/Initializable.sol
// Added public isInitialized() view of private initialized bool.

// pragma solidity 0.6.10;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    /**
     * @dev Return true if and only if the contract has been initialized
     * @return whether the contract has been initialized
     */
    function isInitialized() public view returns (bool) {
        return initialized;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}


// Dependency file: contracts/common/UpgradeableClaimable.sol

// pragma solidity 0.6.10;

// import {Context} from "@openzeppelin/contracts/GSN/Context.sol";

// import {Initializable} from "contracts/common/Initializable.sol";

/**
 * @title UpgradeableClaimable
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. Since
 * this contract combines Claimable and UpgradableOwnable contracts, ownership
 * can be later change via 2 step method {transferOwnership} and {claimOwnership}
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract UpgradeableClaimable is Initializable, Context {
    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting a custom initial owner of choice.
     * @param __owner Initial owner of contract to be set.
     */
    function initialize(address __owner) internal initializer {
        _owner = __owner;
        emit OwnershipTransferred(address(0), __owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Modifier throws if called by any account other than the pendingOwner.
     */
    modifier onlyPendingOwner() {
        require(msg.sender == _pendingOwner, "Ownable: caller is not the pending owner");
        _;
    }

    /**
     * @dev Allows the current owner to set the pendingOwner address.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _pendingOwner = newOwner;
    }

    /**
     * @dev Allows the pendingOwner address to finalize the transfer.
     */
    function claimOwnership() public onlyPendingOwner {
        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0);
    }
}


// Dependency file: contracts/proxy/interface/IOwnedUpgradeabilityProxy.sol

// pragma solidity 0.6.10;

interface IOwnedUpgradeabilityProxy {
    function proxyOwner() external view returns (address owner);

    function pendingProxyOwner() external view returns (address pendingOwner);

    function transferProxyOwnership(address newOwner) external;

    function claimProxyOwnership() external;

    function upgradeTo(address implementation) external;

    function implementation() external view returns (address impl);
}


// Dependency file: contracts/proxy/ImplementationReference.sol

// pragma solidity 0.6.10;

// import {UpgradeableClaimable} from "contracts/common/UpgradeableClaimable.sol";

/**
 * @title ImplementationReference
 * @dev This contract is made to serve a simple purpose only.
 * To hold the address of the implementation contract to be used by proxy.
 * The implementation address, is changeable anytime by the owner of this contract.
 */
contract ImplementationReference is UpgradeableClaimable {
    address public implementation;

    /**
     * @dev Event to show that implementation address has been changed
     * @param newImplementation New address of the implementation
     */
    event ImplementationChanged(address newImplementation);

    /**
     * @dev Set initial ownership and implementation address
     * @param _implementation Initial address of the implementation
     */
    constructor(address _implementation) public {
        UpgradeableClaimable.initialize(msg.sender);
        implementation = _implementation;
    }

    /**
     * @dev Function to change the implementation address, which can be called only by the owner
     * @param newImplementation New address of the implementation
     */
    function setImplementation(address newImplementation) external onlyOwner {
        implementation = newImplementation;
        emit ImplementationChanged(newImplementation);
    }
}


// Dependency file: contracts/common/interface/IPauseableContract.sol


// pragma solidity 0.6.10;

/**
 * @dev interface to allow standard pause function
 */
interface IPauseableContract {
    function setPauseStatus(bool pauseStatus) external;
}


// Dependency file: contracts/governance/interface/ITimelock.sol


// pragma solidity ^0.6.10;

// import {IOwnedUpgradeabilityProxy} from "contracts/proxy/interface/IOwnedUpgradeabilityProxy.sol";
// import {ImplementationReference} from "contracts/proxy/ImplementationReference.sol";
// import {IPauseableContract} from "contracts/common/interface/IPauseableContract.sol";

interface ITimelock {
    function delay() external view returns (uint256);

    function GRACE_PERIOD() external view returns (uint256);

    function acceptAdmin() external;

    function queuedTransactions(bytes32 hash) external view returns (bool);

    function queueTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external returns (bytes32);

    function cancelTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external;

    function executeTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external payable returns (bytes memory);

    function emergencyPauseProxy(IOwnedUpgradeabilityProxy proxy) external;

    function emergencyPauseReference(ImplementationReference implementationReference) external;

    function setPauseStatus(IPauseableContract pauseContract, bool status) external;
}


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// Dependency file: contracts/governance/interface/IVoteToken.sol

// pragma solidity ^0.6.10;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVoteToken {
    function delegate(address delegatee) external;

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function getCurrentVotes(address account) external view returns (uint96);

    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint96);
}

interface IVoteTokenWithERC20 is IVoteToken, IERC20 {}


// Root file: contracts/governance/Pauser.sol

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

// import {UpgradeableClaimable} from "contracts/common/UpgradeableClaimable.sol";
// import {ITimelock} from "contracts/governance/interface/ITimelock.sol";
// import {IVoteToken} from "contracts/governance/interface/IVoteToken.sol";
// import {IOwnedUpgradeabilityProxy} from "contracts/proxy/interface/IOwnedUpgradeabilityProxy.sol";
// import {ImplementationReference} from "contracts/proxy/ImplementationReference.sol";
// import {IPauseableContract} from "contracts/common/interface/IPauseableContract.sol";

contract Pauser is UpgradeableClaimable {
    // ================ WARNING ==================
    // ===== THIS CONTRACT IS INITIALIZABLE ======
    // === STORAGE VARIABLES ARE DECLARED BELOW ==
    // REMOVAL OR REORDER OF VARIABLES WILL RESULT
    // ========= IN STORAGE CORRUPTION ===========

    // @notice The duration of voting on emergency pause
    uint256 public votingPeriod;

    // @notice The address of the TrustToken Protocol Timelock
    ITimelock public timelock;

    // @notice The address of the TrustToken Protocol Governor
    IOwnedUpgradeabilityProxy public governor;

    // @notice The address of the TrustToken governance token
    IVoteToken public trustToken;

    // @notice The address of the stkTRU voting token
    IVoteToken public stkTRU;

    // @notice The total number of requests
    uint256 public requestCount;

    // @notice The official record of all requests ever proposed
    mapping(uint256 => PauseRequest) public requests;

    // @notice The latest request for each requester
    mapping(address => uint256) public latestRequestIds;

    // ======= STORAGE DECLARATION END ============

    // @notice The name of this contract
    string public constant name = "TrueFi Pauser";

    // @notice Time in seconds, which corresponds to a period of time,
    // that a request is available for execution after successful voting
    uint256 public constant EXECUTION_PERIOD = 1 days;

    struct PauseRequest {
        // @notice Unique id for looking up a request
        uint256 id;
        // @notice Creator of the request
        address requester;
        // @notice the ordered list of target addresses of contracts to be paused
        address[] targets;
        // @notice The ordered list of functions to be called
        // different types of proxies might require different types of pause functions
        PausingMethod[] methods;
        // @notice The block number at which voting begins: holders must delegate their votes prior to this block
        uint256 startBlock;
        // @notice The timestamp at which voting ends: votes must be cast prior to this timestamp
        uint256 endTime;
        // @notice Current number of votes in favor of this request
        uint256 votes;
        // @notice Flag marking whether the request has been executed
        bool executed;
        // @notice Receipts of ballots for the entire set of voters
        mapping(address => Receipt) receipts;
    }

    // @notice Ballot receipt record for a voter
    struct Receipt {
        // @notice Whether or not a vote has been cast
        bool hasVoted;
        // @notice The number of votes the voter had, which were cast
        uint96 votes;
    }

    // @notice Possible pausing mechanisms
    enum PausingMethod {Status, Proxy, Reference}

    // @notice Possible states that a request may be in
    enum RequestState {Active, Succeeded, Defeated, Expired, Executed}

    // @notice An event emitted when a request has been executed in the Timelock
    event RequestExecuted(uint256 id);

    // @notice An event emitted when a vote has been cast on a request
    event VoteCast(address voter, uint256 requestId, uint256 votes);

    // @notice An event emitted when a new request is created
    event RequestCreated(
        uint256 id,
        address requester,
        address[] targets,
        PausingMethod[] methods,
        uint256 startBlock,
        uint256 endTime
    );

    // @notice The number of votes in support of a request required in order for a quorum to be reached and for a vote to succeed
    function quorumVotes() public pure returns (uint256) {
        return 50000000e8;
    } // 50,000,000 Tru

    // @notice The number of votes required in order for a voter to become a requester
    function requestThreshold() public pure returns (uint256) {
        return 100000e8;
    } // 100,000 TRU

    // @notice The maximum number of actions that can be included in a request
    function requestMaxOperations() public pure returns (uint256) {
        return 10;
    } // 10 actions

    /**
     * @dev Initialize sets initial contract variables
     */
    function initialize(
        ITimelock _timelock,
        IOwnedUpgradeabilityProxy _governor,
        IVoteToken _trustToken,
        IVoteToken _stkTRU,
        uint256 _votingPeriod
    ) external {
        UpgradeableClaimable.initialize(msg.sender);
        timelock = _timelock;
        governor = _governor;
        trustToken = _trustToken;
        stkTRU = _stkTRU;
        votingPeriod = _votingPeriod;
    }

    /**
     * @dev Get the request state for the specified request
     * @param requestId ID of a request in which to get its state
     * @return Enumerated type of RequestState
     */
    function state(uint256 requestId) public view returns (RequestState) {
        require(requestCount >= requestId && requestId > 0, "Pauser::state: invalid request id");
        PauseRequest storage request = requests[requestId];
        if (request.executed) {
            return RequestState.Executed;
        } else if (block.timestamp >= add256(EXECUTION_PERIOD, request.endTime)) {
            return RequestState.Expired;
        } else if (request.votes >= quorumVotes()) {
            return RequestState.Succeeded;
        } else if (block.timestamp <= request.endTime) {
            return RequestState.Active;
        } else {
            return RequestState.Defeated;
        }
    }

    /**
     * @dev Create a request to pause the protocol or its parts
     * @param targets The ordered list of target addresses for calls to be made during request execution
     * @param methods The ordered list of function signatures to be passed during execution
     * @return The ID of the newly created request
     */
    function makeRequest(address[] memory targets, PausingMethod[] memory methods) public returns (uint256) {
        require(
            countVotes(msg.sender, sub256(block.number, 1)) > requestThreshold(),
            "Pauser::makeRequest: requester votes below request threshold"
        );
        require(targets.length == methods.length, "Pauser::makeRequest: request function information arity mismatch");
        require(targets.length != 0, "Pauser::makeRequest: must provide actions");
        require(targets.length <= requestMaxOperations(), "Pauser::makeRequest: too many actions");

        uint256 latestRequestId = latestRequestIds[msg.sender];
        if (latestRequestId != 0) {
            RequestState proposersLatestRequestState = state(latestRequestId);
            require(
                proposersLatestRequestState != RequestState.Active,
                "Pauser::makeRequest: one live request per proposer, found an already active request"
            );
        }

        uint256 startBlock = block.number;
        uint256 endTime = add256(block.timestamp, votingPeriod);

        requestCount++;
        PauseRequest memory newRequest = PauseRequest({
            id: requestCount,
            requester: msg.sender,
            targets: targets,
            methods: methods,
            startBlock: startBlock,
            endTime: endTime,
            votes: 0,
            executed: false
        });

        requests[newRequest.id] = newRequest;
        latestRequestIds[newRequest.requester] = newRequest.id;

        emit RequestCreated(newRequest.id, msg.sender, targets, methods, startBlock, endTime);
        return newRequest.id;
    }

    /**
     * @dev Execute a request after enough votes have been accumulated
     * @param requestId ID of a request that has queued
     */
    function execute(uint256 requestId) external {
        require(state(requestId) == RequestState.Succeeded, "Pauser::execute: request can only be executed if it is succeeded");
        PauseRequest storage request = requests[requestId];
        request.executed = true;
        for (uint256 i = 0; i < request.targets.length; i++) {
            require(request.targets[i] != address(governor), "Pauser::execute: cannot pause the governor contract");
            if (request.methods[i] == PausingMethod.Status) {
                timelock.setPauseStatus(IPauseableContract(request.targets[i]), true);
            } else if (request.methods[i] == PausingMethod.Proxy) {
                timelock.emergencyPauseProxy(IOwnedUpgradeabilityProxy(request.targets[i]));
            } else if (request.methods[i] == PausingMethod.Reference) {
                timelock.emergencyPauseReference(ImplementationReference(request.targets[i]));
            }
        }
        emit RequestExecuted(requestId);
    }

    /**
     * @dev Get the actions of a selected request
     * @param requestId ID of a request
     * return An array of target addresses, an array of request pausing methods
     */
    function getActions(uint256 requestId) public view returns (address[] memory targets, PausingMethod[] memory methods) {
        PauseRequest storage r = requests[requestId];
        return (r.targets, r.methods);
    }

    /**
     * @dev Get a request ballot receipt of the indicated voter
     * @param requestId ID of a request in which to get voter's ballot receipt
     * @return the Ballot receipt record for a voter
     */
    function getReceipt(uint256 requestId, address voter) public view returns (Receipt memory) {
        return requests[requestId].receipts[voter];
    }

    /**
     * @dev Count the total PriorVotes from TRU and stkTRU
     * @param account The address to check the total votes
     * @param blockNumber The block number at which the getPriorVotes() check
     * @return The sum of PriorVotes from TRU and stkTRU
     */
    function countVotes(address account, uint256 blockNumber) public view returns (uint96) {
        uint96 truVote = trustToken.getPriorVotes(account, blockNumber);
        uint96 stkTRUVote = stkTRU.getPriorVotes(account, blockNumber);
        uint96 totalVote = add96(truVote, stkTRUVote, "Pauser::countVotes: addition overflow");
        return totalVote;
    }

    /**
     * @dev Cast a vote on a request
     * @param requestId ID of a request in which to cast a vote
     */
    function castVote(uint256 requestId) public {
        return _castVote(msg.sender, requestId);
    }

    /**
     * @dev Cast a vote on a request internal function
     * @param voter The address of the voter
     * @param requestId ID of a request in which to cast a vote
     */
    function _castVote(address voter, uint256 requestId) internal {
        require(state(requestId) == RequestState.Active, "Pauser::_castVote: voting is closed");
        PauseRequest storage request = requests[requestId];
        Receipt storage receipt = request.receipts[voter];
        require(!receipt.hasVoted, "Pauser::_castVote: voter already voted");
        uint96 votes = countVotes(voter, request.startBlock);

        request.votes = add256(request.votes, votes);

        receipt.hasVoted = true;
        receipt.votes = votes;

        emit VoteCast(voter, requestId, votes);
    }

    /**
     * @dev safe96 add function
     * @return a + b
     */
    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    /**
     * @dev safe addition function for uint256
     */
    function add256(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    /**
     * @dev safe subtraction function for uint256
     */
    function sub256(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "subtraction underflow");
        return a - b;
    }
}
