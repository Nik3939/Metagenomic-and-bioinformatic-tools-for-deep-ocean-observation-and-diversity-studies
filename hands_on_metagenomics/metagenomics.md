# Metagenomics Hands-On
## Metagenomic and bioinformatic tools for deep-ocean observation and diversity studies
### 2026-05-05 to 2026-05-08

> [!IMPORTANT]
> This tutorial will be used for the hand-son section in metagenomics.

## Access to the virtual machine - Instructions

In order to allow the participants to run the analysis, a server (remote computer) has been provided.
To access the machine, please run in your terminal the following command:

```
ssh root@178.104.74.191
```

## Tmux
>[!TIP]
> __tmux__ is a terminal multiplexer. 
>It lets you switch easily between several programs in one terminal, detach them (they keep running in the background) and reattach them to a different terminal.

`tmux` will be used to ensure your analysis will keep running in case of connection issues or other kind of technical problems.

To open a new session
```
tmux new-session -t name
```

To detach from the open session, ensuring it keeps running in the background press `CTRL+B` and then `D`.

To attach a pre-existing session
```
tmux attach-session -t name
```

To kill a pre-existing session
```
tmux kill-session -t name
```

To get a list of the currently existing session
```
tmux ls
```

## Activating conda environment

All softwares you will need for the analysis have been already been installed and tested. They are in a `conda` environment that was called `bioconda`. In order to activate it, please run this command once logged in the server:
```
conda activate bioconda
```

## Organizing the working space

In order to have a clear organization of our files during our analysis, the first step is to create a directory to store all the files we will create during the workshop.

```
mkdir workshop
```

Then, we create a directory for the sample we will analyze and we enter in it.
From now on, all the example will use the sample name `nice6`. You will have to change it for your actual sample name.
```
mkdir nice6
```
Then, enter the directory
```
cd workshop/nice6
```

## Downloading Data
Now it is time to download the data from the [European Nucleotide Archive (ENA)](https://www.ebi.ac.uk/ena/browser/home).

The data we will work today are from a study on the biosynthetic potential of the Arctic Ocean available [here](https://pmc.ncbi.nlm.nih.gov/articles/PMC8767328/).

In order to retrieve the data, we need to find the data availability statement with the link to the data repository. In this case, we will find it in the `Data Summary` section. 

<details>
<summary>Reveal accession code</summary>

The code is `PRJEB15043`.

<br>
</details>
<br>

Using the [ENA browser](https://www.ebi.ac.uk/ena/browser/home) we can search the code and find the different samples that were uploaded. For our analysis, we will use two samples from different stations both located at 250m below the sea surface.

When you click on "download FASTQ file" you will obtain a file with a name like this one: `ena-file-download-read_run-SAMEA104141260-submitted_ftp-DATE-TIME.sh`.

This file is a `BASH`script and it is meant to be run in a terminal to download the actual FASTQ files.

If you open the file with a text editor like `Notepad` you will see something like this:

```
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR201/ERR2017144/nice6_R1.fastq.bz2
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR201/ERR2017144/nice6_R2.fastq.bz2
```
The above command will download the forward and reverse file of the `nice6` sample, one of the two sample we will work on.

We need to run them inside a directory that we will call `data` to keep them separated by the other future files.

First, create the directory
```
mkdir data
```

Then, enter it
```
cd data
```

Finally, we need to decompress the files. In order to do so, run:

```
bzip2 -d *
```
>[!Tip]
>The `*` is a regex symbol that indicate to the command to execute the decompression routine on every file present in the current folder

>[!Tip]
>Some of the softwares we will use can work on compressed files but for simplicity we will decompress them and actual work on the 'traditional' formats (FASTQ, ...)

## Quality check (1)

The first thing you want to do when you receive or download sequencing data is to assess their quality. 

You can do this by running `FastQC`, a well-established java software that provide several information on your sequences.

However, before doing so, there is another nice tool to know that is very quick to give some basic info on sequencing data. That is `seqkit`

>[!TIP]
>`seqkit` can actually do a lot of different operations. If you are curious I invite you to visit [this site](https://github.com/shenwei356/seqkit)

### running seqkit

`seqkit stats` will give you some information about your sequences. Please run:
```
seqkit stats data/nice6_R1.fastq
```
```
seqkit stats data/nice6_R2.fastq
```

### running FastQC

As always, it is important to keep our data in order.
Let's create a directory to store the output of the program.
```
mkdir 1_fastqc_results
```
>[!TIP]
>putting numbers at the beginning of our output directory can be helpful to remember us the order we used them and the general pipeline direction in case we come back at them after some time

Now we run fastqc.
```
fastqc -o fastqc_results --threads 30 data/nice6_R1.fastq data/nice6_R2.fastq
```

FastQC produce a nice HTML report that we can open in our web browser of preference. This is not possible from the server as it command-line interface (CLI) only and we need a graphical user interface (GUI). To solve the issue we will download the data.

In order to download results run the following:
```
scp -r root@178.104.74.191:workshop/nice6/1_fastqc_results .
```
>[!Tip]
>The command `scp` is used to copy files and folders from remote to local machines and vice versa

Now a html report is present for each sample in the folder `1_fastqc_r`.

## Clipping, Trimming, and Filtering

Once assessed the initial quality of our sequences, we can perform 3 different tasks:
1. Clipping: removal of Illumina adapters
2. Trimming: removal of sequences based on nucleotide quality thresholds
3. Filtering: removal of sequences based on lenght thresholds

In our case, we will use `Trimmomatic`, a well-established software that perform the 3 steps one after the other in a single command.

We will first create a folder to store our results (assuming you are at `~/workshop/nice6/`):
```
mkdir 2_trimmomatic_results
```
Then, you enter the folder
```
cd 2_trimmomatic_results
```

Since Illumina Adapters were detected, we need to use a FASTA file containing possible adapters to try to trim them away.
This file has already been created and it is called `illumina_adapaters.fasta`

>[!CAUTION]
>Usually you want to use the adapters that were used in the library preparation specifically used for your samples

Finally, we run trimmomatic:
```
trimmomatic PE -phred33 -trimlog trimming_log -summary trimming_summary ../data/nice6_R1.fastq ../data/nice6_R2.fastq nice6_f_p.fastq nice6_f_u.fastq nice6_r_p.fastq nice6_r_u.fastq ILLUMINACLIP:illumina_universal_adapters.fasta:2:30:10 LEADING:10 TRAILING:10 SLIDINGWINDOW:5:20 MINLEN:20
```
>[!Tip]
>We know the PHRED encoding is 33 due to FastQC reporting `Sanger / Illumina 1.9` in the "Encoding" field

Here a useful table about `PHRED score encoding`:

| Variant | ASCII Range | Offset |
|------|------|------|
|Sanger|33 to 126|33|
|Illumina1.3 or <|64 to 126|64|
|Illumina1.8 or >|33 to 95|33|

## Quality check (2)

Once the trimming is done, we can compare the quality of our reads between before and after the trimming. To do so, we run FastQC once again on the results we obtained from Trimmomatic.

Exit current directory
```
cd ..
```
Create a new directory
```
mkdir 3_fastqc_results
```
Run FastQC
```
fastqc -o 3_fastqc_results --threads 30 2_trimmomatic_results/nice6_f_p.fastq 2_trimmomatic_results/nice6_r_p.fastq
```
>[!CAUTION]
>Normally, gentle trimming is enough to proceed with the assembly. 
>However, it is important to dedicate enough time to the quality filtering and trimming 
>as such data are the __foundation__ of all the downstream analysis.

## Assembly

Once we are satisfied with the quality filtering, it is time to assemble our reads in `contigs`.

>[!TIP]
> We will run two different assembly softwares that use different approaches based on __De Brujin Graph__. 
> It is always a good practice to run a couple or more assembly softwares and compare the results rather than run a single one only.

### Megahit2

In order to run megahit 

```
megahit -t 30 -o 4_megahit_results -1 2_trimmomatic_results/nice6_f_p.fastq -2 2_trimmomatic_results/nice6_r_p.fast
```
An output folder called `4_megahit_results` will automatically created and it will store the results.

### Metaspades

In order to run metaspades

```
metaspades.py -1 2_trimmomatic_results/nice6_f_p.fastq -2 2_trimmomatic_results/nice6_r_p.fastq -t 30 -o 4_metaspades_results
```
An output folder called `4_metaspades_results` will automatically created and it will store the results.

## Quality check (3) 

Quality checks are very important steps in a metagenomic analysis. Similarly to before, we will show two tools: `assembly-stats` and `metaquast`. The first give you back useful information pretty quickly, the second one is slow but give you a really comprehensive set of informations.

### running assembly-stats

```
assembly-stats 4_megahit_results/final.contigs.fa
```
```
assembly-stats 4_metaspades_results/contigs.fasta
```
```
assembly-stats 4_metaspades_results/scaffolds.fasta
```

### running MetaQuast

```
metaquast.py -o 5_metaquast_results -l megahit,metaspades_contig,metaspades_scaffold -t 30 --rna-finding 4_megahit_results/final.contigs.fa 4_metaspades_results/contigs.fasta 4_metaspades_results/scaffolds.fasta
```

## Mapping

After ensuring the good quality of the assembly, we now need to prepare for the binning step. In order to do so, we need to map clean reads to our obtained assembly to use the depth information for grouping contigs in bins.
To do so, we first need to index the assembly using `bowtie2-build`. 

>[!TIP]
>This is necessary as the binning software we will use make use of this information

Let's first create a folder to store the results:
```
mkdir 6_bowtie2_results
```
And access it:
```
cd 6_bowtie2_results
```

Now, we need to __index__ our assembly as we will use it as `reference genome` for our sequence alignment.
To do so, we use a very well-established tool called `bowtie2`

### running bowtie2
```
bowtie2-build --threads 30 -f ../4_metaspades_results/scaffolds.fasta nice6
```
Then we query the indexed assembly with the cleaned reads.
Let's run the command.
```
bowtie2 -x nice6 -1 ../2_trimmomatic_results/nice6_f_p.fastq -2 ../2_trimmomatic_results/nice6_r_p.fastq -q --phred33 --threads 30 > nice6.sam 2> nice6.log
```
>[!TIP]
>The `>` and `2>` operators capture the `stdout` and the `stderr` output of bowtie2.

Now, we need to convert the `SAM` output to a sorted and binary file `BAM`. 
We do this by running `samtools`.
```
samtools sort -@ 30 nice6.sam -o nice6.bam
```

>[!TIP]
>`BAM` is the binary version of `SAM`

## Binning

Finally, we want to group our `contigs/scaffolds` into `bins`. As per the assembly, it is better to run multiple binning softwares. But this time we won't compare them but rather __combine__ them.

### running MetaBat2
First, we create a directory to store the results and we enter in it (assuming we are in `~/workshop/nice6/`).
```
mkdir 7_metabat2_results
```
```
cd 7_metabat2_results
```

Then we run the binning software
```
runMetaBat.sh ../4_metaspades_results/scaffolds.fasta ../6_bowtie2_results/nice6.bam
```

## running CONCOCT
Running CONCOCT require a bit more of work respect to MetaBat2. First we need an additional file, a `BAI`file consisting of the indexed version of our `BAM`.

To obtain we enter the `bowtie2` folder
```
cd ~/workshop/nice6/6_bowtie2_results
```
And we run there `samtools index` command:
```
samtools index nice6.bam -b nice6.bai
```

Now we can turn back to our sample folder.
```
cd ~/workshop/nice6
```
Create a directory to store CONCOCT results.
```
mkdir 7_concoct_results
mkdir 7_concoct_results/mapping
```
Copy the `BAM`and `BAI`files to the mapping directory.
>[!CAUTION]
>Making copies of BAM and BAI files can fill up your server memory quickly. It is better practice to just point to the file locations when you ran CONCOCT.
>For the sake of ease, we will copy them.

```
cp 6_bowtie2_results/nice6.bai 7_concoct_results/mapping/.
cp 6_bowtie2_results/nice6.bam 7_concoct_results/mapping/.
```

Now we run the first CONCOCT command:
```
cut_up_fasta.py 4_metaspades_results/scaffolds.fasta -c 10000 -o 0 --merge_last -b 7_concoct_results/contigs_10K.bed > 7_concoct_results/contigs_10K.fa
```
We enter in the results folder
```
cd ~/workshop/nice6/7_concoct_results
```
and we run the second one:
```
concoct_coverage_table.py contigs_10K.bed mapping/nice6.bam > coverage_table.tsv
```
then, the third one:
```
concoct --composition_file contigs_10K.fa --coverage_file coverage_table.tsv --threads 30 -b output/
```
This will automatically create an `output` folder.

Running the next command:
```
merge_cutup_clustering.py output/clustering_gt1000.csv > output/clustering_merged.csv
```
To run the final one, we need to create a new directory called `fasta_bins` to store our bins.
```
mkdir output/fasta_bins
```
Finally, we run:
```
extract_fasta_bins.py ../4_metaspades_results/scaffolds.fasta output/clustering_merged.csv --output_path output/fasta_bins
```

### running DASTool
DASTool will allow us to combine the bins obtained from `MetaBat2` and `CONCOCT`and select the best ones.

#### Input preparation
Before being able to run it, we need to prepare two input files, consisting of tables mapping the contig to the bins for `CONCOCT` and `MetaBat2`

##### For MetaBat2
Let's check that the bin folder of MetaBat2 only contains bins.
```
mv 7_metabat2_results/scaffolds.fasta.metabat-bins-20260503_170859/bin.BinInfo.txt 7_metabat2_results/.
```

Create the DASTool folder
```
mkdir 8_DASTool_results
```
And enter it
```
cd 8_DASTool_results
```
Run the `BASH`script provided by DASTool to create the `.tsv` table that will be our input for DASTool.
```
Fasta_to_Contig2Bin.sh -e fa -i ../7_metabat2_results/scaffolds.fasta.metabat-bins-20260503_170859 > metabat2bin.tsv
```
>[!CAUTION]
> It may be possible that this file is still not ready to be fed to DASTool
> Open it and check that it consists of only two columns, one for contigs and one for bin.
> If not, run `awk -F"\t" '{print $1"\t"$4}' metabat2bin.tsv > metabat22bin.tsv`

##### For CONCOCT
To prepare the `.tsv` table from CONCOCT data, we need to run:
```
awk -F "," 'NR>1{print $1"\t"$2}' ../7_concoct_results/output/clustering_merged.csv | sed 's/\.concoct_part_[0-9]//g' > concoct2bin.tsv
```
##### Running DASTool
Finally, we can run DASTool
```
DAS_Tool -i metabat22bin.tsv,concoct2bin.tsv -c ../4_metaspades_results/scaffolds.fasta -l metabat2,concoct -o nice6 --write_bin_eval --write_bins --threads 30
```

## Quality Check (4)

Now it is time for the last quality check, where we assess the completeness and contamination of our bins, together with other informative statistcs.
>[!TIP]
>Also here, it is best practice to compare quality assessment from multiple softwares.
>We will run `checkm`, `checkm2`, and `BUSCO`

### Running checkm
```
mkdir 9_checkm_results
```

```
cd 9_checkm_results
```

```
checkm lineage_wf -t 30 -x fa ../8_DASTool_results/nice6_DASTool_bins . > checkm.out 2> checkm.log
```
### Running checkm2
Assuming you are at `~/workshop/nice6/`
Run
```
checkm2 predict --threads 30 --input ../8_DASTool_results/nice6_DASTool_bins --output-directory 9_checkm2_results -x fa
```
