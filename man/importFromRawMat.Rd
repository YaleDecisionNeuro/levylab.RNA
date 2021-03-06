% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/importFromRawMat.R
\name{importFromRawMat}
\alias{importFromRawMat}
\title{Import a single subject's R&A choice data from a raw .mat file.}
\usage{
importFromRawMat(filename, substituteColor = FALSE)
}
\arguments{
\item{filename}{A full file path to a .mat file}

\item{substituteColor}{Replace the numeric reference to the
color of the winning probability with information about the actual color?}
}
\value{
A clean R&A data frame
}
\description{
Take the location of any Matlab file with information that
was saved by PTB-based R&A tasks prior to PsychTaskFramework
and returns a clean output that can be analyzed.
}
