library(tidyverse)
library(dplyr)

# Unzip dataSet to /data directory
unzip(zipfile="C:/Users/hey09895/Desktop/Data Science Specialization/Data Cleaning/getdata_projectfiles_UCI HAR Dataset.zip",
      exdir="C:/Users/hey09895/Desktop/Data Science Specialization/Data Cleaning/New folder")

list.files("C:/Users/hey09895/Desktop/Data Science Specialization/Data Cleaning/New folder")

pathdata<-file.path("C:/Users/hey09895/Desktop/Data Science Specialization/Data Cleaning/New folder/UCI HAR Dataset")

#list of unzipped files
sep_files<-list.files(pathdata,recursive = TRUE)

#4 Categories
##training
##test
##features
##activity labels

#read train for x & y & sub
x_train<-read.table(file.path(pathdata,"train","X_train.txt"),header = FALSE)
y_train<-read.table(file.path(pathdata,"train","y_train.txt"),header = FALSE)
SUB_Train<-read.table(file.path(pathdata,"train","subject_train.txt"),header = FALSE)

#read test for x & y & sub
x_test<-read.table(file.path(pathdata,"test","X_test.txt"),header = FALSE)
y_test<-read.table(file.path(pathdata,"test","y_test.txt"),header = FALSE)
SUB_Test<-read.table(file.path(pathdata,"test","subject_test.txt"),header = FALSE)

#read feature data
features<-read.table(file.path(pathdata,"features.txt"),header = FALSE)

#read activity label
activity_label<-read.table(file.path(pathdata,"activity_labels.txt"),header = FALSE)

#add features to training data
colnames(x_train)=features[,2]
colnames(y_train)="activity"
colnames(SUB_Train)="subject"

#add features to test data
colnames(x_test)=features[,2]
colnames(y_test)="activity"
colnames(SUB_Test)="subject"

colnames(activity_label)=c('activity','activity_type')

#join train
join_train=cbind(y_train,SUB_Train,x_train)

#join test
join_test=cbind(y_test,SUB_Test,x_test)

#join train & test
DF=rbind(join_test,join_train)


#get variable names in joined dataset
col_names_DF<-colnames(DF)


#get mean and std and the matching activity and subject
std_mean<-(grepl("activity",col_names_DF)|
                   grepl("subject",col_names_DF)|
                   grepl("mean..",col_names_DF)|
                   grepl("std..",col_names_DF)
                   )
#Dataset with only mean and std
DF_Mean_Std<-DF[,std_mean==TRUE]


#join dataset with only mean and std with activity label
join_activity_names<-inner_join(DF_Mean_Std,activity_label,by="activity")

#use aggregate to group by subject and mean and determine the mean of
#each subject for a specific activity
tidyDF <- aggregate(. ~subject + activity, join_activity_names, mean)

#order the data on subject and activity
tidyDF <- tidyDF[order(tidyDF$subject, tidyDF$activity),]

#Remove unwanted symbols
remove_brack <- function(x) {colnames(x) <- gsub("[()]", "", colnames(x));x}
tidyDF<-remove_brack(tidyDF)

remove_hyph <- function(x) {colnames(x) <- gsub("[-]", "", colnames(x));x}
tidyDF<-remove_hyph(tidyDF)

#assign activity label to activity number
tidyDF<-left_join(tidyDF,activity_label,by="activity")
tidyDF<-tidyDF%>%
  mutate(activity = activity_type.y)%>%
  select(-c(activity_type.x,activity_type.y))

tidyDF

#save dataframe as .txt and .csv files
write.table(tidyDF,file = "C:/Users/hey09895/Desktop/Data Science Specialization/Data Cleaning/tidydata.txt",
            row.names = FALSE)











