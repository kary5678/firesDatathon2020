library(RSQLite)
database <- dbConnect(SQLite(), dbname = "firedata.sqlite")
fire_data <- dbReadTable(database, "Fires")

#Looking at what may cause more fires
query <- paste0("
SELECT STAT_CAUSE_DESCR as `Cause of Fire`, count(*) as `Number of Fires`
FROM Fires
GROUP BY `Cause of Fire`
ORDER BY `Number of Fires`;")
res <- dbSendQuery(database, query)
dbFetch(res, -1)
#dbFetch(res, -1) %>% knitr::kable()
dbClearResult(res) 
#Surprising result... Arson?!

#What causes the most amount of acreage burned?
query <- paste0("
SELECT STAT_CAUSE_DESCR as `Cause of Fire`, SUM(FIRE_SIZE) as `Total Acreage Burned`
FROM Fires
GROUP BY `Cause of Fire`
ORDER BY `Total Acreage Burned`;")
res <- dbSendQuery(database, query)
dbFetch(res, -1)
dbClearResult(res) 

query <- paste0("
SELECT STAT_CAUSE_DESCR as `Cause of Fire`,  
  count(*) as `Number of Fires`, 
  SUM(FIRE_SIZE) as `Total Acreage Burned`
FROM Fires
GROUP BY `Cause of Fire`
ORDER BY `Cause of Fire`;")
res <- dbSendQuery(database, query)
dbFetch(res, -1)
dbClearResult(res) 

#Do some locations have more fires than others?
query <- paste0("
SELECT SOURCE_REPORTING_UNIT_NAME as Location, count(*) as `Number of Fires`
FROM Fires
GROUP BY `Location`
ORDER BY `Number of Fires`;")
res <- dbSendQuery(database, query)
tail(dbFetch(res, -1), n=20)
dbClearResult(res) 

query <- paste0("
SELECT NWCG_REPORTING_UNIT_NAME as Location, count(*) as `Number of Fires`
FROM Fires
GROUP BY `Location`
ORDER BY `Number of Fires`;")
res <- dbSendQuery(database, query)
tail(dbFetch(res, -1), n=20)
dbClearResult(res) 

#Looking at fire occurrence by state
query <- paste0("
SELECT STATE as Location, count(*) as `Number of Fires`
FROM Fires
GROUP BY `State`
ORDER BY `Number of Fires`;")
res <- dbSendQuery(database, query)
dbFetch(res, -1)
dbClearResult(res) 

##Georgia has a lot of fires
#California has the most amount of fires when you look at the data by state


#Looking at size of fires versus causes
library(ggplot2)
causes_subset <- subset(fire_data,STAT_CAUSE_DESCR!="Missing/Undefined" & 
                                  STAT_CAUSE_DESCR!="Miscellaneous")
ggplot(causes_subset)+geom_bar(aes(x=FIRE_SIZE_CLASS,fill=FIRE_SIZE_CLASS))+
  facet_wrap(~STAT_CAUSE_DESCR,scales="free_y",ncol=4)+theme(legend.position = "none")+
  labs(x="Severity of Fire Size",y="Number of Fires",
       title="Causes of Fires and their Resulting Severity and Occurrence")

#Similar to the above plot, but focusing on severity classes D-G
#It was hard to see the differences with so many cases of A-C
severe_subset <- subset(causes_subset,FIRE_SIZE_CLASS!="A" &
                                      FIRE_SIZE_CLASS!="B" &
                                      FIRE_SIZE_CLASS!="C" )
ggplot(severe_subset)+geom_bar(aes(x=FIRE_SIZE_CLASS,fill=FIRE_SIZE_CLASS))+
  facet_wrap(~STAT_CAUSE_DESCR,scales="free_y",ncol=4)+theme(legend.position = "none")+
  labs(x="Severity of Fire Size",y="Number of Fires",
       title="A Closer Look at Severe Fires and their Causes")

#Looking at Severe Fires by State
ggplot(severe_subset)+geom_bar(aes(x=FIRE_SIZE_CLASS,fill=FIRE_SIZE_CLASS))+
  facet_wrap(~STATE,scales="free_y",ncol=9)+theme(legend.position = "none")+
  labs(x="Severity of Fire Size",y="Number of Fires",
       title="A Closer Look at Severe Fires and their Location")

ggplot(fire_data)+geom_point(aes(x=FIRE_SIZE,y=CONT_TIME))

ggplot(fire_data)+geom_point(aes(x=DISCOVERY_TIME,y=FIRE_SIZE))

ggplot(fire_data)+geom_point(aes(x=DISCOVERY_TIME,y=CONT_TIME))