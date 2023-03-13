// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

uint256 constant maxUint256   = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

bytes32 constant nameLength   = 0x000000000000000000000000000000000000000000000000000000000000000D;
bytes32 constant nameData     = 0x4578616d706c6520546f6b656e00000000000000000000000000000000000000;

bytes32 constant symbolLength = 0x0000000000000000000000000000000000000000000000000000000000000003;
bytes32 constant symbolData   = 0x45544b0000000000000000000000000000000000000000000000000000000000;

contract ERC20Assembly {
    uint256 internal totalSupply;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowances;

    constructor() {
        assembly {
            sstore(0x00, maxUint256)

            mstore(0x00, caller())
            mstore(0x20, 0x01)
            let slot := keccak256(0x00, 0x40)
            sstore(slot, maxUint256)
        }
    }

    function name() public pure returns (string memory) {
        assembly {
            // 3 memory slots: the pointer, the string length and the string data.
            let pointer := mload(0x40)
            mstore(pointer, 0x20)
            mstore(add(pointer, 0x20), nameLength)
            mstore(add(pointer, 0x40), nameData)
            return(pointer, 0x60)
        }
    }

    function symbol() public pure returns (string memory) {
        assembly {
            let pointer := mload(0x40)
            mstore(pointer, 0x20)
            mstore(add(pointer, 0x20), symbolLength)
            mstore(add(pointer, 0x40), symbolData)
            return(pointer, 0x60)
        }
    }

    function decimals() public pure returns (uint8) {
        assembly {
            mstore(0x00, 18)
            return(0x00, 0x20)
        }
    }

    function balance(address) public view returns (uint256) {
        assembly {
            let account := calldataload(4)
            mstore(0x00, account)
            mstore(0x20, 0x01)
            let hash := keccak256(0x00, 0x40)

            let userBalance := sload(hash)
            mstore(0x00, userBalance)
            return(0x00, 0x20)
        }
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        assembly {
            mstore(0x00, owner)
            mstore(0x20, 0x02)
            let ownerSlot := keccak256(0x00, 0x40)

            mstore(0x00, spender)
            mstore(0x20, ownerSlot)
            let allowanceSlot := keccak256(0x00, 0x40)
            let allowanceVal := sload(allowanceSlot)
            mstore(0x00, allowanceVal)
            return(0x00, 0x20)
        }
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        assembly {
            mstore(0x00, caller())
            mstore(0x20, 0x02)
            let ownerSlot := keccak256(0x00, 0x40)

            mstore(0x00, spender)
            mstore(0x20, ownerSlot)
            let allowanceSlot := keccak256(0x00, 0x40)

            sstore(allowanceSlot, amount)
            mstore(0x00, 0x01)
            return(0x00, 0x20)
        }
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        assembly {
            let pointer := mload(0x40)
            mstore(pointer, caller())
            mstore(add(pointer, 0x20), 0x01)

            let fromSlot := keccak256(pointer, 0x40)
            let fromBalance := sload(fromSlot)
            
            if lt(fromBalance, amount) {
                revert(0x00, 0x00)
            }

            let newFromBalance := sub(fromBalance, amount)
            sstore(fromSlot, newFromBalance)

            mstore(pointer, to)
            mstore(add(pointer, 0x20), 0x01)

            let toSlot := keccak256(pointer, 0x40)
            let toBalance := sload(toSlot)
            let newToBalance := add(toBalance, amount)

            sstore(toSlot, newToBalance)

            mstore(0x00, 0x01)
            return(0x00, 0x20)
        }
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        assembly {
            // Check caller allowance
            mstore(0x00, from)
            mstore(0x20, 0x02)
            let ownerSlot := keccak256(0x00, 0x40)

            mstore(0x00, caller())
            mstore(0x20, ownerSlot)
            let allowanceSlot := keccak256(0x00, 0x40)
            let allowanceVal := sload(allowanceSlot)

            if lt(allowanceVal, amount) {
                revert(0x00, 0x00)
            }

            // Update caller allowance.
            let newCallerAllowance := sub(allowanceVal, amount)
            sstore(allowanceSlot, newCallerAllowance)

            // Load "from" balance.
            let pointer := mload(0x40)
            mstore(pointer, from)
            mstore(add(pointer, 0x20), 0x01)

            let fromSlot := keccak256(pointer, 0x40)
            let fromBalance := sload(fromSlot)
            
            if lt(fromBalance, amount) {
                revert(0x00, 0x00)
            }

            // Update "from" and "to" balances.
            let newFromBalance := sub(fromBalance, amount)
            sstore(fromSlot, newFromBalance)

            mstore(pointer, to)
            mstore(add(pointer, 0x20), 0x01)

            let toSlot := keccak256(pointer, 0x40)
            let toBalance := sload(toSlot)
            let newToBalance := add(toBalance, amount)

            sstore(toSlot, newToBalance)

            mstore(0x00, 0x01)
            return(0x00, 0x20)
        }
    }
}