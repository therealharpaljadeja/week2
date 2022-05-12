//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {PoseidonT3} from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        hashes.push(0);
        hashes.push(0);
        hashes.push(0);
        hashes.push(0);
        hashes.push(0);
        hashes.push(0);
        hashes.push(0);
        hashes.push(0);
        hashes.push(PoseidonT3.poseidon([hashes[0], hashes[1]]));
        hashes.push(PoseidonT3.poseidon([hashes[2], hashes[3]]));
        hashes.push(PoseidonT3.poseidon([hashes[4], hashes[5]]));
        hashes.push(PoseidonT3.poseidon([hashes[6], hashes[7]]));
        hashes.push(PoseidonT3.poseidon([hashes[8], hashes[9]]));
        hashes.push(PoseidonT3.poseidon([hashes[10], hashes[11]]));
        hashes.push(PoseidonT3.poseidon([hashes[12], hashes[13]]));
    }

    function buildTree(uint32 level, uint256 _index) internal {
        if (level <= 0) return;
        else {
            uint256[] memory _hashes = hashes;
            if (index % 2 == 0) {
                uint256 hash = PoseidonT3.poseidon(
                    [_hashes[_index], _hashes[_index + 1]]
                );
                _hashes[_index + (1 << level)] = hash;
                buildTree(level - 1, _index + (1 << level));
            } else {
                uint256 hash = PoseidonT3.poseidon(
                    [_hashes[_index - 1], _hashes[_index]]
                );
                _hashes[_index - 1 + (1 << level)] = hash;
                buildTree(level - 1, (_index - 1 + (1 << level)));
            }
        }
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        buildTree(3, index);
        index = index + 1;
        root = hashes[14];
    }

    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) public view returns (bool) {
        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a, b, c, input);
    }
}
