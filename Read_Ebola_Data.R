rm(list=ls())
library(XML)
###########################
# West Africa Data
###########################
url = "http://www.cdc.gov/vhf/ebola/outbreaks/2014-west-africa/case-counts.html"
doc = htmlParse(url, isURL = TRUE)
afr.tab = readHTMLTable(doc)

###########################
# Congo Data
###########################
drc_url = "http://www.cdc.gov/vhf/ebola/outbreaks/drc/2014-august.html"
ddoc = htmlParse(drc_url, isURL = TRUE)
dat = xpathSApply(ddoc, "//div[@class='module-typeA']/p", xmlValue)
dat = paste(dat, collapse = " ")
cases = gsub("(.*) (.*) cases(.*)", "\\2", dat)
deaths = gsub("(.*) (.*) deaths(.*)", "\\2", dat)
cases = as.numeric(cases)
deaths = as.numeric(deaths)

cdc_chart = "http://www.cdc.gov/vhf/ebola/outbreaks/history/distribution-map.html"
cdoc = htmlParse(cdc_chart, isURL = TRUE)
cdc.tab = readHTMLTable(cdoc, 
	stringsAsFactors=FALSE)$`distribution-map`
cdc.tab$Cases = as.numeric(gsub("*", "", cdc.tab$Cases, fixed=TRUE))
cdc.tab$Deaths = as.numeric(gsub("*", "", cdc.tab$Deaths, fixed=TRUE))
