## ncbi::sra-human-scrubber 
### Description
A tool based on STAT ([manuscript in submission](https://biorxiv.org/cgi/content/short/2021.02.16.431451v1)) that will take as input a fastq file, and produce as output a fastq.clean file in which all reads identified as potentially of human origin are removed.

### Quick Start
* For user simplicity this repo is release only, so that the human scrubber db, binary aligns_to, and necessary scripts are downloaded as a gzipped tar file.
* Create directory `scrubber`
* `pushd` or `cd` to directory `scrubber`
* Download {release.tar.gz}
* tar -zxvf {release.tar.gz}


### Usage
Working in the directory `scrubber`
#### Invoke the test 
Here the command is simply given the (file) argument `test`
`./scripts/scrub.sh test`

```
2021-02-22 16:14:37 aligns_to version 0.55  
2021-02-22 16:14:37 hardware threads: 1, omp threads: 1  
2021-02-22 16:14:39 loading time (sec) 1
2021-02-22 16:14:39 /tmp/tmp.jPhmylO4q8/scrubber_test.fastq.fasta  
2021-02-22 16:14:39 100% processed  
2021-02-22 16:14:39 total spot count: 2  
2021-02-22 16:14:39 total read count: 2 
2021-02-22 16:14:39 total time (sec) 1 

test succeeded
```

#### Remove human reads from fastq file

Here the command is given the path to your local fastq file as argument
`./scripts/scrub.sh path-to-fastq-file/filename.fastq`

Example:
`./scripts/scrub.sh Runs/SRR13402847.fastq`

```
2021-02-22 16:17:03 aligns_to version 0.55
2021-02-22 16:17:03 hardware threads: 1, omp threads: 1
2021-02-22 16:17:04 loading time (sec) 1
2021-02-22 16:17:04 SCRUBBER/Runs/SRR13402847.fastq.fasta
2021-02-22 16:17:04 15% processed
2021-02-22 16:17:26 100% processed
2021-02-22 16:17:47 total spot count: 216859
2021-02-22 16:17:47 total read count: 216859
2021-02-22 16:17:47 total time (sec) 44
```

```
$ ls -l Runs/
total 275816
 rw-rr- 1 xxx xxx 141280412 Feb 19 00:03 SRR13402847.fastq
 rw-rr- 1 xxx xxx 141151371 Feb 22 17:06 SRR13402847.fastq.clean
```