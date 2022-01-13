#' @title Load isotopic and other data from file
#'
#' @description
#' The input is the path to a .xlsx file (likely Uluburun Ingots Grouped.xlsx)
#' containing artifact information in Sheet1. Load the data and return a
#' dataframe, renaming column 5 to be completeness.
#'
#' @param file_path Path the the input file
#'
#' @return The artifacts dataframe
#'
#' @export
load_uluburun_data <- function(file_path) {
    artifacts <- readxl::read_excel(file_path, sheet = "Sheet1")
    #artifacts <- read.csv(file_path, stringsAsFactors=FALSE)
    return(artifacts)
}

#' @title Run the t-sne algorithm with restarts
#'
#' @description
#' Run t-sne algorithm multiple times, returning the one with the lowest error.
#' Optionally, the perplexity can be input; by defaul, 30 is used.
#'
#' @param Y The matrix on which to run the t-sne algorithm. Columns are
#'   variables and rows are observations
#' @param num_restarts The number of restarts to use
#' @param base_seed The base number seed to use for reproducibility
#' @param perplexity The perplexity to use (default: 30)
#'
#' @return The best t-sne fit
#'
#' @export
tsne_with_restarts <- function(Y, num_restarts, base_seed, perplexity=30) {
  set.seed(base_seed)
  run_seeds <- sample.int(1000000,num_restarts)
  cl <- parallel::makePSOCKcluster(parallel::detectCores()-2)
  doParallel::registerDoParallel(cl)
  tsne_list <- foreach(r = 1:num_restarts) %dopar% {
    set.seed(run_seeds[r])
    Rtsne::Rtsne(Y,
                 dims = 2,
                 perplexity=perplexity,
                 verbose=F,
                 max_iter = 10000,
                 theta=0)
  }

  error_vect <- unlist(lapply(tsne_list,function(tsne){sum(tsne$costs)}))
  ind_best <- which.min(error_vect)
  parallel::stopCluster(cl)
  return(tsne_list[[ind_best]])
}