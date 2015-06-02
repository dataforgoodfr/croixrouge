rm(list = ls())
source("~/Desktop/croixrouge/R/tools/exp_tools.R")
source("~/Desktop/croixrouge/R/tools/sql_tools.R")
require(data.table)


#get the sql file
print('sql to R:')
aida_agg = sql_to_r(dbname = 'aida_agg', sql_file = '/home/selim/Desktop/tests/2015-04-03-db-aida_pri.sql', 
              user = 'root', password = '1234', host = 'localhost', rdata_path = NULL)


#cleaning script
print('clean the script:')
source('/home/selim/Desktop/croixrouge/R/data_cleaning.R')


#bring back the r data to sql format
print('r to sql:')
r_to_sql(dt_list = aida_agg, dbname = 'aida_agg',
         user = 'root', password = '1234', host = 'localhost', sqlfile_path = '~/Desktop/tests/2015-06-02-db-aida_pri.sql')


#zip the file
system('cd ~/Desktop/tests ; zip --password vincalmeouhumidechien 2015-06-02-db-aida_pri.sql.zip 2015-06-02-db-aida_pri.sql')

#save the new database to R format
save(list = 'aida_agg', file = '/home/selim/Desktop/croixrouge/R/RData/aida_agg.RData')
