#!/usr/bin/R

#installation of of database packages from Bioconductor, if already installed not necessary
#first installing BiocManager as well as test db
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!requireNamespace("ensembldb", quietly = TRUE)) BiocManager::install("ensembldb")
if (!requireNamespace("EnsDb.Hsapiens.v86", quietly = TRUE)) BiocManager::install("EnsDb.Hsapiens.v86")

#installing locuszoomr from CRAN
if (!requireNamespace("locuszoomr", quietly = TRUE)) install.packages("locuszoomr")

library(EnsDb.Hsapiens.v86)
library(locuszoomr) 
library(argparse)
library(data.table)

#create parser object
parser <- ArgumentParser()

#specify our desired options: RSID and LD Token
parser$add_argument("--phecode", help="all of us phenotype ID", default=NULL)
parser$add_argument("--pop", help="all of us population ID", default=NULL)
parser$add_argument("--rsid", help = "Specify an index SNP rsID to plot")
parser$add_argument("--token", help = "Specify unique LD Link user token to plot with LD information")

args <- parser$parse_args()

#get the bucket name
my_bucket <- Sys.getenv('WORKSPACE_BUCKET')

#replace empty quotes with the name of the file in your google bucket (don't delete the quotation marks)
name_of_file_in_bucket <- paste0(args$pop, "_formatted_filtered_", args$phecode,".tsv")
read_in_command <- paste0("gsutil cp ", my_bucket, "/data/", name_of_file_in_bucket, " .")

#copy the file from current workspace to the bucket
system(read_in_command, intern=TRUE)
data <- fread(name_of_file_in_bucket, sep = "\t", header=TRUE)

#if rsid is user provided
if (!is.null(args$rsid)) {
  #creating locus object with user provided SNP
  loc <- locus(data = data, ens_db = "EnsDb.Hsapiens.v86", index_snp = args$rsid, flank = 1e5)
} else { 
  #rsid is not provided, so we default to most signif. SNP
  data$Pvalue <- as.numeric(as.character(data$Pvalue)) #ensure p-values are numeric
  if(any(is.na(data$Pvalue))) {
    cat("Warning: NA values found in Pvalue column, removing NA rows from analysis\n")
    signif_rsid <- which.min(data$Pvalue[!is.na(data$Pvalue)])
    cat(signif_rsid, "\n")
  } else {
    signif_rsid <- data$rsID[which.min(data$Pvalue)]
    cat(signif_rsid, "\n")
  }
  # creating locus object with top hit SNP
  cat("rsID not provided; running locuszoom on lowest p-value SNP\n")
  loc <- locus(data = data, ens_db = "EnsDb.Hsapiens.v86", index_snp = signif_rsid, flank = 1e5)
}

#make a one-time request for your personal access token from a web browser at https://ldlink.nih.gov/?tab=apiaccess.
#if LD link token is provided
if (!is.null(args$token)) {
  #try to link with LD information
  tryCatch({
    loc <- link_LD(loc, token = args$token)
    #if successful and SNP included in 1000 genomes, plot with LD
    has_ld <- TRUE
  }, error = function(e) {
    #if error (SNP not in 1000G), continue without LD
    cat("Index SNP not found in 1000G panel. Plotting without LD information.\n")
    has_ld <- FALSE
  })
} else {
  has_ld <- FALSE
}

#save to png
output_filename <- paste0(args$pop, "_locuszoom_", args$phecode, ".png")
png(output_filename, width = 1200, height = 800)
locus_plot(loc, labels = c("index"), label_x = c(4, -5))
dev.off()

cat("LocusZoom plot complete\n")
