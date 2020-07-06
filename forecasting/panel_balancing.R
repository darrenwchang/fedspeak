# balanced panel function
# darren chang

## -- OUTLIER CORRECTION FUNCTION
# outlier correction is from the nowcasting package
# edits: matlab::ones() instead of ones()
outliers_correction <- function(x, k.ma = 3, NA.replace){

    # find missings
    if(NA.replace == T){missing <- is.na(x)}else{missing <- rep(FALSE, length(x))}

    # outlier is an observation greater than 4 times interquartile range
    if(NA.replace == T){
    outlier <- abs(x - median(x, na.rm = T)) > (4 * stats::IQR(x, na.rm = T)) & !missing
    }else{
    outlier <- abs(x - median(x, na.rm = T)) > (4 * stats::IQR(x, na.rm = T)) & !missing
    outlier[is.na(outlier)] = FALSE
    }
    Z <- x

    # replacing outliers and missings by median
    Z[outlier] <- median(x, na.rm = T)
    Z[missing] <- median(x, na.rm = T)

    # centred moving average length k.ma
    xpad <- c(Z[1]*matlab::ones(k.ma,1), Z, Z[length(Z)]*matlab::ones(k.ma,1))
    x_ma <- xpad*NA
    for(j in (k.ma + 1):(length(xpad) - k.ma)){
        x_ma[j - k.ma] <- mean(xpad[(j - k.ma):(j + k.ma)],na.rm=TRUE)
    }
    x_ma <- x_ma[1:length(x)]

    Z[outlier] <- x_ma[outlier]
    Z[missing] <- x_ma[missing]

    # output
    return(Z)
}

## -- BALANCED PANELS FUNCTION
# balance panel function is almost the same as nowcasting::BPanel()
# added base <- ts(base)

balance_panel <- function(base, trans, start, end, frequency, NA.replace = T, aggregate = F, k.ma = 3, na.prop = 1/3, h = 12){

    if(is.null(trans)){
    stop('trans can not to be NULL')
    }

    if(sum(is.na(trans)) != 0){
    stop('trans does not support missings values')
    }

    if(length(trans) != ncol(base)){
    stop('the number of elements in the vector must be equal to the number of columns of base')
    }

    if(sum(!names(table(trans)) %in% c(0:7)) != 0){
    stop('the only available transformations are 0, 1, 2, 3, 4, 5, 6, and 7.')
    }

    if(na.prop < 0 | na.prop > 1){
    stop("na.prop must be between 0 and 1.")
    }

    # data transformation
    base <- ts(base, start, end, frequency)
    base1 <- base
    for(j in 1:ncol(base)){
    base1[,j] <- NA
    if(trans[j] == 1){  # monthly rate of change
        temp <- diff(base[,j]) / stats::lag(base[,j], -1)
        base1[-1,j] <- temp
    }else if(trans[j] == 2){ # monthly difference
        temp <- diff(base[,j])
        base1[-1,j] <- temp
    }else if(trans[j] == 3){ # monthly difference in year-over-year rate of change
        temp <- diff(diff(base[,j], 12) / stats::lag(base[,j], -12))
        base1[-c(1:13),j] <- temp
    }else if(trans[j] == 4){ # monthly difference in year difference
        temp <- diff(diff(base[,j],12))
        base1[-c(1:13),j] <- temp
    }else if(trans[j] == 5){ # yearly difference
        temp <- diff(base[,j],12)
        base1[-c(1:12),j] <- temp  
    }else if(trans[j] == 6){ # yearly rate of change
        temp <- diff(base[,j],12) / stats::lag(base[,j],-12)
        base1[-c(1:12),j] <- temp  
    }else if(trans[j] == 7){ # quarterly rate of change
        temp <- diff(base[,j],3) / stats::lag(base[,j],-3)
        base1[-c(1:3),j] <- temp
    }else if(trans[j] == 0){ # no transformation
        base1[,j] <- base[,j]
    }
    }

    # transformation of monthly series based on Mariano and Murasawa (2003)
    if(aggregate == T){
    for(j in 1:ncol(base)){
        base1[,j] <- stats::filter(base1[,j], c(1,2,3,2,1), sides = 1)
    }
    }
colnames(base1) <- colnames(base)

    # remove series with more than the indicated ratio of missing values (na.prop)
  SerOk <- colSums(is.na(base1)) < (nrow(base1) * na.prop)
    base2 <- base1[, which(SerOk)]

    if(sum(SerOk) == 1){
    stop("the procedure can not be done with only one series available.")
    }

    if(sum(!SerOk) > 0){
    warning(paste(sum(!SerOk),'series ruled out due to lack in observations (more than', round(na.prop*100,2),'% NA).'))
    }

    seriesdeletadas <- colnames(base1[, which(!SerOk)])
    print(seriesdeletadas)


    # replacing both missing values and outliers 
  base3 <- base2 * NA

    for(i in 1:ncol(base2)){
    # ignoring the last missing values
    na <- is.na(base2[,i])
    na2 <- NULL
    for(j in 1:length(na)){
        na2[j] <- ifelse(sum(na[j:length(na)]) == length(j:length(na)), 1, 0)
    }
    suppressWarnings({ na_position <- min(which(na2 == 1)) - 1 })
    if(length(which(na2 == 1)) == 0){ na_position <- nrow(base2)} 
    base3[,i] <- c(outliers_correction(base2[1:na_position,i], k.ma, NA.replace), rep(NA, nrow(base2) - na_position))
    }

    # add h lines to the database
    base4 <- ts(rbind(base3, matrix(NA, nrow = h, ncol = ncol(base3))),
            start = start(base3), frequency = 12)

    # output
    return(base4)
}