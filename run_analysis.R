install.packages("purrr")
install.packages("dplyr")
install.packages('tidyr')
install.packages("stringr")

library(purrr)
library(dplyr)
library(tidyr)
library(stringr)

# Download and unzip the raw data
url="http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,"data.zip","curl")
unzip("data.zip")

# Task 1: Merges the training and the test sets to create one data set.

## read the data in txt and bind these columns together
xtest=read.delim("./UCI HAR Dataset/test/X_test.txt",header=FALSE)
ytest=read.delim("./UCI HAR Dataset/test/Y_test.txt",header=FALSE)
subtest=read.delim("./UCI HAR Dataset/test/subject_test.txt",header=FALSE)
test_or_train=rep_along(ytest,"test")
tbltest=cbind(xtest,ytest,subtest,test_or_train)

xtrain=read.delim("./UCI HAR Dataset/train/X_train.txt",header=FALSE)
ytrain=read.delim("./UCI HAR Dataset/train/Y_train.txt",header=FALSE)
subtrain=read.delim("./UCI HAR Dataset/train/subject_train.txt",header=FALSE)
test_or_train=rep_along(ytrain,"train")
tbltrain=cbind(xtrain,ytrain,subtrain,test_or_train)

## bind the rows within test and train data together
alldata=rbind(tbltrain,tbltest)
names(alldata)=c("collected_data","labels","subjects","train/test")

# Task 2: Extracts only the measurements on the mean and standard deviation for 
# each measurement.

## 2.1. Find out the collection of required features (those measurements on the 
## mean and standard deviation)

## read the features data and make it tidy
fts=read.delim("./UCI HAR Dataset/features.txt",sep=" ",header=FALSE)
## find out the No.s of measurements contains mean() and std(v)
fmean_std=c(grep("mean()",fts$V2,fixed=T),grep("std()",fts$V2,fixed=T))

## 2.2. first we should split the measurement column V1 into 561 measurements and
## allocate them into seperate columns

## There 561 features for each row, however each row of xtest starts with a space,
## so we need extra one column to store the space and drop it latter
cnames=as.character(c(1:562))  
alldata=separate(alldata,collected_data,cnames,sep="\\s+")
alldata=alldata[-1]
names(alldata)=c(as.character(c(1:561)),"labels","subjects","train/test")

## 2.3 Extracts only the targeted measurements, which colnames are concluded in 
## fmean_fstd, and we also keep the columns of "labels", "subjects" and 
## "train/test"
m_std_data=alldata[c(fmean_std,"labels","subjects","train/test")]

# Task 3: Uses descriptive activity names to name the labels in the data set

## 3.1 First we read the activity labels list
als=read.delim("./UCI HAR Dataset/activity_labels.txt",sep=" ",header=FALSE)
names(als)=c("labels","activities")
## 3.2 merge the current data table (m_std_data) with the activitiy labels list(als)
m_std_data=merge(m_std_data,als,by.x="labels",by.y="labels")
m_std_data=m_std_data[-1]

# Task 4: Appropriately labels the data set with descriptive variable names.
# (I apply two method to set the labels: One, I use the original feature names 
# offered by the data supplier, thus the variable names won't be misunderstand 
# by the assignment reviewers who must read the original feature infos; Two, I 
# expand the abbreviation within the original names, such as Accelaration for 
# Acc, total for t,etc.)

## 4.1 create a character contains the original feature names
fnames=as.character(fts$V2[fmean_std])

## 4.2 you could apply the second way to name the variables
##abbr=data.frame(abbr=c("^f","^t","Acc","Gyro","Mag"),
##                full=c("frequency domain signal: ","time domain signal:"," Accelaration "," Gyroscope "," Magnitude"))

##for(i in 1:5){
##       fnames=gsub(abbr$abbr[i],abbr$full[i],fnames)
##}

## 4.3 rename the variables within the data table
names(m_std_data)=c(fnames,"subjects","train/test","activities")

# Task 5: Creates a second, independent tidy data set with the average of each 
# variable for each activity and each subject.

## 5.1 create a independent data table and alter the format of the data for 
## further calculation
tddata=m_std_data
tddata$subjects=as.factor(tddata$subjects)
tddata[fnames]=lapply(tddata[fnames],as.numeric)

## 5.2 apply summarise_all to tddata grouped by "subjects" and "activities"
tddata=tddata%>%group_by(subjects,activities)%>%summarise_all(.funs = c(mean="mean"))
## the train/test column would be all NAs, lets drop it
tddata=tddata%>%select(-`train/test_mean`)

## Since the variables contains 4 parts of information: time/frequency domain 
## signal, specific observation, measurements in mean or std and dimension for 
## some variables, we could store these information into 4 extra columns to make
## the data tidy.

## 5.3 apply gather to store the information contained in variables' names into
## columns
tddata=gather(tddata,name,value,-c("subjects","activities"))
tddata=separate(tddata,name,c("name","dropit"),sep="_")
tddata=separate(tddata,name,c("name","measurement","dimension"),sep="-")
tddata=tddata%>%mutate(domain=substr(name,1,1))
tddata=tddata%>%mutate(observation=str_sub(name,2))

## Drop the column of means and name, since we know that tddata is a table of 
## the means of all measurements and column name has already been separate into 
## two other columns. Arrange the sequence of these columns as well.
tddata=tddata[,c("subjects","activities","observation","domain","measurement",
              "value")]

# Step 6: Store the new data tables and clean the environment
write.table(m_std_data, file="m_std_data.txt",sep="")
write.csv(tddata, file="means of measurements.csv")
rm(list=ls())