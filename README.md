## ncbi::sra-human-scrubber 
### Description
The human read removal tool (HRRT) is based on the [SRA Taxonomy Analysis Tool](https://doi.org/10.1186/s13059-021-02490-0) that will take as input a fastq file, and produce as output a fastq.clean file in which all reads identified as potentially of human origin are removed.
### Overview
Briefly, the HRRT is based on a k-mer database that is constructed from the k-mers derived from all human RefSeq records and subtracts the library of k-mers generated from all non-Eukaryota RefSeq records. The remaining set of k-mers are the database used to ID human reads by the removal tool. This means it tends to be aggressive about identifying human reads since it contains not only human-specific k-mers, but also k-mers common to primates, mammals, and other lineages further up the Eukaryotic tree. However, it is also fairly conservative at maintaining any viral or bacterial clinical pathogen sequences. It takes a fastq file as input, identifies any reads with hits to the 'human' k-mer database and outputs a fastq.clean with the identified human reads masked with 'N'.
### Quick Start
* Clone the repo.
* `pushd` or `cd` to directory `sra-human-scrubber`.
	* Alternatively, download the zip file from the green 'Code' button, unzip it, then cd to directory `sra-human-scrubber-master`.
* Execute `./init_db.sh` in directory `sra-human-scrubber` - this will retrieve the pre-built db from ftp and place it in the directory `sra-human-scrubber/data` where it needs to be located.
* Please note binary `aligns_to`in bin was compiled on x86_64 GNU/Linux. 



### Usage
Working in the directory `sra-human-scrubber` (or alternatively `sra-human-scrubber-master`)
#### Invoke the test 
Here the command is simply given the (file) argument `test`
`./scripts/scrub.sh test`

```
2021-03-29 12:31:48	aligns_to version 0.60
2021-03-29 12:31:48	hardware threads: 1, omp threads: 1
2021-03-29 12:31:50	loading time (sec) 1
2021-03-29 12:31:50	/tmp/tmp.lzwaZO4fwI/scrubber_test.fastq.fasta
2021-03-29 12:31:50	100% processed
2021-03-29 12:31:50	total spot count: 2
2021-03-29 12:31:50	total read count: 2
2021-03-29 12:31:50	total time (sec) 1
1  spot(s) removed.

test succeeded
```

#### Remove human reads from fastq file

Here the command is given the path to your local fastq file as argument
`./scripts/scrub.sh path-to-fastq-file/filename.fastq`

Example:
`./scripts/scrub.sh Runs/SRR13402847.fastq`

```
2021-03-29 12:33:49	aligns_to version 0.60
2021-03-29 12:33:49	hardware threads: 1, omp threads: 1
2021-03-29 12:33:49	loading time (sec) 0
2021-03-29 12:33:49	Runs/SRR13402847.fastq.fasta
2021-03-29 12:33:49	15% processed
2021-03-29 12:33:56	30% processed
2021-03-29 12:34:02	46% processed
2021-03-29 12:34:08	62% processed
2021-03-29 12:34:14	77% processed
2021-03-29 12:34:20	93% processed
2021-03-29 12:34:26	100% processed
2021-03-29 12:34:29	total spot count: 216859
2021-03-29 12:34:29	total read count: 216859
2021-03-29 12:34:29	total time (sec) 39
139  spot(s) removed.

```

```
$ ls -l Runs/
total 275816
 rw-rr- 1 xxx xxx 141280412 Feb 19 00:03 SRR13402847.fastq
 rw-rr- 1 xxx xxx 141151371 Feb 22 17:06 SRR13402847.fastq.clean
```
Note the application scales to use all threads available

```
2021-03-29 08:39:07	aligns_to version 0.60
2021-03-29 08:39:07	hardware threads: 32, omp threads: 32
2021-03-29 08:39:10	loading time (sec) 2
2021-03-29 08:39:10	/home/kskatz/SCRUBBER/Runs/SRR13402847.fastq.fasta
2021-03-29 08:39:10	15% processed
2021-03-29 08:39:15	100% processed
2021-03-29 08:39:15	total spot count: 216859
2021-03-29 08:39:15	total read count: 216859
2021-03-29 08:39:15	total time (sec) 8
139  spot(s) removed.
```
Docker container available here: https://hub.docker.com/r/ncbi/sra-human-scrubber

Other useful options
```
[sra-human-scrubber]$ ./scripts/scrub.sh -h
Usage: scrub.sh [OPTIONS] [file.fastq] 
OPTIONS:
	-i <input_file>; Input Fastq File.
	-o <output_file>; Save cleaned sequence reads to file, or set to - for stdout.
		NOTE: When stdin is used, output is stdout by default.
	-p <number> Number of threads to use.
	-d <database_path>; Specify path to custom database file (e.g. human_filter.db).
	-n ; Replace sequence length of identified spots with 'N'.
	-r ; Save identified spots to file.fastq.spots_removed.
	-t ; Run test.
	-h ; Display this message.

```
