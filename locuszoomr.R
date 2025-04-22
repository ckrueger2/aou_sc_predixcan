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

# Get the bucket name
my_bucket <- Sys.getenv('WORKSPACE_BUCKET')

# replace empty quotes with the name of the file in your google bucket (don't delete the quotation marks)
fileName = ""

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

# creating locus object and linking LD link
loc2 <- locus(data = data_small, ens_db = "EnsDb.Hsapiens.v86", index_snp = "REPLACE WITH SNP ID OF INTEREST", 
              flank = 1e5)

loc2 <- link_LD(loc2, token = "REPLACE WITH LD LINK TOKEN")

# Plotting locuszoomr plot
# plotting locuszoomr
locus_plot(loc2, labels = c("index"), label_x = c(4, -5))