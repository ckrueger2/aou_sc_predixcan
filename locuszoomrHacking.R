## Installation of of database packages from Bioconductor, if already installed not necessary ##

# First installing BiocManager as well as test db
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
if (!requireNamespace("data.table", quietly = TRUE))
  install.packages("data.table")
BiocManager::install("ensembldb")
BiocManager::install("EnsDb.Hsapiens.v86")

# installing locuszoomr from CRAN
install.packages("locuszoomr")
library(locuszoomr)

# Reading in table
data <- read.table('cleaned_TESTDATA_hacking.txt', 
                   header = TRUE, sep = "\t")

# Reformatting column headers
colnames(data)[colnames(data) == "Pvalue"] <- "p"
colnames(data)[colnames(data) == "CHR"] <- "chrom"
colnames(data)[colnames(data) == "locus"] <- "rsid"

# Finding signif snp
signif_POS <- data$POS[which.min(data$p)]
signif_chrom <- data$chrom[which.min(data$p)]


# creating locus object
loc <- locus(data = data, ens_db = "EnsDb.Hsapiens.v86", xrange = c(signif_POS-100000, signif_POS+100000), 
            seqname = signif_chrom, flank = 1e5)

#summary(loc)

# plotting locuszoomr
locus_plot(loc)

