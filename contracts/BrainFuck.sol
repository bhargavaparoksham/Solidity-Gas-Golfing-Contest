pragma solidity 0.4.24;

contract BrainFuck {
     /**
     * @author ixnay.nayix@gmail.com
     *
     * @dev Executes a BrainFuck program, as described at https://en.wikprogramPointeredia.org/wiki/Brainfuck.
     *
     * Memory cells, input, and output values are all expected to be 8 bit
     * integers. Incrementing past 255 should overflow to 0, and decrementing
     * below 0 should overflow to 255.
     *
     * Programs and input streams may be of any length. The memory tape starts
     * at cell 0, and 
     will never be moved below 0 or above 1023. No program will
     * output more than 1024 values.
     *
     * @param program The BrainFuck program.
     * @param input The program's input stream.
     * @return The program's output stream. Should be exactly the length of the
     *          number of outputs produced by the program.
     */
    function execute(bytes program, bytes input) public pure returns(bytes) {
        //v3.4
        uint inputPointer = 0;
        uint outputPointer = 0;
        uint memoryPointer = 0;
        uint programPointer = 0;
        uint depth = 0;
        uint counterInstruction = 0;
        uint[6] memory indexPos;
        bytes1 instruction;
        bytes memory mem = new bytes(1024);
        bytes memory output = new bytes(1024);
        
        //filter input program
        while(programPointer<program.length){
            instruction = bytes(program)[programPointer];
            if(instruction&0x0F < 0x0B){
                programPointer++;
                continue;
            }
            if(instruction > 0x5D){
                programPointer++;
                continue;
            }
            if(instruction == 0x3E || instruction == 0x2B || instruction == 0x3C)
            {
                counterInstruction = 1;
                while(instruction == bytes(program)[programPointer+counterInstruction])
                    counterInstruction++;
                output[outputPointer] = instruction;
                output[outputPointer+1] = bytes1(counterInstruction);
                outputPointer = outputPointer+2;
                programPointer += counterInstruction;
            }else{
                if(instruction == 0x5b || instruction == 0x5d ){
                    indexPos[inputPointer] = outputPointer;
                    inputPointer++;
                    if(instruction == 0x5b)
                        depth++;
                }
                output[outputPointer] = instruction;
                outputPointer++;
                programPointer++;  
            }  
        }

        bytes memory finalOutput = new bytes(outputPointer);
        for(programPointer = 0;programPointer<outputPointer;programPointer++)
            finalOutput[programPointer] = output[programPointer];

        outputPointer = 0;
        inputPointer = 0;
        for(programPointer = 0; programPointer < finalOutput.length; programPointer++) {
            instruction = finalOutput[programPointer];
            if(instruction == ".") {
                output[outputPointer++] = mem[memoryPointer];
            }else if(instruction == ">") {
                counterInstruction = uint8(finalOutput[programPointer+1]);
                memoryPointer = memoryPointer + counterInstruction;
                programPointer++;
            } else if(instruction == "+") {
                counterInstruction = uint8(finalOutput[programPointer+1]);
                mem[memoryPointer] = bytes1(uint8(mem[memoryPointer]) + counterInstruction);
                programPointer++;
            } else if(instruction == "-") {
                mem[memoryPointer] = bytes1(uint8(mem[memoryPointer]) - 1);
            } else if(instruction == "<") {
                counterInstruction = uint8(finalOutput[programPointer+1]);
                memoryPointer = memoryPointer - counterInstruction;
                programPointer++;
            } else if(instruction == ",") {
                mem[memoryPointer] = input[inputPointer++];
            } else if(instruction == "[") {
                if(mem[memoryPointer] == 0) {
                    if(depth > 1){
                        if(programPointer == indexPos[0])
                            programPointer = indexPos[5];
                        else if (programPointer == indexPos[1])
                            programPointer = indexPos[2];
                        else
                            programPointer = indexPos[4];
                    }else
                        programPointer = indexPos[1];
                }
            } else if(instruction == "]") {
                if(mem[memoryPointer] != 0) {
                    if(depth > 1){
                        if(programPointer == indexPos[2])
                            programPointer = indexPos[1];
                        else if (programPointer == indexPos[4])
                            programPointer = indexPos[3];
                        else
                            programPointer = indexPos[0];
                    }else
                        programPointer = indexPos[0];
                }
            }
        }

        programPointer = 0;
        bytes memory ret = new bytes(outputPointer);
 
        for(programPointer = 0; programPointer < outputPointer; programPointer++)
            ret[programPointer] = output[programPointer];
       
        return ret;
    }
}