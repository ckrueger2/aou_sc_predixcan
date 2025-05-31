if (!requireNamespace("coloc", quietly = TRUE)) install.packages("coloc")

library(dplyr)
library(data.table)
library(coloc)

#find bucket
my_bucket <- Sys.getenv('WORKSPACE_BUCKET')

#read in MESA pQTL table
name_of_pqtl_file <- "META_mesa_pqtls.txt"
pqtl_command <- paste0("gsutil cp ", my_bucket, "/data/", name_of_pqtl_file, " .")
system(pqtl_command, intern=TRUE)
qtl_data <- fread(name_of_pqtl_file, header=TRUE)

#read in AoU GWAS table
name_of_gwas_file <- "META_formatted_mesa_CV_404.tsv"
gwas_command <- paste0("gsutil cp ", my_bucket, "/data/", name_of_gwas_file, " .")
system(gwas_command, intern=TRUE)
gwas_data <- fread(name_of_gwas_file, header=TRUE)

#ID SNPs
qtl_data$variant_key <- gsub("chr", "", qtl_data$variant_id)
gwas_data$variant_key <- paste(gwas_data$CHR, gwas_data$POS, gwas_data$REF, gwas_data$ALT, sep = ":")

#find common SNPs
common_variants <- intersect(qtl_data$variant_key, gwas_data$variant_key)

#filter to common SNPs
qtl_coloc <- qtl_data[qtl_data$variant_key %in% common_variants, ]
gwas_coloc <- gwas_data[gwas_data$variant_key %in% common_variants, ]

#merge tables
merged_data <- merge(qtl_coloc, gwas_coloc, by = "variant_key")

# Prepare datasets
dataset1 <- list(
  beta = merged_data$slope,
  varbeta = merged_data$slope_se^2,
  snp = merged_data$variant_key,
  type = "quant",
  N = 2953 #META: 2953, EUR: 1270
)

dataset2 <- list(
  beta = merged_data$BETA,
  varbeta = merged_data$SE^2,
  snp = merged_data$variant_key,
  type = "quant",
  N = 276112  #META: 276112, EUR: 111887
)

#run coloc
result <- coloc.abf(dataset1, dataset2)

#output
print(result$summary)
