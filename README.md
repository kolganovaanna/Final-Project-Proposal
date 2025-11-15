## General information

- Author: Anna kolganova
- Date: 2025-11-10
- Environment: Pitzer cluster at OSC via VS Code
- Working dir: `/fs/ess/PAS2880/users/kolganovaanna/ProjectProposal`

## Assignment background

This is a final project proposal focusing on analyzing 16S sequencing data obtained by processing rumen fluid samples. 

## Protocol

**Part A**: Obtaining and describing the samples 

1. Study selection and description

I obtained samples from the study proposed and found by Menuka: [research paper](https://academic.oup.com/ismej/article/16/11/2535/7474101#435086839). This study focuses on exploring metabolically distinct microorganisms found in the rumen microbiota of 24 beef cattle. I was interested in the study because I work with ruminal microbiome in the scope of my Ph.D. research. Analyzing such datasets can help me work on my own data in the future. 


2. Obtaining specific samples

I obtain specific samples by searching PRJNA736529 project number (the study project number) on the NIH website: [datasets](https://www.ncbi.nlm.nih.gov/biosample?LinkName=bioproject_biosample_all&from_uid=736529)
I chose samples #1 (run SRR14784363) and #14 (run SRR14784377). 

3. Run descriptions

* Run SRR14784363
This run consists of 99.44% identified reads and 0.56% unidentified reads. Out of the 99.44%, domain Bacteria composes 99.24% and domain Archaea contributes only 0.15%. The length of each read is 250. Learn more about the run using this link: [SRR14784363](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&page_size=10&acc=SRR14784363&display=metadata)

* Run SRR14784377
This run consists of 97.83% identified reads and 2.17% unidentified reads. Out of the 97.83%, domain Bacteria composes 96.80% and domain Archaea contributes only 0.95%. The length of each read is 250. Learn more about the run using this link: [SRR14784377](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&page_size=10&acc=SRR14784377&display=metadata)

I downloaded both runs as fastq files from the website pages provided above. 

I chose 2 runs instead of 1 to prove that the code I am going to develop is resproducible, as reproducibility is one of the core principles of any data analysis. 

**Part B**

This part focuses on describing specific steps I plan to take to analyze the runs. Note that this proposal is more practical than theoretical and will include some actual commands that I ran and some steps that I've already completed. So, you will see outputs in this directory. It may also include some steps I'm still in the process of figuring out. I included my practical work to gain feedback on the logic of the workflow and commands (if possible). I decided to leave some outputs because I wanted to see what's in the file to determine what exactly my analysis will focus on. It will also help to determine specific goals I want to achieve in my final submission. 

4. Creating a working directory and structurizing the project

To create the directory for this project, I used the following commands:

```bash
mkdir ProjectProposal
```

To structurize the project, I created a couple of directories within ProjectProposal:

```bash
touch README.md
mkdir data results scripts
```

Using Filezilla, I dragged the downloaded fastq files with my chosen runs to the "data" directory. 

I then initialized a Git repository, added .gitignore, and commited to README for the first time. 

```bash
git init
git add README.md
git commit -m "Committing to README to set up"
echo "results/" > .gitignore
echo "data/" >> .gitignore
git add .gitignore
git commit -m "Adding a Gitignore file"
```





To obtain 16S sequencing data

wc -l data/SRR14784356.fastq.gz
   
   head data/SRR14784356.fastq.gz
   
   grep -v data/SRR14784356.fastq.gz | wc -l
zcat data/SRR14784356.fastq.gz | grep -v "methanogen" | cut -f1 | sort | uniq > results/methane.txt

zcat data/SRR14784363.fastq | head -n 40

fastqc data/SRR14784356.fastq.gz -o results/qualitydistribution.txt
# or (if installed)
seqtk fqchk data/SRR14784356.fastq.gz > results/seqtk_fqchk.txt

module spider fastqc
module spider seqtk

To load the module, type:
   module load fastqc/0.12.1

   mkdir -p results/qltdist.txt
fastq data/SRR14784363.fastq -o results/qlt.txt
fastqc data/SRR14784363.fastq -o results/


head -n 40 data/SRR14784363.fastq

grep -v "^@" data/SRR14784363.fastq | wc -l
grep -v "^@" data/SRR14784377.fastq | wc -l

 cat data/SRR14784363.fastq | grep -v "^@" | cut -f3 | sort | uniq -c | sort -n

  cat data/SRR14784363.fastq | wc -l

   echo $(( $(wc -l < data/SRR14784363.fastq) / 4 ))

Let's check at least 1 overlapping sequence 
cat data/SRR14784363.fastq | grep -c "GCA"
cat data/SRR14784363.fastq | grep -c "TTTCGCA"
cat data/SRR14784363.fastq | grep -c "TCCTGTTTGCTACCCACGCTTTCGCA"
cat data/SRR14784363.fastq | grep -c "GTCTGGGACTACACGGGTATCTAATCCTGTTTGCTACCCACGCTTTCGCA"

  cat data/SRR14784363.fastq  | grep "^@" | cut -d= -f2 | sort | uniq -c | sort -n

  cat data/SRR14784363.fastq | grep "length=250" -A 1 | head -n 10

R1=data/SRR14784363.fastq
R2=data/SRR14784377.fastq

sbatch scripts/project_trimgalore.sh "$R1" "$R2" results/fastqc

for f in data/*.fastq; do
  cat "$f" | awk -v fn="$f" '
    NR%4==2 { seq=toupper($0); total++; if (seq ~ /A{10,}$/) poly++ }
    END { printf "%s\t%d\t%d\t%.2f%%\n", fn, total, poly, (total?100*poly/total:0) }
  '
done