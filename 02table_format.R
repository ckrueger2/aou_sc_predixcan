#!/usr/bin/R

cat("Beginning table formatting...")

#if needed, install packages
if (!requireNamespace("data.table", quietly = TRUE)) install.packages("data.table")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("tidyr", quietly = TRUE)) install.packages("tidyr")
if (!requireNamespace("argparse", quietly = TRUE)) install.packages("argparse")

#load packages
library(data.table)
library(dplyr)
library(tidyr)
library(argparse)

#set up argparse
parser <- ArgumentParser()
parser$add_argument("--phecode", help="all of us phenotype ID")
parser$add_argument("--pop", help="all of us population ID")
parser$add_argument("--cell_type", help="cell_type to filter by for single cell S-PrediXcan")

args <- parser$parse_args()

#find bucket
my_bucket <- Sys.getenv('WORKSPACE_BUCKET')

#PERFORM COMMAND LINE FORMATTING FOR S-PREDIXCAN FILE
#upload single cell SNP file to workspace bucket
command7 <- paste0("gsutil -m cp -v ~/aou_sc_predixcan/sc_predixcan_models_varids-effallele_", args$cell_type,".txt.gz ", my_bucket, "/data/")
system(command7, intern=TRUE)

#unzip files
command8 <- paste0("gsutil cat ", my_bucket, "/data/sc_predixcan_models_varids-effallele_", args$cell_type,".txt.gz | gunzip > /tmp/predixcan_models_varids-effallele.txt")
system(command8)

#format reference file
system("awk -F'[,:]' 'NR>1 {print $1\":\"$2}' /tmp/predixcan_models_varids-effallele.txt > /tmp/chrpos_allele_table.tsv", intern=TRUE)

#make temp files
command9 <- paste0("gsutil cp ", my_bucket, "/data/", args$pop, "_full_", args$phecode,".tsv /tmp/")
system(command9)

#filter SNPs
command10 <- paste0("awk 'NR==FNR{a[$1];next} $1 in a' /tmp/chrpos_allele_table.tsv /tmp/", args$pop, "_full_", args$phecode, ".tsv > /tmp/sc_", args$phecode, ".tsv")
system(command10)

#save to bucket
command11 <- paste0("gsutil cp /tmp/sc_", args$phecode, ".tsv ", my_bucket, "/data/", args$pop, "_sc_", args$phecode,".tsv")
system(command11)

#check bucket
check_result2 <- system(paste0("gsutil ls ", my_bucket, "/data/ | grep ", args$pop, "_sc_", args$phecode, ".tsv"), ignore.stderr = TRUE)

if (check_result2 != 0) {
  stop(paste0("ERROR: File '", args$pop, "_sc_", args$phecode, ".tsv' was not found in bucket ", my_bucket, "/data/"))
} else {
  cat("Reference single cell file successfully transferred to bucket.\n")
}

#FORMAT TABLES
#read in sc filtered table
name_of_sc_file <- paste0(args$pop, "_sc_", args$phecode, ".tsv")
sc_command <- paste0("gsutil cp ", my_bucket, "/data/", name_of_sc_file, " .")

system(sc_command, intern=TRUE)

sc_table <- fread(name_of_sc_file, header=FALSE, sep="\t")
colnames(sc_table) <- c("locus","alleles","BETA","SE","Het_Q","Pvalue","Pvalue_log10","CHR","POS","rank","Pvalue_expected","Pvalue_expected_log10")

#check table
cat("sc filtered table preview:\n")
head(sc_table)

#SINGLE CELL TABLE
#reformat locus column to chr_pos_ref_alt_b38
sc_table$locus_formatted <- gsub(":", "_", sc_table$locus) #colon to underscore
sc_table$alleles_formatted <- gsub('\\["', "", sc_table$alleles)  #remove opening [
sc_table$alleles_formatted <- gsub('"\\]', "", sc_table$alleles_formatted)  #remove closing ]
sc_table$alleles_formatted <- gsub('","', "_", sc_table$alleles_formatted)  #comma to underscore

#split allele column
sc_table <- sc_table %>%
  separate(alleles_formatted, into = c("REF", "ALT"), sep = "_", remove=F)

#combine strings
sc_table$SNP <- paste0(sc_table$locus_formatted, "_", sc_table$alleles_formatted, "_b38")
sc_table$ID <- paste0(sc_table$locus, ":", sc_table$REF, ":", sc_table$ALT)

#remove intermediate columns
sc_table$locus_formatted <- NULL
sc_table$alleles_formatted <- NULL

#edit sex chromosomes
sc_table$CHR <- gsub("X", "23", sc_table$CHR)
sc_table$CHR <- gsub("Y", "24", sc_table$CHR)

#FINAL FORMATTING
#format chromosomes
sc_table$CHR <- gsub("chr", "", sc_table$CHR)
sc_table$CHR <- gsub("X", "23", sc_table$CHR)
sc_table$CHR <- gsub("Y", "24", sc_table$CHR)

#sort by chr, pos
sc_table <- sc_table %>%
  arrange(CHR, POS)

#rename header
sc_table$"#CHROM" <- sc_table$CHR
sc_table$CHR <- NULL

#select columns
sc_table <- sc_table %>%
  select(locus, alleles, ID, REF, ALT, "#CHROM", BETA, SE, Pvalue, SNP)

#edit X chromosome SNP file for sc table
sc_table$SNP <- gsub("^chrX_", "X_", sc_table$SNP)

#check table
cat("Final single cell filtered table:\n")
head(sc_table)

#write sc table
sc_destination_filename <- paste0(args$pop, "_formatted_sc_", args$cell_type, "_", args$phecode,".tsv")

#store the dataframe in current workspace
write.table(sc_table, sc_destination_filename, col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")

#copy the file from current workspace to the bucket
system(paste0("gsutil cp ./", sc_destination_filename, " ", my_bucket, "/data/"), intern=TRUE)

#CHECK IF FILES ARE IN THE BUCKET
#sc file
check_sc <- system(paste0("gsutil ls ", my_bucket, "/data/ | grep ", sc_destination_filename), ignore.stderr = TRUE)

if (check_sc != 0) {
  stop(paste0("ERROR: File '", sc_destination_filename, "' was not found in bucket ", my_bucket, "/data/"))
} else {
  cat("sc formatted file successfully saved to bucket.\n")
}

#clean up tmp files
system(paste0("rm -f /tmp/predixcan_models_varids-effallele.txt /tmp/chrpos_allele_table.tsv /tmp/", args$pop, "_full_", args$phecode, ".tsv /tmp/sc_", args$phecode, ".tsv"), intern=TRUE)
