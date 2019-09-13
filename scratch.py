import os
#import numpy as np
import subprocess as sub
def main():
    #test = 1
    #iter = 10
    inputs = [1,2,3,4,5,6,7,8,11,12,13,14,15,16,17,18,19,20]
    results = []
    for input in inputs:
        sub.call(['./runme', 'input_test/Step2/test'+str(input)+'.micro', 'outputtest'])
        #path = os.path.join()
        with open('outputtest') as file:
            line = file.readline()
            results.append(line)
    print(results)

if __name__ == "__main__": main()
