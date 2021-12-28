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

    constructor(string memory _answer) {
        owner = payable(msg.sender);
        answer = _answer;
        /**
        * BELOW is the original code, which i was stupidly hashing
        * then reallized user can't decrypt the hash for answer
        */
        // bytes32  theAnswer;
        // assembly{
        //     theAnswer := keccak256(add(_answer, 0x20), mload(_answer))
        // }
        // answer = theAnswer;
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


    function withdraw_assembly() external {
        require(msg.sender == owner, "Only owner can withdraw from this smart contract");
        address payable destAddr = owner; // I wish we can access state variable directly :'(
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
    }


    // If you wanna try hard
    event Bingo(string message);
    event Wrong(string message);
    function tryToAnswer(string calldata _value) payable external {
        require(msg.value >= 1e15, "Minimum value: 1 finney");
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
