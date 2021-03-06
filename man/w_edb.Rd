% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wind.R
\name{w_edb}
\alias{w_edb}
\title{Revised w.edb for friendly Chinese index names}
\usage{
w_edb(path, sheet = NULL, beginTime = getOption("beginTime",
  "20010101"), endTime = getOption("endTime", Sys.Date()))
}
\arguments{
\item{endTime}{}
}
\description{
Read in an excel file including names and codes, and get relative data from Wind terminal.
The excel spreadsheet should have 2 columns named code & name respectively.
}
