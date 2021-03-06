# analyze survey data for free (http://asdfree.com) with the r language
# medical expenditure panel survey
# 2010 consolidated

# # # # # # # # # # # # # # # # #
# # block of code to run this # #
# # # # # # # # # # # # # # # # #
# library(downloader)
# setwd( "C:/My Directory/MEPS/" )
# source_url( "https://raw.github.com/ajdamico/usgsd/master/Medical%20Expenditure%20Panel%20Survey/2010%20consolidated%20-%20analyze%20with%20brr.R" , prompt = FALSE , echo = TRUE )
# # # # # # # # # # # # # # #
# # end of auto-run block # #
# # # # # # # # # # # # # # #

# if you have never used the r language before,
# watch this two minute video i made outlining
# how to run this script from start to finish
# http://www.screenr.com/Zpd8

# anthony joseph damico
# ajdamico@gmail.com

# if you use this script for a project, please send me a note
# it's always nice to hear about how people are using this stuff

# for further reading on cross-package comparisons, see:
# http://journal.r-project.org/archive/2009-2/RJournal_2009-2_Damico.pdf



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#############################################################################################################################################################
# prior to running this analysis script, the linkage brr file and 2010 consolidated file must be loaded as an r data file (.rda) file on the local machine. #
# running the 1996-2010 household component - download all microdata.R script will create an R data file (.rda)                                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# https://raw.github.com/ajdamico/usgsd/master/Medical%20Expenditure%20Panel%20Survey/1996-2010%20household%20component%20-%20download%20all%20microdata.R  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# that script will create files "linkage - brr.rda" and "2010 - consolidated.rda" in C:/My Directory/MEPS (or wherever the working directory was chosen)    #
#############################################################################################################################################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #



###############################################
# balanced repeated replication (brr) version #

# this script uses the brr method to calculate standard errors
# brr has the disadvantage of being computationally more difficult
# and the advantage of producing standard errors or confidence intervals
# on percentile statistics
# (for example, tsl cannot compute the confidence interval around a median)

# if you are not sure which method to use, use this brr script instead of tsl
# available in the same folder


# the statistics (means, medians, percents, and counts) from brr and tsl designs
# will match exactly.  the standard errors and confidence intervals
# will be slightly different. both methods are considered valid.


##############################################################################
# Analyze the 2010 Medical Expenditure Panel Survey consolidated file with R #
##############################################################################


# set your working directory.
# the MEPS 2010 data file will be stored here
# after downloading and importing it.
# use forward slashes instead of back slashes


# set your working directory.
# this directory must contain the MEPS 2010 consolidated (.rda) file 
# as well as the MEPS linkage - brr (.rda) file
# created by the R program specified above
# use forward slashes instead of back slashes

# uncomment this line by removing the `#` at the front..
# setwd( "C:/My Directory/MEPS/" )
# ..in order to set your current working directory



# remove the # in order to run this install.packages line only once
# install.packages( "survey" )


library(survey)  # load survey package (analyzes complex design surveys)


# set R to produce conservative standard errors instead of crashing
# http://r-survey.r-forge.r-project.org/survey/exmample-lonely.html
options( survey.lonely.psu = "adjust" )
# this setting matches the MISSUNIT option in SUDAAN


# if this option is set to TRUE
# R will exactly match SUDAAN results and Stata with the MSE option results
options( survey.replicates.mse = TRUE )
# otherwise if it is commented out or set to FALSE
# R will exactly match Stata without the MSE option results

# Stata svyset command notes can be found here: http://www.stata.com/help.cgi?svyset


# load the consolidated.2010 data frame into an R data frame
load( "2010 - consolidated.rda" )
	

# load the linkage - brr.rda file into an R data frame
load( "linkage - brr.rda" )


####################################
# if your computer runs out of RAM #
# if you get a memory error        #
####################################

# comment out these lines if you'd rather not restrict the MEPS 10 file
# to only the columns you expect to use in the analysis

# the MEPS 2010 consolidated file has almost 2,000 different columns
# most analyses only use a small fraction of those
# by removing the columns not necessary for the analysis,
# lots of RAM gets freed up

# create a character vector containing 
# the variables you need for the analysis

KeepVars <-
	c( 
		# unique identifiers
		"DUPERSID" , "PANEL" ,
		# cluster and strata variables used for complex survey design
		"VARPSU" , "VARSTR" , 
		# 2010 weight
		"PERWT10F" , 
		# annualized insurance coverage variable
		"INS10X" , 
		# total annual medical expenditure variable
		"TOTEXP10" , 
		# region of the country variable
		"REGION10" , 
		# gender variable
		"SEX"
	)

# restrict the consolidated data table to
# only the columns specified above

consolidated.2010 <-
	consolidated.2010[ , KeepVars ]

# clear up RAM - garbage collection function

gc()

############################
# end of RAM-clearing code #
############################
	

#################################################
# merge consolidated file with brr weights file #
#################################################

# remove columns DUID and PID from the brr file
# or they will create duplicate column names in the merged data frame
brr <- 
	brr[ , !( names( brr ) %in% c( "DUID" , "PID" ) ) ]

	
# merge the consolidated file 
# with the brr file
MEPS.10.consolidated.with.brr.df <-
	merge( 
		consolidated.2010 ,
		brr ,
		by = c( "DUPERSID" , "PANEL" ) 
	)

	
# confirm that the number of records in the 2010 consolidated file
# matches the number of records in the merged file

if ( nrow( MEPS.10.consolidated.with.brr.df ) != nrow( consolidated.2010 ) ) 
	stop( "problem with merge - merged file should have the same number of records as the original consolidated file" )
	
	

	
###################################################
# survey design for balanced repeated replication #
###################################################

# create survey design object with MEPS design information
# using existing data frame of MEPS data
meps.brr.design <- 
	svrepdesign(
		data = MEPS.10.consolidated.with.brr.df ,
		weights = ~PERWT10F ,
		type = "BRR" , 
		combined.weights = F ,
		repweights = "BRR[1-9]+"
	)

# notice the 'meps.brr.design' object used in all subsequent analysis commands


# remove two of the original data frames from RAM
# since they're no longer of value
rm( MEPS.10.consolidated.with.brr.df )
rm( brr )

# clear up RAM
gc()


#####################
# analysis examples #
#####################

# count the total (unweighted) number of records in meps #

# simply use the nrow function
nrow( meps.brr.design )

# the nrow function which works on both data frame objects..
class( consolidated.2010 )
# ..and survey design objects
class( meps.brr.design )

# count the total (unweighted) number of records in meps #
# broken out by region of the country #

svyby(
	~TOTEXP10 ,
	~REGION10 ,
	meps.brr.design ,
	unwtd.count
)



# count the weighted number of individuals in meps #

# add a new variable 'one' that simply has the number 1 for each record #

meps.brr.design <-
	update( 
		one = 1 ,
		meps.brr.design
	)

# the civilian, non-institutionalized population of the united states #
svytotal( 
	~one , 
	meps.brr.design 
)


# note that this is exactly equivalent to summing up the weight variable
# from the original MEPS data frame
# (assuming this data frame was not cleared out of RAM above)

sum( consolidated.2010$PERWT10F )

# the civilian, non-institutionalized population of the united states #
# by region of the country
svyby(
	~one ,
	~REGION10 ,
	meps.brr.design ,
	svytotal
)


# calculate the mean of a linear variable #

# average medical expenditure - nationwide
svymean( 
	~TOTEXP10 , 
	design = meps.brr.design
)

# by region of the country
svyby( 
	~TOTEXP10 , 
	~REGION10 ,
	design = meps.brr.design ,
	svymean
)


# calculate the distribution of a categorical variable #

# INS10X should be treated as a factor (categorical) variable
# instead of a numeric (linear) variable
# this update statement converts it.
# the svyby command below will not run without this
meps.brr.design <-
	update( 
		INS10X = factor( INS10X ) ,
		meps.brr.design
	)


# percent uninsured - nationwide
svymean( 
	~INS10X , 
	design = meps.brr.design
)

# by region of the country
svyby( 
	~INS10X , 
	~REGION10 ,
	design = meps.brr.design ,
	svymean
)

# calculate the median and other percentiles #

# note that unlike a taylor-series survey design
# the brr design does allow for
# calculation of standard errors

# minimum, 25th, 50th, 75th, maximum 
# medical expenditure in the united states
svyquantile( 
	~TOTEXP10 , 
	design = meps.brr.design ,
	c( 0 , .25 , .5 , .75 , 1 )
)

# by region of the country
svyby( 
	~TOTEXP10 , 
	~REGION10 ,
	design = meps.brr.design ,
	svyquantile ,
	c( 0 , .25 , .5 , .75 , 1 ) , 
	ci = T
)

######################
# subsetting example #
######################

# restrict the meps.brr.design object to
# females only
meps.brr.design.female <-
	subset(
		meps.brr.design ,
		SEX %in% 2
	)
# now any of the above commands can be re-run
# using the meps.brr.design.female object
# instead of the meps.brr.design object
# in order to analyze females only
	
# calculate the mean of a linear variable #

# average medical expenditure - nationwide, restricted to females
svymean( 
	~TOTEXP10 , 
	design = meps.brr.design.female
)



###################
# export examples #
###################

# calculate the distribution of a categorical variable #
# by region of the country

# store the results into a new object

coverage.by.region <-
	svyby( 
		~INS10X , 
		~REGION10 ,
		design = meps.brr.design ,
		svymean
	)

# print the results to the screen 
coverage.by.region

# now you have the results saved into a new object of type "svyby"
class( coverage.by.region )

# print only the statistics (coefficients) to the screen 
coef( coverage.by.region )

# print only the standard errors to the screen 
SE( coverage.by.region )

# this object can be coerced (converted) to a data frame.. 
coverage.by.region <- data.frame( coverage.by.region )

# ..and then immediately exported as a comma-separated value file 
# into your current working directory 
write.csv( coverage.by.region , "coverage by region.csv" )

# ..or trimmed to only contain the values you need.
# here's the uninsured percentage by region, 
# with accompanying standard errors
uninsured.rate.by.region <-
	coverage.by.region[ 2:5 , c( "REGION10" , "INS10X2" , "se3" ) ]

# that's rows 2 through 5, and the three specified columns


# print the new results to the screen
uninsured.rate.by.region

# this can also be exported as a comma-separated value file 
# into your current working directory 
write.csv( uninsured.rate.by.region , "uninsured rate by region.csv" )

# ..or directly made into a bar plot
barplot(
	uninsured.rate.by.region[ , 2 ] ,
	main = "Uninsured Rate by Region of the Country" ,
	names.arg = c( "Northeast" , "Midwest" , "South" , "West" ) ,
	ylim = c( 0 , .25 )
)

# for more details on how to work with data in r
# check out my two minute tutorial video site
# http://www.twotorials.com/

# dear everyone: please contribute your script.
# have you written syntax that precisely matches an official publication?
message( "if others might benefit, send your code to ajdamico@gmail.com" )
# http://asdfree.com needs more user contributions

# let's play the which one of these things doesn't belong game:
# "only you can prevent forest fires" -smokey bear
# "take a bite out of crime" -mcgruff the crime pooch
# "plz gimme your statistical programming" -anthony damico
