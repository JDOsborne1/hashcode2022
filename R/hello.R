

#' Returns the dataset of a given set and variant
#'
#' @param .set
#' @param .variant
#'
#' @return
#' @export
#'
#' @examples
giff_data <- function(.set, .variant = NULL) {
        if (.set == "a" & is.null(.variant)) {
                return(hashcode2022::part_a)
        }
}
