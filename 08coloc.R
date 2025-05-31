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
#qtl_data$variant_key <- gsub("chr", "", qtl_data$variant_id)
#gwas_data$variant_key <- paste(gwas_data$CHR, gwas_data$POS, gwas_data$REF, gwas_data$ALT, sep = ":")

#extract unique phenotypes
unique_phenotypes <- unique(qtl_data$phenotype_id)

for (phenotype in unique_phenotypes) {
  cat("Processing phenotype:", phenotype, "\n")
  
  #filter QTL data for current phenotype
  qtl_subset <- qtl_data[qtl_data$phenotype_id == phenotype, ]
  
  #find common SNPs for each phenotype
  common_variants <- intersect(qtl_subset$variant_id, gwas_data$ID)
  
  if (length(common_variants) > 0) {
    # Filter to common SNPs
    qtl_coloc <- qtl_subset[qtl_subset$variant_id %in% common_variants, ]
    gwas_coloc <- gwas_data[gwas_data$ID %in% common_variants, ]
    
    #merge tables
    merged_data <- inner_join(gwas_coloc, qtl_coloc, by = c("ID" = "variant_id"))
    head(merged_data)
    
    pre_filter <- (nrow(merged_data))
    
    #remove duplicate SNPs
    duplicate_snps <- merged_data$ID[duplicated(merged_data$ID)]
    if (length(duplicate_snps) > 0) {
      cat("Found", length(duplicate_snps), "duplicate SNPs. Removing duplicates...\n")
      #keep most significant
      merged_data <- merged_data %>%
        group_by(ID) %>%
        slice_min(pval_nominal, n = 1, with_ties = FALSE) %>%
        ungroup()
    }

    post_filter <-(nrow(merged_data))

    cat("Pre-filter SNP count: ", pre_filter, " Post-filter SNP count: ", post_filter, "\n")
    
    #prepare datasets
    dataset1 <- list(
      beta = merged_data$slope,
      varbeta = merged_data$slope_se^2,
      snp = merged_data$ID,
      type = "quant",
      N = 2953, #META: 2953, EUR: 1270
      MAF = merged_data$af
    )
    
    dataset2 <- list(
      beta = merged_data$BETA,
      varbeta = merged_data$SE^2,
      snp = merged_data$ID,
      type = "quant",
      N = 276112,  #META: 276112, EUR: 111887
      sdY = 1
    )
    
    #run coloc
    result <- coloc.abf(dataset1, dataset2)

    # Print results
    cat("\n=== Colocalization Analysis Results ===\n")
    print(coloc_result$summary)
    
    cat("\nPosterior probabilities:\n")
    cat("PP.H0 (no association):", coloc_result$summary[1], "\n")
    cat("PP.H1 (association with trait 1 only):", coloc_result$summary[2], "\n")
    cat("PP.H2 (association with trait 2 only):", coloc_result$summary[3], "\n")
    cat("PP.H3 (association with both traits, different causal variants):", coloc_result$summary[4], "\n")
    cat("PP.H4 (association with both traits, shared causal variant):", coloc_result$summary[5], "\n")
    
    # Interpretation
    pp4 <- coloc_result$summary[5]
    if (pp4 > 0.8) {
      cat("\nInterpretation: Strong evidence for colocalization (PP.H4 > 0.8)\n")
    } else if (pp4 > 0.5) {
      cat("\nInterpretation: Moderate evidence for colocalization (PP.H4 > 0.5)\n")
    } else {
      cat("\nInterpretation: Weak/no evidence for colocalization (PP.H4 < 0.5)\n")
    }
    
    # Plot results if there are enough variants
    if (nrow(merged_data) > 5) {
      # Create comparison plot
      par(mfrow = c(2, 1))
      
      plot(-log10(merged_data$pval_nominal), 
           main = "QTL Association", 
           xlab = "Variant index", 
           ylab = "-log10(P-value)",
           pch = 20, col = "blue")
      
      plot(-log10(merged_data$Pvalue), 
           main = "GWAS Association", 
           xlab = "Variant index", 
           ylab = "-log10(P-value)",
           pch = 20, col = "red")
      
      par(mfrow = c(1, 1))
    }
    
    # Detailed results table
    cat("\n=== Detailed Results for Each Variant ===\n")
    detailed_results <- data.frame(
      variant = merged_data$variant_key,
      qtl_beta = merged_data$slope,
      qtl_se = merged_data$slope_se,
      qtl_pval = merged_data$pval_nominal,
      gwas_beta = merged_data$BETA,
      gwas_se = merged_data$SE,
      gwas_pval = merged_data$Pvalue
    )
    print(detailed_results)
    
    #view summary
    cat("Results for", phenotype, ":\n")
    print(result$summary)
    cat("\n")
  } else {
    cat("No common variants found for", phenotype, "\n\n")
  }
}
