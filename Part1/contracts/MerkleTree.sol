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

    // building tree using recursion, only hashing what is needed not all nodes.
    function buildTree(
        uint32 level,
        uint256 _index,
        uint256[] storage _hashes
    ) internal {
        if (level <= 0) {
            return;
        } else {
            if (_index % 2 == 0) {
                uint256 hash = PoseidonT3.poseidon(
                    [_hashes[_index], _hashes[_index + 1]]
                );
                _hashes[_index + (1 << level)] = hash;
                buildTree(level - 1, _index + (1 << level), _hashes);
            } else {
                uint256 hash = PoseidonT3.poseidon(
                    [_hashes[_index - 1], _hashes[_index]]
                );
                _hashes[_index - 1 + (1 << level)] = hash;
                buildTree(level - 1, (_index - 1 + (1 << level)), _hashes);
            }
        }
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        buildTree(3, index, hashes);
        index = index + 1;
        root = hashes[14];
        return root;
    }

    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) public view returns (bool) {
        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a, b, c, input) == true && root == input[0];
    }
}
