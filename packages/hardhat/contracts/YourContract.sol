//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Useful for debugging. Remove when deploying to a live network.
import "@phala/solidity/contracts/PhatRollupAnchor.sol";

// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)

/**
 * A smart contract that allows changing a state variable of the contract and tracking the changes
 * It also allows the owner to withdraw the Ether in the contract
 * @author BuidlGuidl
 */
contract YourContract is PhatRollupAnchor {
	// State Variables
	address public immutable owner;
	address public nftContract;
	string public greeting = "Building Unstoppable Apps!!!";
	bool public premium = false;
	uint256 public totalCounter = 0;
	mapping(address => uint) public userGreetingCounter;

	uint constant TYPE_RESPONSE = 0;
	uint constant TYPE_ERROR = 2;

	mapping(uint => address) requests;
	uint nextRequest = 1;

	// Events: a way to emit log statements from smart contract that can be listened to by external parties
	event GreetingChange(
		address indexed greetingSetter,
		string newGreeting,
		bool premium,
		uint256 value
	);
	event ResponseReceived(uint reqId, address target, string[] greetings);
	event ErrorReceived(uint reqId, address target, string[] error);

	// Constructor: Called once on contract deployment
	// Check packages/hardhat/deploy/00_deploy_your_contract.ts
	constructor(address _owner, address _nftContract) {
		owner = _owner;
		nftContract = _nftContract;
		_grantRole(PhatRollupAnchor.ATTESTOR_ROLE, _owner);
	}

	function setAttestor(address phatAttestor) public {
		_grantRole(PhatRollupAnchor.ATTESTOR_ROLE, phatAttestor);
	}

	// Modifier: used to define a set of rules that must be met before or after a function is executed
	// Check the withdraw() function
	modifier isOwner() {
		// msg.sender: predefined variable that represents address of the account that called the current function
		require(msg.sender == owner, "Not the Owner");
		_;
	}

	/**
     * Function that allows anyone to change the state variable "greeting" of the contract and increase the counters
     *
     * @param _newGreeting (string memory) - new greeting to save on the contract
	 */
	function setGreeting(string memory _newGreeting) public payable {
		// Change state variables
		greeting = _newGreeting;
		totalCounter += 1;
		userGreetingCounter[msg.sender] += 1;

		// msg.value: built-in global variable that represents the amount of ether sent with the transaction
		if (msg.value > 0) {
			premium = true;
		} else {
			premium = false;
		}

		// emit: keyword used to trigger an event
		emit GreetingChange(msg.sender, _newGreeting, msg.value > 0, 0);
	}

	/**
     * Function to request for all of an accounts greetings
     *
     * @param target (address) - Target account address to request all greetings
	 */
	function request(address target) public {
		// assemble the request
		uint id = nextRequest;
		requests[id] = target;
		_pushMessage(abi.encode(id, target));
		nextRequest += 1;
	}

	/**
     * Internal override function from PhatRollupAnchor that handles the response from the
     * Phat Contract that will return encoded bytes calldata of the response type, request id
     * and the array of greetings set by the account address requested in `request` function
     *
     * @param action (bytes calldata) - bytes calldata action reply from the Phat Contract
	 */
	function _onMessageReceived(bytes calldata action) internal override {
		// Optional to check length of action
		// require(action.length == 32 * 3, "cannot parse action");
		(uint respType, uint id, string[] memory greetings) = abi.decode(
			action,
			(uint, uint, string[])
		);
		address target = requests[id];
		if (respType == TYPE_RESPONSE) {
			emit ResponseReceived(id, target, greetings);
			delete requests[id];
		} else if (respType == TYPE_ERROR) {
			emit ErrorReceived(id, target, greetings);
			delete requests[id];
		}
	}

	/**
     * Function that allows the owner to withdraw all the Ether in the contract
     * The function can only be called by the owner of the contract as defined by the isOwner modifier
     */
	function withdraw() public isOwner {
		(bool success, ) = owner.call{ value: address(this).balance }("");
		require(success, "Failed to send Ether");
	}

	/**
     * Function that allows the contract to receive ETH
     */
	receive() external payable {}
}
