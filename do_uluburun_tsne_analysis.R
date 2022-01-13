library(foreach)

# Clear the workspace
rm(list=ls())

# Load the analysis functions
source("uluburun_functions.R")

# Load the data
artifacts <- load_uluburun_data("Supplemental Data Table.xlsx")

unique_groups <- sort(unique(artifacts$Group))
num_groups <- length(unique_groups)

#> print(unique_groups)
#[1] "MC1A"    "MC1B"    "MC1C"    "MC2A"    "MC2B"    "P1"      "P2A"
#[8] "P2B"     "Unknown"

# group_colors is a matrix where each row is the RGB value for the group
group_colors <- cbind(
  c( 95, 132, 167), # MC 1A
  c(135, 171, 205), # MC 1B
  c(203, 231, 243), # MC 1C
  c(119, 177, 126), # MC 2A
  c(202, 228, 191), # MC 2B
  c(198,  79, 111), # P1
  c(251, 206, 200), # P 2A
  c(245, 173,  97), # P 2B
  c(187, 149, 198)  # Unk
)

# group_colors must be transposed to create the color matrix used below
col_matrix <- t(group_colors)

# Initialize a vector of colors, then modify it
colors <- rep(NA, num_groups)
for(cc in 1:length(colors)) {
  colors[cc] <- grDevices::adjustcolor(
    rgb(col_matrix[cc,1],col_matrix[cc,2],col_matrix[cc,3],maxColorValue=255),
    alpha.f=0.85)
}
names(colors) = unique(artifacts$Group)

# Set colors for each observation
N <- nrow(artifacts)
col_vect <- rep(NA,N)
for (n in 1:N) {
  col_vect[n] <- colors[which(artifacts$Group[n] == unique_groups)]
}

# Use ingot Form to set scatter plot shapes
shape_vect <- rep(NA,N)

for (n in 1:N) {
  if (artifacts[n,'Form'] == 'Anchor') {
    shape_vect[n] <- 8
  } else if (artifacts[n,'Form'] %in% c('Bun', 'Bun-Pb Bars', 'Unique')) {
    shape_vect[n] <- 19
  } else if (artifacts[n,'Form'] == 'Fragment') {
    shape_vect[n] <- 4
  } else if (artifacts[n,'Form'] == 'Oxhide') {
    shape_vect[n] <- 15
  } else if (artifacts[n,'Form'] %in% c('Slab', 'Slab Thin')) {
    shape_vect[n] <- 23
  } else if (artifacts[n,'Form'] == 'Wedge') {
    shape_vect[n] <- 25
  } else {
    stop(paste0('Unrecognized form = ', paste0(artifacts[n, 'Form'])))
  }
}

# The tsne uses columns 5:8, corresponding to column names:
# 206/204, 207/204, 208/204, 124/116
M <- artifacts[,5:8]
testthat::expect_equal(
  names(M),
  c("206/204", "207/204","208/204","124/116")
)

# Normalizes the columns
for (column in 1:ncol(M)) {
  v <- M[,column, drop=TRUE]
  v <- v - mean(v)
  v <- v / sd(v)
  M[,column] <- v
}

tsne <- tsne_with_restarts(M,
                           1000,
                           base_seed=876966)

# 9734
pdf("uluburun_tsne.pdf")
  plot(tsne$Y[,1], tsne$Y[,2], col=col_vect, bg=col_vect, pch=shape_vect,
       asp=1, xlab="tsne-1", ylab="tsne-2", cex=2.0)
dev.off()

# Create a matrix of scatter plots using pairs, including the following
# variables:
#
# tsne-1
# tsne-2
# 206/204  -- Input to tsne
# 207/204  -- Input to tsne
# 208/204  -- Input to tsne
# 124/116  -- Input to tsne
#      Cu  --  Not input to tsne (column 12)
#      Te  --  Not input to tsne (column 20)
#      Au  --  Not input to tsne (column 23)
Y <- tsne$Y
colnames(Y) <- c('tsne-1', 'tsne-2')
X <- cbind(Y, artifacts[,c(5:8, 12, 20, 23)])
testthat::expect_equal(
  names(X),
  c("tsne-1", "tsne-2",
    "206/204", "207/204", "208/204", "124/116",
    "Cu", "Te", "Au")
)

pdf('uluburun_pairs_plot.pdf', width=20, height=20)
  pairs(X, col=col_vect,bg=col_vect, pch=shape_vect)
dev.off()