#'Return a catalog of DESC chemistry data
#'
#'The function CHMcatalog can be used to return a catalog of chemistry data in
#'the DESC database. There are only two arguments. One to define the connection
#'handle and the other to limit the size of the catalog by sample count. Many
#'sites within the DESC chemistry database have only 1 or two samples and are
#'excluded by default. This can be changed by changing 'n' which defaults to 10
#'but can be set to any value.
#'
#'@param channel connection handle as returned by odbcConnect
#'@param n minimum sample count
#'
#'@return A data frame
#'
#'@examples
#'# Establish connection with database
#'CHM = odbcConnect("Connection", "User id", "Password")
#'
#'# Grab a catalog of available chemistry data
#'Catalog = CHMcatalog(CHM)
#'
#'# Grab a catalog of all available chemistry data
#'Catalog = CHMcatalog(CHM, n = 0)
#'
#'@import RODBC
#'@export

CHMcatalog = function(channel, n = 10)
{
  RODBC::sqlQuery(channel, {paste(
    "SELECT ALL_SAMPLES.STATION,
    BODY_OF_WATER.LOCATION,
    STATIONS.DESCRIPTION,
    STATIONS.MEDIA,
    ALL_RESULTS.TEST_NAME,
    ALL_RESULTS.NAME,
    ALL_RESULTS.UNITS,
    MIN (ALL_SAMPLES.SDATETIME) AS BEGIN_DATE,
    MAX (ALL_SAMPLES.SDATETIME) AS END_DATE,
    COUNT (ALL_SAMPLES.SDATETIME) AS VALUE_COUNT
    FROM (((CHEMISTRY_MGR.ALL_RESULTS ALL_RESULTS
    INNER JOIN CHEMISTRY_MGR.ALL_SAMPLES ALL_SAMPLES
    ON (ALL_RESULTS.SAMPLE_FKM = ALL_SAMPLES.SAMPLE_PK))
    LEFT JOIN GEOGRAPHIC_MGR.STATIONS STATIONS
    ON (STATIONS.STATION = ALL_SAMPLES.STATION))
    LEFT JOIN GEOGRAPHIC_MGR.BODY_OF_WATER BODY_OF_WATER
    ON (STATIONS.BODY_OF_WATER_FKM = BODY_OF_WATER.BODY_OF_WATER_PK))
    WHERE (ALL_SAMPLES.STATION IS NOT NULL)
    GROUP BY ALL_SAMPLES.STATION,
    ALL_RESULTS.TEST_NAME,
    ALL_RESULTS.NAME,
    STATIONS.DESCRIPTION,
    STATIONS.MEDIA,
    ALL_RESULTS.UNITS,
    BODY_OF_WATER.LOCATION
    HAVING COUNT(ALL_SAMPLES.SDATETIME) > ", paste(n, collapse = ","), "
    ORDER BY 10 DESC, ALL_SAMPLES.STATION ASC")})
  }
