// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;


// You can know that many honeypots may similiar to this but this one is not,
// you won't get any token if answer right. Only perform transaction if you're curious about my answer.
// This contract is just4fun so don't be serious 
// or send any amount of token to it without knowing that you won't get any token back.
contract Wisdom {
    address payable  public owner;
    string public question = "What is the fastest way to infinity? (Pls answer in UPPERCASE text)";
    // bytes32 private answer = "";
    string  private answer = "";
    mapping (address => uint) public sentAmount;

    // constructor(string memory _answer) {
    //     owner = payable(msg.sender);
    //     answer = _answer;
    //     /**
    //     * BELOW is the original code, which i was stupidly hashing
    //     * then reallized user can't decrypt the hash for answer
    //     */
    //     // bytes32  theAnswer;
    //     // assembly{
    //     //     theAnswer := keccak256(add(_answer, 0x20), mload(_answer))
    //     // }
    //     // answer = theAnswer;
    // }

    constructor() {
        owner = payable(msg.sender);
        answer = "ZERO";
    }


    event receiveEth(address sender, uint amount);
    receive() external payable{
        emit receiveEth(msg.sender, msg.value);
    }


    event fallbackTrigger(address sender, uint amount);
    fallback() external payable{
        emit fallbackTrigger(msg.sender, msg.value);
    }

    event Withdraw(uint timestamp);
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw from this smart contract");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transaction failed!");
        emit Withdraw(block.timestamp);
    }

    event UserWithdraw(address indexed user, uint timestamp);
    function userWithdraw() external {
        uint amount = sentAmount[msg.sender];
        require(amount >= 1e15, "Insufficient minimal amount sent!");
        require(address(this).balance >= amount, "The owner is a little bit faster than you! Good luck next time!");

        sentAmount[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transaction failed!");

        emit UserWithdraw(msg.sender, block.timestamp);
    }


    event WithdrawAssembly(uint timestamp);
    function withdrawAssembly() external {
        require(msg.sender == owner, "Only owner can withdraw from this smart contract");
        address payable destAddr = owner;
        bool result;
        assembly {
            result := call(
                gas(),  // GAS: Send all gas left
                destAddr,   // DESTINATION: owner's address
                selfbalance(), // VALUE: Send all balance
                0, // OUTPUT DATA: ignore ==> 0
                0, // OUTPUT DATA LENGTH: ignore ==> 0
                0, // OUTPUT DATA: ignore ==> 0
                0 // OUTPUT DATA LENGTH: ignore ==> 0
            )
        }
        require(result, "Transaction failed!");

        emit WithdrawAssembly(block.timestamp);
    }

    event UserWithdrawAssembly(address indexed user, uint timestamp);
    function userWithdrawAssembly() external {
        uint amount = sentAmount[msg.sender];
        require(amount >= 1e15, "Insufficient minimal amount sent!");
        require(address(this).balance >= amount, "The owner is a little bit faster than you! Good luck next time!");

        sentAmount[msg.sender] = 0;
        address payable destAddr = payable(msg.sender); 
        bool result;

        assembly {
            result := call(
                gas(),  // GAS
                destAddr,   // DESTINATION
                amount, // VALUE
                0, // OUTPUT DATA: ignore ==> 0
                0, // OUTPUT DATA LENGTH: ignore ==> 0
                0, // OUTPUT DATA: ignore ==> 0
                0 // OUTPUT DATA LENGTH: ignore ==> 0
            )
        }
        require(result, "Transaction failed!");

        emit UserWithdrawAssembly(msg.sender, block.timestamp);
    }


    // If you wanna try hard
    event Bingo(string message);
    event Wrong(string message);
    function tryToAnswer(string calldata _value) payable external {
        uint amount = sentAmount[msg.sender];
        require(msg.value >= 1e15, "Minimum value: 1 finney");
        // Just make sure it will not overflow under any circumstances although it's kind of redundant here
        require(amount + msg.value >= amount, "Overflow operation detected");
        sentAmount[msg.sender] += msg.value;
        if(keccak256(abi.encodePacked(answer)) == keccak256(abi.encodePacked(_value))){
            emit Bingo("You're awesome, it's ZERO. You got such a big brain");
            return;
        }
        emit Wrong("Dude! It's ZERO, how can you not know it XD");
    }

    //If you just want result in the boring way
    function getAnswer() public view returns (string memory ) {
        return answer;
    }


}

// Change context of question-answer
// If _answer == yes => emit Right
// Else if _answer == Wisdom's answer a.k.a  => emit Wrong
// Else emit Wrong
// P/s: This contract will use Wisdom's emit messages at the moment
contract DelegateCallWisdom {
    address payable public owner;
    string public question = "Do you know delegatecall?";
    string private answer = "yes";
    mapping (address => uint) public sentAmount;

    function tryToAnswerDelegateCall(address _wisdomAddress, string calldata _answer) external payable {
        (bool success, ) = _wisdomAddress.delegatecall(
            abi.encodeWithSelector(Wisdom.tryToAnswer.selector, _answer)
        );
        require(success, "Delegate Call not success");
    }
}
