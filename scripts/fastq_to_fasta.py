#!/usr/bin/env python3
import sys
import os


def main():
    if __name__ != "__main__":
        return

    _interleaved = False
    if "-I" in sys.argv:
        _interleaved = True

    _pair = 1
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
            if not _interleaved:
                spot_id += 1
            elif _interleaved and _pair == 2:
                spot_id += 1
                _pair = 1
            elif _interleaved:
                _pair = 2


main()
