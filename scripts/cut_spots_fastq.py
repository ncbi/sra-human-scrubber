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
    f_removed_spots = None
    s_interleaved = False
    if len(sys.argv) >= 3:
        if "-r" in sys.argv:
            save_removed = True
            file_pos = sys.argv.index("-r") + 1
            if len(sys.argv) > file_pos:
                if sys.argv[file_pos]:
                    f_removed_spots = sys.argv[file_pos]

        if "-n" in sys.argv:
            n_replace = True

        if "-I" in sys.argv:
            s_interleaved = True

    if save_removed:
        if f_removed_spots is None:
            f_removed_spots = sys.argv[1] + ".removed_spots"

    spots = load_spots()
    frs = None
    if len(spots) and save_removed:
        frs = open(f_removed_spots, "w")

    _pair = 1
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

        if not s_interleaved:
            spot_id += 1
        elif s_interleaved and _pair == 2:
            spot_id += 1
            _pair = 1
        elif s_interleaved:
            _pair = 2

    print(len(spots), " spot(s) masked or removed.", file=sys.stderr)


main()
