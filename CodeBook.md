Getting and cleaning data course project
================
Manoli Heyneke
November 15, 2019

## Import required library

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

## Data reading and extraction

The following code unzips the data,obtains a path for each of the
required files and a list is created of each file name

``` r
# Unzip dataSet to /data directory
unzip(zipfile="C:/Users/hey09895/Desktop/Data Science Specialization/Data Cleaning/getdata_projectfiles_UCI HAR Dataset.zip",
      exdir="C:/Users/hey09895/Desktop/Data Science Specialization/Data Cleaning/New folder")

list.files("C:/Users/hey09895/Desktop/Data Science Specialization/Data Cleaning/New folder")
```

    ## [1] "UCI HAR Dataset"

``` r
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
```

## Data labeling

The following snippet of code adds the features to the train and test
data

``` r
#add features to training data
colnames(x_train)=features[,2]
colnames(y_train)="activity"
colnames(SUB_Train)="subject"

#add features to test data
colnames(x_test)=features[,2]
colnames(y_test)="activity"
colnames(SUB_Test)="subject"

colnames(activity_label)=c('activity','activity_type')
```

## Data joining

``` r
#join train
join_train=cbind(y_train,SUB_Train,x_train)

#join test
join_test=cbind(y_test,SUB_Test,x_test)

#join train & test
DF=rbind(join_test,join_train)
```

## Variable selection based on variable name

The following snippet extracts the variables containing the strings
“activity”, “subject”, “mean” and “std”.

``` r
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
```

## Determining the average of each variable for each activity

The next snippet of code joins the activity label to the dataframe
containing the train and test data. The aggregate function is used to
group by subject and activity and then determine the mean for each of
the groupings. The order function is used to order the data on the basis
of subject and then activity.

``` r
#join dataset with only mean and std with activity label
join_activity_names<-inner_join(DF_Mean_Std,activity_label,by="activity")

#use aggregate to group by subject and mean and determine the mean of
#each subject for a specific activity
tidyDF <- aggregate(. ~subject + activity, join_activity_names, mean)

#order the data on subject and activity
tidyDF <- tidyDF[order(tidyDF$subject, tidyDF$activity),]
```

## Variable name cleaning

The following two functions removes unwanted symbols in the variable
names.

``` r
#Remove unwanted symbols
remove_brack <- function(x) {colnames(x) <- gsub("[()]", "", colnames(x));x}
tidyDF<-remove_brack(tidyDF)

remove_hyph <- function(x) {colnames(x) <- gsub("[-]", "", colnames(x));x}
tidyDF<-remove_hyph(tidyDF)
```

The next snippet of code adds the descriptive name of the activity to
the activity number.

``` r
#assign activity label to activity number
tidyDF<-left_join(tidyDF,activity_label,by="activity")
tidyDF<-tidyDF%>%
  mutate(activity = activity_type.y)%>%
  select(-c(activity_type.x,activity_type.y))
```

## Export data

The dataframe is then saved as a .txt or a .csv file.

``` r
#save dataframe as .txt file
write.table(tidyDF,file = "C:/Users/hey09895/Desktop/Data Science Specialization/Data Cleaning/tidydata.txt",
            row.names = FALSE)
```
