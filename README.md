## ncbi::sra-human-scrubber 
### Description
The human read removal tool (HRRT) is based on the [SRA Taxonomy Analysis Tool](https://doi.org/10.1186/s13059-021-02490-0) that will take as input a fastq file, and produce as output a fastq.clean file in which all reads identified as potentially of human origin are masked with 'N'.
### Overview
Briefly, the HRRT is based on a k-mer database that is constructed from the k-mers derived from all human RefSeq records and subtracts the library of k-mers generated from all non-Eukaryota RefSeq records. The remaining set of k-mers compose the database used to identify human reads by the removal tool. This means it tends to be aggressive about identifying human reads since it contains not only human-specific k-mers, but also k-mers common to primates, mammals, and other lineages further up the Eukaryotic tree. However, it is also fairly conservative at maintaining any viral or bacterial clinical pathogen sequences. It takes a fastq file as input, identifies any reads with hits to the 'human' k-mer database and outputs a fastq.clean with
the identified human reads masked with 'N'. Note that for an interleaved paired-read input file, whenever a read is identified as human the pair mate will also be masked *whether or not it too is identified as human.*
### Quick Start
* Clone the repo.
* `pushd` or `cd` to directory `sra-human-scrubber`.
    * Alternatively, download the zip file from the green 'Code' button, unzip it, then cd to directory `sra-human-scrubber-master`.
* Execute `./init_db.sh` in directory `sra-human-scrubber` - this will retrieve the default (newest) pre-built db from ftp and place it in the directory `sra-human-scrubber/data` where it needs to be located.
* Please note binary `aligns_to`in bin was compiled on x86_64 GNU/Linux. 
* Please refer to CHANGELOG for recent changes.

### Usage
Working in the directory `sra-human-scrubber` (or alternatively `sra-human-scrubber-master`)
#### Invoke the test 
Here the command is simply given the (file) argument `test`
`./scripts/scrub.sh test`

```
./scripts/scrub.sh test
2022-08-31 14:35:08	aligns_to version 0.707
2022-08-31 14:35:08	hardware threads: 32, omp threads: 32
2022-08-31 14:35:09	loading time (sec) 1
2022-08-31 14:35:09	/tmp/tmp.EpHdBbPYzb/temp.fasta
2022-08-31 14:35:09	FastaReader
2022-08-31 14:35:09	100% processed
2022-08-31 14:35:09	total spot count: 2
2022-08-31 14:35:09	total read count: 2
2022-08-31 14:35:09	total time (sec) 1
1  spot(s) masked or removed.

test succeeded
```

#### Mask human reads from fastq file

Here the command is given the path to your local fastq file as argument
`./scripts/scrub.sh path-to-fastq-file/filename.fastq`

Example:
`./scripts/scrub.sh $TmpRuns/MyFastqFile.fastq`

```
./scripts/scrub.sh $TmpRuns/MyFastqFile.fastq 
2022-08-31 14:43:58	aligns_to version 0.707
2022-08-31 14:43:58	hardware threads: 32, omp threads: 32
2022-08-31 14:43:59	loading time (sec) 1
2022-08-31 14:43:59	/tmp/tmp.jZwaayxNAA/temp.fasta
2022-08-31 14:43:59	FastaReader
2022-08-31 14:43:59	0% processed
2022-08-31 14:44:00	100% processed
2022-08-31 14:44:00	total spot count: 216859
2022-08-31 14:44:00	total read count: 216859
2022-08-31 14:44:00	total time (sec) 2
129  spot(s) masked or removed.
```
Note by default the application scales to use all threads available
( see option `-p` for setting threads below ).

Docker container available here: https://hub.docker.com/r/ncbi/sra-human-scrubber

Other useful options:
```
[sra-human-scrubber]$ ./scripts/scrub.sh -h
Usage: scrub.sh [OPTIONS] [file.fastq] 
OPTIONS:
	-i <input_file>; Input Fastq File.
	-o <output_file>; Save cleaned sequence reads to file, or set to - for stdout.
		NOTE: When stdin is used, output is stdout by default.
	-p <number> Number of threads to use.
	-d <database_path>; Specify path to custom database file (e.g. human_filter.db).
		NOTE: Now by default sequence length of identified spots replaced with 'N'.
	-x ; Remove spots instead of default 'N' replacement.
	-r ; Save identified spots to file.fastq.spots_removed.
	-t ; Run test.
	-h ; Display this message.

```
