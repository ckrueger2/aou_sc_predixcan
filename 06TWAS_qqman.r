# using biomart to find genomic coordinates of genes from spredixcan output
install.packages("BiocManager")
BiocManager::install("biomaRt")
library(biomaRt)

# data table and dplyr for data and table manipulation
install.packages("BiocManager")
BiocManager::install("data.table")
library(data.table)

install.packages("BiocManager")
BiocManager::install("dplyr")
library(dplyr)

# accessing the Ensembl biomart database for 'genes', specifically the human genes version 113 (can be changed or left out)
biomart_access <- useEnsembl(biomart = "genes", dataset = "hsapiens_gene_ensembl", version = "113")

# we read in the spredixcan output csv, making that our "df", or data frame for qqman plotting
# string as factors = false so they wont be categorized 
df <- read.csv("/home/jupyter/GWAS-TWAS-in-All-of-Us-Cloud/qqman-twas-input.csv", stringsAsFactors = FALSE)

# removes the decimal after the gene, helps with merging and searching in general 
# this doesnt rename the gene, instead creates a new column so we dont lose data
df$gene_id <- sub("\\..*", "", df$gene)

# head to see the data and make sure it was read correctly 
head(df, 10)

# use biomart to pull chromosomal location information 
# we need the gene_id to find it, the chromosomal name (chromosome), the start position and end position (we will only use start) and what the gene is called in the database
gene_coords <- getBM(
  attributes = c("ensembl_gene_id", "chromosome_name", "start_position", "end_position", "external_gene_name"),
  filters = "ensembl_gene_id",
  values = df$gene_id,
  mart = biomart_access
)

# attributes are the columns you want to retrieve/add from the database to your data
# filters are for ensuring that youre using the same data base as was used for the previous tools (spredixcan)
# values are what the database will use to search for your data, in our case the "cleaned up" gene_ids 
# mart is just the accessing that we created in the previous cell

# merge our TWAS table and biomart results 
merged_df <- merge(df, gene_coords, by.x = "gene_id", by.y = "ensembl_gene_id")

# merging the original "df", with new "gene_coords", gene_id in df and ensembl_gene_id in gene_coords into a new dataframe merged_df

# make P column is numeric and remove NA p-values and 0s
merged_df$P <- as.numeric(merged_df$pvalue)
merged_df <- merged_df[is.finite(merged_df$P) & merged_df$P > 0, ]

# make CHR rows numeric and remove rows with NA, keeping only autosomes (1-22)
merged_df$CHR <- as.numeric(merged_df$chromosome_name)
merged_df <- merged_df[!is.na(merged_df$CHR) & merged_df$CHR %in% 1:22, ]

# double check data
head(merged_df, 10)

# finding sample size to calculate threshold
sample_size <- nrow(merged_df)
#print(sample_size)

# calculate the new bonferroni and threshold based on sample size 
bonferroni_threshold <- 0.05 / sample_size
new_suggestive_threshold <- -log10(bonferroni_threshold)
#print(new_suggestive_threshold)

# use qqman to plot the chromosome, location, snp, and pvalue into manhattan plot
library(qqman)
manhattan(merged_df, chr = "chromosome_name", bp = "start_position", snp = "gene_name", p = "pvalue",
          main = "TWAS Manhattan Plot",
          col = c("mediumblue", "darkgreen"),
          suggestiveline = new_suggestive_threshold)

