#!/usr/bin/env python3
import sys
import os


def main():
    if __name__ != "__main__":
        return

    internal_number = 0
    spot_id = 1

    for line in sys.stdin:
        if internal_number == 0:
            print('>' + str(spot_id))
        elif internal_number == 1:
            print(line.rstrip())
        elif internal_number == 2:
            if line[0] != '+':
                raise line

        internal_number += 1
        if internal_number == 4:
            internal_number = 0 
            spot_id += 1    


main()
