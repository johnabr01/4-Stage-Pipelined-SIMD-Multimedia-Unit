# -*- coding: utf-8 -*-
"""
Created on Thu Apr 17 23:31:30 2025

@author: Dharmik
"""

source = open("C:/Users/jobif/OneDrive/Documents/John College/ese 345/345ProjFinal/345_proj-20250430T171046Z-1-001/345_proj/source.txt","r")
destination = open("C:/Users/jobif/OneDrive/Documents/John College/ese 345/345ProjFinal/345_proj-20250430T171046Z-1-001/345_proj/src/instructions.txt","w")

instructionArray = []

instructionDictionary = {
        "li" :      ["0"],
        
        "simals" :  ["10","000"],
        "simahs" :  ["10","001"],
        "simsls" :  ["10","010"],
        "simshs" :  ["10","011"],
        "slimals" : ["10","100"],
        "slimahs" : ["10","101"],
        "slimsls" : ["10","110"],
        "slimshs" : ["10","111"],
        
        "nop" :     ["11","00000000"],
        "shrhi" :   ["11","00000001"],
        "au" :      ["11","00000010"],
        "cntiw" :   ["11","00000011"],
        "ahs" :     ["11","00000100"],
        "nor" :     ["11","00000101"],
        "bcw" :     ["11","00000110"],
        "maxws" :   ["11","00000111"],
        "minws" :   ["11","00001000"],
        "mlhu" :    ["11","00001001"],
        "mlhcu" :   ["11","00001010"],
        "and" :     ["11","00001011"],
        "clzh" :    ["11","00001100"],
        "rotw" :    ["11","00001101"],
        "sfwu" :    ["11","00001110"],
        "sfhs" :    ["11","00001111"],
    }


def init():
    destination.write("")
    initInstructionArray()
    
def deInit():
    source.close()
    destination.close()
    
def initInstructionArray():
    with source as file:
        for line in file:
            addInstructionLine(line.rstrip())

def addInstructionLine(line):
    line = line.replace(',','') # get rid of comma
    instructionLine = line.split()
    instructionArray.append(instructionLine)
            

def registerToBinary(value):
    return '{0:05b}'.format(int(value))

def loadIndexToBinary(value):
    return '{0:03b}'.format(int(value))

def IntTo16BitSigned(value):
    value = int(value)
    value = value if value >= 0 else (1 << 16) + value
    return f'{value:016b}'

def processLW(instruction):
    prefix = instructionDictionary[instruction[0]][0]
    rd = registerToBinary(instruction[3])
    LI = loadIndexToBinary(instruction[1])
    Imm = IntTo16BitSigned(instruction[2])
    
    return f"{prefix}{LI}{Imm}{rd}"

            
def processTypeR3(instruction):
    prefix = instructionDictionary[instruction[0]][0]
    opcode = instructionDictionary[instruction[0]][1]
    if instruction[0] == "nop":
        rd = rs2 = rs1 = "00000"
        return f"{prefix}{opcode}{rs2}{rs1}{rd}"
    rs2 = registerToBinary(instruction[1])
    rs1 = registerToBinary(instruction[2])
    rd = registerToBinary(instruction[3])
    
    return f"{prefix}{opcode}{rs2}{rs1}{rd}"
    
def processTypeR4(instruction):
    prefix = instructionDictionary[instruction[0]][0]
    opcode = instructionDictionary[instruction[0]][1]   
    rs3 = registerToBinary(instruction[1])
    rs2 = registerToBinary(instruction[2])
    rs1 = registerToBinary(instruction[3])
    rd = registerToBinary(instruction[4])
    
    return f"{prefix}{opcode}{rs3}{rs2}{rs1}{rd}"

            
def processInstruction(instruction):
    if instructionDictionary.get(instruction[0]):
        match instructionDictionary[instruction[0]][0]:
            case "0":
                return processLW(instruction)
            case "10":
                return processTypeR4(instruction)
            case "11":
                return processTypeR3(instruction)
            case _:
                return "Null"
            
def outputInstruction(outputVal):
    destination.write(f"{outputVal}\n")
    
def processAllInstructions():
    for line in instructionArray:
        output = processInstruction(line)
        outputInstruction(output)

def main():
    init()
    processAllInstructions()
    deInit()
    
main()
