#!/usr/bin/env python3
import sys


def read_fastq(f):
    seq = ""
    desc = ""
    plus_line = ""
    quality_scores = ""
    fastq_line = 1
    for line in f:
        if fastq_line == 5:
            yield desc, seq, plus_line, quality_scores
            fastq_line = 1
        line = line.rstrip()
        if fastq_line == 1:
            desc = line
            fastq_line += 1
        elif fastq_line == 2:
            seq = line
            fastq_line += 1
        elif fastq_line == 3:
            plus_line = line
            fastq_line += 1
        else:
            quality_scores = line
            fastq_line += 1

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
    save_removed = False
    n_replace = False
    if len(sys.argv) >= 3:
        if "-r" in sys.argv:
            save_removed = True
        if "-n" in sys.argv:
            n_replace = True
    f_removed_spots = None
    if save_removed:
        f_removed_spots = sys.argv[1] + ".removed_spots"

    spots = load_spots()
    frs = None
    if len(spots) and save_removed:
        frs = open(f_removed_spots, "w")

    spot_id = 1
    for desc, seq, plus_line, quality_scores in read_fastq(f):
        if spot_id not in spots:
            print(desc)
            print(seq)
            print(plus_line)
            print(quality_scores)
        if save_removed and spot_id in spots:
            print(desc, file=frs)
            print(seq, file=frs)
            print(plus_line, file=frs)
            print(quality_scores, file=frs)
        if n_replace and spot_id in spots:
            print(desc)
            print(len(seq) * 'N')
            print(plus_line)
            print(quality_scores)

        spot_id += 1

    print(len(spots), " spot(s) removed.", file=sys.stderr)


main()
