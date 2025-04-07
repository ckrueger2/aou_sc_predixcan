# Rscript /home/2025/acarcione/qqman_hacking.r
 
install.packages("qqman")

library(qqman)

data <- read.table('~/reformat_output_file.txt', 
                   header = TRUE, 
                   sep = ' ', 
                   stringsAsFactors = FALSE)

# make the chromosome numerical because if you dont its a character and you get error
data$CHR <- as.numeric(data$CHR)

head(data)

# gets rid of any NA values introduced "by coercion"
data <- data[!is.na(data$CHR), ]


manhattan(
data,
chr = "CHR",
bp = "BP",
p = "P",
snp = "SNP",
col = c("red", "blue"),
suggestiveline = -log10(1e-05),
genomewideline = -log10(5e-08),
logp = TRUE,
annotateTop = TRUE,
)


