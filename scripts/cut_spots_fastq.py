#!/usr/bin/env python3
import sys
import fastq_to_fasta


def read_fastq(f):
    seq = ""
    desc = ""
    plus_line = ""
    quality_scores = ""
    i = 1
    for line in f:
        if i == 5:
            yield desc, seq, plus_line, quality_scores
            i = 1
        line = line.rstrip()
        if i == 1:
            desc = line
            i=i+1
        elif i == 2:
            seq = line
            i=i+1
        elif i == 3:
            plus_line = line
            i=i+1
        else:
            quality_scores = line
            i = i+1

    yield desc, seq, plus_line, quality_scores




def load_spots():
    spots = set()
    for line in sys.stdin:
        spots.add(int(line))

    return spots


def main():
    if __name__ != "__main__":
        return

    if len(sys.argv) < 2:
        print("need <collated fastq to edit>", file=sys.stderr)
        return

    f = open(sys.argv[1])
    spots = load_spots()
    spot_id = 1
    for desc, seq, plus_line, quality_scores in read_fastq(f):
        if spot_id not in spots:
            print(desc)
            print(seq)
            print(plus_line)
            print(quality_scores)

        spot_id += 1


main()
