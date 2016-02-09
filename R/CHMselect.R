#'Query DESC chemistry database
#'
#'The function CHMselect can be used to get data from the DESC chemistry database.
#'A standard SQL query is issued to the database and the values are
#'returned in dataframe. The data returned can be limited by a start
#'and/or end date defined by the user.
#'
#'@param channel connection handle as returned by odbcConnect
#'@param STATION station number
#'@param LDESC location description given during sample submissions
#'@param TEST_NAME the test name short form found in the lab submission manual
#'@param SUBNUM submission number
#'@param startDate access data from this date forward
#'@param endDate access data up to this date
#'
#'@return A data frame
#'
#'@examples
#'# Establish connection with database
#'CHM = odbcConnect("Connection", "User id", "Password")
#'
#'# Extract all data by STATION
#'tmp <- CHMselect(CHM, STATION = '03008557402')
#'
#'# Extract data by STATION and multiple TEST_NAME.
#'tmp = CHMselect(CHM, STATION = '03008557402', TEST_NAME = c('PPUT1','PPUT2'))
#'
#'# Limit extraction by date.
#'tmp = CHMselect(CHM, STATION = '03008557402', TEST_NAME = 'PPUT1',
#'  startDate = "2015-09-01", endDate = "2015-11-01")
#'
#'@import RODBC
#'@export

CHMselect <- function(channel, STATION = NULL,
  LDESC = NULL, TEST_NAME = NULL, SUBNUM = NULL,
  startDate = "1970-01-1 00:00:00", endDate = Sys.Date())
{
  Old.TZ <- Sys.getenv("TZ")
  Sys.setenv(TZ = "Etc/GMT")
  Data <- RODBC::sqlQuery(channel, {
    paste ("SELECT ALL_SAMPLES.SUBNUM,
       ALL_SAMPLES.SDATETIME,
      ALL_SAMPLES.STATION,
      ALL_SAMPLES.LDESC,
      ALL_RESULTS.TEST_NAME,
      ALL_RESULTS.VALUE,
      ALL_RESULTS.UNITS,
      ALL_RESULTS.REMARK,
      ALL_RESULTS.ANALYTIC_METHOD
      FROM CHEMISTRY_MGR.ALL_RESULTS ALL_RESULTS
       INNER JOIN CHEMISTRY_MGR.ALL_SAMPLES ALL_SAMPLES
          ON (ALL_RESULTS.SAMPLE_FKM = ALL_SAMPLES.SAMPLE_PK)
       WHERE     (ALL_SAMPLES.SUBNUM IN (",
      if (is.null(SUBNUM))
        paste("SUBNUM", collapse = ",") else
          paste("'",SUBNUM,"'", collapse = ",", sep=""),"))
      AND (ALL_SAMPLES.STATION IN (",
      if (is.null(STATION))
        paste("STATION", collapse = ",") else
          paste("'",STATION,"'", collapse = ",", sep=""),"))
      ",
      if (is.null(LDESC))
        paste("", collapse = ",") else
          paste("AND (ALL_SAMPLES.LDESC IN ('",LDESC,"'))", collapse = ",", sep=""),"
      AND (ALL_RESULTS.TEST_NAME IN (",
      if (is.null(TEST_NAME))
        paste("TEST_NAME", collapse = ",") else
          paste("'",TEST_NAME,"'", collapse = ",", sep=""),"))
      AND ((ALL_SAMPLES.SDATETIME >
          TO_DATE ('", startDate,"', 'yyyy/mm/dd hh24:mi:ss'))
      AND (ALL_SAMPLES.SDATETIME <
          TO_DATE ('", endDate,"', 'yyyy/mm/dd hh24:mi:ss')))
      ORDER BY ALL_SAMPLES.STATION ASC, ALL_RESULTS.TEST_NAME ASC,
      ALL_SAMPLES.SDATETIME ASC", sep = "")
  })
  Sys.setenv(TZ=Old.TZ)
  return(Data)
}

