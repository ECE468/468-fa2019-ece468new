import os
#import numpy as np
import subprocess as sub
def main():
    step_num = "4"
    #results = inputs
    entries = os.listdir('input_test/Step'+step_num+'/')
    inputs = []
    #print(entries)
    for element in entries:
        if '.' in element and '~' not in element:
            inputs.append(element)
    #print(inputs)
    for input in inputs:
        sub.call(['./runme', 'input_test/Step'+step_num+'/'+input, 'outputtest'])
        print("------------------" + input.split(".")[0]+".out-------------------")
        sub.call(['diff', 'output_test/Step'+step_num+'/'+input.split('.')[0]+'.out', 'outputtest'])

	
if __name__ == "__main__": main()
