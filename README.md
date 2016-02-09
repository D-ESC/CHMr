# CHMr
A R package for working with the DESC chemistry database. For use in our office, may or may not be useful to others outside our work-site. The development version can be installed using:

```R
# install.packages("devtools")
devtools::install_github("D-ESC/CHMr")
```
### ODBC
In order to talk to the database, you'll need to establish an ODBC connection to the ODM database on the machine that you're working on. To do this in Win7, go to Control Panel -> Administrative Tools, then choose "Data Sources (ODBC)". You'll want to add a "User DSN".

### The Basics
Here is a quick example. You'll need the package RODBC in order to establish a connection using an ODBC connection. `odbcConnect` establishes a connection to the specified DSN. `CHMcatalog` is used to create a catalog of the datavalues available.

```R
require(CHMr)
ODM <- odbcConnect("Connection", "User id", "Password")
Catalog = CHMcatalog(CHM)
```

Multiple data series can be queried at once. The function makes use of the IN
operator in the underlying SQL statement to specify multiple values. 

```R
tmp = CHMselect(CHM, STATION = '03008557402', TEST_NAME = c('PPUT1','PPUT2'))
```

Start and end dates can be specified, LDESC and sample numbers can all be used
to extract data.

```R
tmp = CHMselect(CHM, STATION = '03008557402', TEST_NAME = 'PPUT1',
  startDate = "2015-09-01", endDate = "2015-11-01")
```