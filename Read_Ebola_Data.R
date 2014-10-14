rm(list=ls())
library(XML)
library(stringr)
library(plyr)
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
#### current data
cdat = xpathSApply(ddoc, "//div[@class='module-typeA']/p", xmlValue)
cdat = cdat[!grepl("^For information about(.*) web page[.]$", cdat)]
#### previous data
dat = xpathSApply(ddoc, "//div[@class='rx-row']/p", xmlValue)
ind = grepl("^For information about(.*) web page[.]$", dat)
group = cumsum(ind) + 1
group = group[!grepl("^For information about(.*) web page[.]$", dat)]
dat = dat[!grepl("^For information about(.*) web page[.]$", dat)]

### last 2 are separated
ldat = length(dat)
dat[length(dat)]
dat = c(cdat, dat)
group = c(0, group)

data = data.frame(group=group, dat= dat, stringsAsFactors=FALSE)
dat = daply(data, .(group), function(x){
	paste0(x$dat, collapse = " ")
})
names(dat) = NULL
##############################
# Parse strings of death counts over time
##############################
month.string = paste0('(', paste0(month.name, collapse="|"), ")")
str1 = paste0("((As of|On) ", month.string, " (\\d\\d|\\d), 201\\d), the.*")
dates = gsub(str1, "\\1", dat)
dates = gsub("^(As of|On) ", "", dates)

dat = gsub("suspected cases", "cases", dat)
dat = gsub("total number of cases to (\\d{1,})", "\\1 cases", dat)

cases = sub("(.*) (\\d|\\d\\d) cases(.*)", "\\2", dat)
cases = as.numeric(cases)

dat = gsub("number of deaths reported to (\\d{1,})", 
	"\\1 deaths", dat)

deaths = gsub("(.*) (.*) deaths(.*)", "\\2", dat)
deaths = as.numeric(deaths)
hist.data = data.frame(date=as.Date(dates, format = "%B %d, %Y"), 
	cases = cases,
	deaths = deaths)

###################################
# Extra tab
###################################
cdc_chart = "http://www.cdc.gov/vhf/ebola/outbreaks/history/distribution-map.html"
cdoc = htmlParse(cdc_chart, isURL = TRUE)
cdc.tab = readHTMLTable(cdoc, 
	stringsAsFactors=FALSE)$`distribution-map`
cdc.tab$Cases = as.numeric(gsub("*", "", cdc.tab$Cases, fixed=TRUE))
cdc.tab$Deaths = as.numeric(gsub("*", "", cdc.tab$Deaths, fixed=TRUE))
