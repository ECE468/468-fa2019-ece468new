import os
#import numpy as np
import subprocess as sub
def main():
    inputs = [1,5,6,7,8,11,13,14,16,18,19,20,21,22]
    #results = inputs
    for input in inputs:
        sub.call(['./runme', 'input_test/Step3/test'+str(input)+'.micro', 'outputtest'])
        print("------------------test" + str(input)+".out-------------------")
        sub.call(['diff', 'output_test/Step3/test'+str(input)+'.out', 'outputtest'])
        #path = os.path.join()
        #with open('outputtest') as file:
        #    line = file.readline()
        #    results.append(line)
    #print(results)
	
if __name__ == "__main__": main()
