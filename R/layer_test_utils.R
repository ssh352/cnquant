# snippet function
# regular cleaning mission
#' Title
#'
#' @param Stock_Daily_Data
#'
#' @return
#' @export
#'
#' @examples
clean_stock_daily_data <- function(Stock_Daily_Data) {
  Stock_Daily_Data %>%

    # S_DQ_PCTCHANGE
    mutate(S_DQ_PCTCHANGE = S_DQ_PCTCHANGE / 100,
           S_DQ_PCTCHANGE = winsorize(S_DQ_PCTCHANGE, method = c(-0.105, 0.103), fill = "NA")) %>%
    tidyr::replace_na(list(S_DQ_PCTCHANGE = 0)) %>%

    # S_DQ_MV
    mutate(S_DQ_MV = log(S_DQ_MV)) %>%
    rename(LOG_S_DQ_MV = S_DQ_MV) %>%

    # S_VAL_PB_NEW
    mutate(S_VAL_PB_NEW = log(1 / S_VAL_PB_NEW)) %>%
    rename(LOG_B2M = S_VAL_PB_NEW) %>%
    mutate(LOG_B2M = winsorize(LOG_B2M, method = "quantile", side = "left")) %>%

    # TRADABLE
    tidyr::replace_na(list(UP_DOWN_LIMIT_STATUS = 0)) %>%
    mutate(TRADABLE = S_DQ_TRADESTATUS %in% c("交易", "DR", "XD", "XR")
           & UP_DOWN_LIMIT_STATUS == 0
           & !ST) %>%

    return()
}


# snippet function
# spread var along stock code
#' Title
#'
#' @param Test_Data
#' @param var
#' @param fill
#'
#' @return
#' @export
#'
#' @examples
spread_single_var <- function(Test_Data, var, fill = NA) {
  var <- enquo(var)
  Test_Data %>%
    select(S_INFO_WINDCODE, TRADE_DT, !! var) %>%
    tidyr::spread(S_INFO_WINDCODE, !! var, fill = fill) %>%
    {xts::xts(select(., -TRADE_DT), lubridate::ymd(.$TRADE_DT))} %>%
    return()
}


# snippet function
# calculate portfolio return exclude transaction cost
portfolio_return_excost <- function(R, W) {
  # original portfolio return
  Portfolio_Return <- PerformanceAnalytics::Return.portfolio(R, W, verbose = TRUE) %>%
    .[c("returns", "EOP.Weight")]

  # exclude transaction cost
  Portfolio_Return %>%
    .$EOP.Weight %>%
    merge(zoo::index(W), all = FALSE) %>%
    {abs(. - W[-1, ])} %>%
    apply(1, sum) %>%
    # 去掉千分之二的交易成本
    {1 - . * 0.002} %>%
    xts::xts(lubridate::ymd(names(.))) %>%
    `names<-`("transaction.cost.discount") %>%
    merge(Portfolio_Return$returns, .) %>%
    na.fill(1) %>%
    {(1 + .[, "portfolio.returns"]) * .[, "transaction.cost.discount"] - 1} %>%
    return()
}
