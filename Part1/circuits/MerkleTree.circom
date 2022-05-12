pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template TreeLayer(height) {
    var nItems = 1 << height;
    signal input ins[nItems * 2];
    signal output outs[nItems];

    component hash[nItems];
    for(var  i = 0; i < nItems; i++) {
        hash[i] = Poseidon(2);
        hash[i].inputs[0] <== ins[i * 2];
        hash[i].inputs[1] <== ins[i * 2 + 1];

        hash[i].out ==> outs[i];
    }
}

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    component layers[n];
    for(var i = n - 1; i >= 0; i--) {
        layers[i] = TreeLayer(i);
        for(var j = 0; j < (1 << i + 1); j++) {
            layers[i].ins[j] <== i == n - 1 ? leaves[i] : layers[i + 1].outs[j];
        }
    } 
    root <== n > 0 ? layers[0].outs[0] : leaves[0];   
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component switcher[n];
    component hasher[n];

    for(var i = 0; i < n; i++) {
        switcher[i] = Switcher();
        switcher[i].L <== i == 0 ? leaf : hasher[i - 1].out;
        switcher[i].R <== path_elements[i];
        switcher[i].sel <== path_index[i];

        hasher[i] = Poseidon(2);
        hasher[i].inputs[0] <== switcher[i].outL;
        hasher[i].inputs[1] <== switcher[i].outR;
    }

    root <== hasher[n - 1].out;
}