import os
#import numpy as np
import subprocess as sub
def main():
    #test = 1
    #iter = 10
    inputs = [1,5,6,7,8,11,13,14,16,18,19,20,21,22]
    results = []
    for input in inputs:
        sub.call(['./runme', 'test'+str(input)+'.micro', 'outputtest'])
        #path = os.path.join()
        with open('outputtest') as file:
            line = file.readline()
            results.append(line)
    print(results)

if __name__ == "__main__": main()
