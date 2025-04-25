## Installation of of database packages from Bioconductor, if already installed not necessary ##

# First installing BiocManager as well as test db
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
if (!requireNamespace("data.table", quietly = TRUE))
  install.packages("data.table")
BiocManager::install("ensembldb")
BiocManager::install("EnsDb.Hsapiens.v86")
library(EnsDb.Hsapiens.v86)

# installing locuszoomr from CRAN
install.packages("locuszoomr")
library(locuszoomr)

# installing argparse library
install.packages("argparse")
library(argparse)

# Create parser object
parser <- ArgumentParser()

# specify our desired options: RSID and LD Token
parser$add_argument("--rsid", help = "Specify an index SNP rsID to plot", default = NULL)
parser$add_argument("--token", help = "Specify unique LD Link user token to plot with LD 
                    information", default = NULL)
parser$add_argument("-i", "--input", help = "Specify the name of the GWAS summary statistics file", default = NULL)
args <- parser$parse_args()

# Get the bucket name
my_bucket <- Sys.getenv('WORKSPACE_BUCKET')

# replace empty quotes with the name of the file in your google bucket (don't delete the quotation marks)
name_of_file_in_bucket = (args$input)

# Get the bucket name
my_bucket <- Sys.getenv('WORKSPACE_BUCKET')

# Copy the file from current workspace to the bucket
system(paste0("gsutil cp ", my_bucket, "/data/", name_of_file_in_bucket, " ."), intern=T)

# Load the file into a dataframe
data <- read.table(file = name_of_file_in_bucket,
                            sep = "\t", header = TRUE)

# Reformatting column headers
colnames(data)[colnames(data) == "P"] <- "p"
colnames(data)[colnames(data) == "CHR"] <- "chrom"

# if rsid is user provided
if (!is.null(args$rsid)) {
  # creating locus object with user provided SNP
  loc <- locus(data = data, ens_db = "EnsDb.Hsapiens.v86", index_snp = args$rsid, 
                flank = 1e5)
} else { 
  # rsid is not provided, so we default to most signif. SNP
  signif_rsid <- data$rsIS[which.min(data$p)]

  # creating locus object with top hit SNP
  loc <- locus(data = data, ens_db = "EnsDb.Hsapiens.v86", index_snp = signif_rsid, 
                flank = 1e5)
}

# if LD link token is provided
if (!is.null(args$token)) {
  # creating locus object with LD info
  loc <- link_LD(loc, token = args$token)

  # plot locus with LD info
  locus_plot(loc, labels = c("index"), label_x = c(4, -5))
} else {
  # plot locus without LD info
  locus_plot(loc, labels = c("index"), label_x = c(4, -5))
}

