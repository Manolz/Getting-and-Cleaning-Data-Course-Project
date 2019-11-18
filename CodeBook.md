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

## Variables

#####Variable Names#####
All variable names (except "Subject" and "Activity") are a combination of:

* The domain (t or f): the t-domain denotes measurements made over time, while f-domain represents Fast Fourier Transformed    variables derived from the t-domain variables. 
* "Body" or "Gravity": some of the acceleration signals do not actually measure body-acceleration but gravity-acceleration. 
* The axis of the measurement (X, Y or Z)
* The function: mean (Mean) or standard deviation (StdDev)
* A combination of "Acc" (for acceleration), "Gyro" (for angular velocity), "Jerk" (for jerk signals) and "Mag" (for magnitude).

"t.Body.Acc.Jerk.X.Mean" will therefore denote a measurement in the t-domain, showing body-acceleration jerk magnitude in the X-plane.
 
The calculated variables (all except "Subject" and "Activity") all represent the **average** of the measurement that they are denoting.

There are 68 variables in the dataset:

**1. Subject.** Integer. Denotes the person (subject) that performed the activities.

**2. Activity.** String. Describes the activity performed.

**3. t.Body.Acc.X.Mean** The average of the means of body-acceleration in the X-plane.

**4. t.Body.Acc.Y.Mean** The average of the means of body-acceleration in the Y-plane.

**5. t.Body.Acc.Z.Mean** The average of the means of body-acceleration in the Z-plane.

**6. t.Body.Acc.X.StdDev** The average of the standard deviations of body-acceleration in the X-plane.

**7. t.Body.Acc.Y.StdDev** The average of the standard deviations of body-acceleration in the Y-plane.

**8. t.Body.Acc.Z.StdDev** The average of the standard deviations of body-acceleration in the Z-plane.

**9. t.Gravity.Acc.X.Mean** The average of the means of gravity-acceleration in the X-plane.

**10. t.Gravity.Acc.Y.Mean** The average of the means of gravity-acceleration in the Y-plane.

**11. t.Gravity.Acc.Z.Mean** The average of the means of gravity-acceleration in the Z-plane.

**12. t.Gravity.Acc.X.StdDev** The average of the standard deviations of gravity-acceleration in the X-plane.

**13. t.Gravity.Acc.Y.StdDev** The average of the standard deviations of gravity-acceleration in the Y-plane.

**14. t.Gravity.Acc.Z.StdDev** The average of the standard deviations of gravity-acceleration in the Z-plane.

**15. t.Body.Acc.Jerk.X.Mean** The average of the means of body-acceleration jerk in the X-plane.

**16. t.Body.Acc.Jerk.Y.Mean** The average of the means of body-acceleration jerk in the Y-plane.

**17. t.Body.Acc.Jerk.Z.Mean** The average of the means of body-acceleration jerk in the Z-plane.

**18. t.Body.Acc.Jerk.X.StdDev** The average of the standard deviations of body-acceleration jerk in the X-plane.

**19. t.Body.Acc.Jerk.Y.StdDev** The average of the standard deviations of body-acceleration jerk in the Y-plane.

**20. t.Body.Acc.Jerk.Z.StdDev** The average of the standard deviations of body-acceleration jerk in the Z-plane.

**21. t.Body.Gyro.X.Mean** The average of the means of angular velocity in the X-plane.

**22. t.Body.Gyro.Y.Mean** The average of the means of angular velocity in the Y-plane.

**23. t.Body.Gyro.Z.Mean** The average of the means of angular velocity in the Z-plane.

**24. t.Body.Gyro.X.StdDev** The average of the standard deviations of angular velocity in the X-plane.

**25. t.Body.Gyro.Y.StdDev** The average of the standard deviations of angular velocity in the Y-plane.

**26. t.Body.Gyro.Z.StdDev** The average of the standard deviations of angular velocity in the Z-plane.

**27. t.Body.Gyro.Jerk.X.Mean** The average of the means of angular velocity jerk in the X-plane.

**28. t.Body.Gyro.Jerk.Y.Mean** The average of the means of angular velocity jerk in the Y-plane.

**29. t.Body.Gyro.Jerk.Z.Mean** The average of the means of angular velocity jerk in the Z-plane.

**30. t.Body.Gyro.Jerk.X.StdDev** The average of the standard deviations of angular velocity jerk in the X-plane.

**31. t.Body.Gyro.Jerk.Y.StdDev** The average of the standard deviations of angular velocity jerk in the Y-plane.

**32. t.Body.Gyro.Jerk.Z.StdDev** The average of the standard deviations of angular velocity jerk in the Z-plane.

**33. t.Body.Acc.Mag.Mean** The average of the means of body-acceleration magnitude.

**34. t.Body.Acc.Mag.StdDev** The average of the standard deviations of body-acceleration magnitude.

**35. t.Gravity.Acc.Mag.Mean** The average of the means of gravity-acceleration magnitude.

**36. t.Gravity.Acc.Mag.StdDev** The average of the standard deviations of gravity-acceleration magnitude.

**37. t.Body.Acc.Jerk.Mag.Mean** The average of the means of body-acceleration jerk magnitude.

**38. t.Body.Acc.Jerk.Mag.StdDev** The average of the standard deviations of body-acceleration jerk magnitude.

**39. t.Body.Gyro.Mag.Mean** The average of the means of angular velocity magnitude.

**40. t.Body.Gyro.Mag.StdDev** The average of the standard deviations of angular velocity magnitude.

**41. t.Body.Gyro.Jerk.Mag.Mean** The average of the means of angular velocity jerk magnitude.

**42. t.Body.Gyro.Jerk.Mag.StdDev** The average of the standard deviations of angular velocity jerk magnitude.

**43. f.Body.Acc.X.Mean** The average of the means of the Fast Fourier Transformation of body-acceleration in the X-plane.

**44. f.Body.Acc.Y.Mean** The average of the means of the Fast Fourier Transformation of body-acceleration in the Y-plane.

**45. f.Body.Acc.Z.Mean** The average of the means of the Fast Fourier Transformation of body-acceleration in the Z-plane.

**46. f.Body.Acc.X.StdDev** The average of the standard deviations of the Fast Fourier Transformation of body-acceleration in the X-plane.

**47. f.Body.Acc.Y.StdDev** The average of the standard deviations of the Fast Fourier Transformation of body-acceleration in the Y-plane.

**48. f.Body.Acc.Z.StdDev** The average of the standard deviations of the Fast Fourier Transformation of body-acceleration in the Z-plane.

**49. f.Body.Acc.Jerk.X.Mean** The average of the means of the Fast Fourier Transformation of body-acceleration jerk in the X-plane.

**50. f.Body.Acc.Jerk.Y.Mean** The average of the means of the Fast Fourier Transformation of body-acceleration jerk in the Y-plane.

**51. f.Body.Acc.Jerk.Z.Mean** The average of the means of the Fast Fourier Transformation of body-acceleration jerk in the Z-plane.

**52. f.Body.Acc.Jerk.X.StdDev** The average of the standard deviations of the Fast Fourier Transformation of body-acceleration jerk in the X-plane.

**53. f.Body.Acc.Jerk.Y.StdDev** The average of the standard deviations of the Fast Fourier Transformation of body-acceleration jerk in the Y-plane.

**54. f.Body.Acc.Jerk.Z.StdDev** The average of the standard deviations of the Fast Fourier Transformation of body-acceleration jerk in the Z-plane.

**55. f.Body.Gyro.X.Mean** The average of the means of the Fast Fourier Transformation of angular velocity in the X-plane.

**56. f.Body.Gyro.Y.Mean** The average of the means of the Fast Fourier Transformation of angular velocity in the Y-plane.

**57. f.Body.Gyro.Z.Mean** The average of the means of the Fast Fourier Transformation of angular velocity in the Z-plane.

**58. f.Body.Gyro.X.StdDev** The average of the standard deviations of the Fast Fourier Transformation of angular velocity in the X-plane.

**59. f.Body.Gyro.Y.StdDev** The average of the standard deviations of the Fast Fourier Transformation of angular velocity in the Y-plane.

**60. f.Body.Gyro.Z.StdDev** The average of the standard deviations of the Fast Fourier Transformation of angular velocity in the Z-plane.

**61. f.Body.Acc.Mag.Mean** The average of the means of the Fast Fourier Transformation of body-acceleration magnitude.

**62. f.Body.Acc.Mag.StdDev** The average of the standard deviations of the Fast Fourier Transformation of body-acceleration magnitude.

**63. f.Body.Acc.Jerk.Mag.Mean** The average of the means of the Fast Fourier Transformation of body-acceleration jerk magnitude.

**64. f.Body.Acc.Jerk.Mag.StdDev** The average of the standard deviations of the Fast Fourier Transformation of body-acceleration jerk magnitude.

**65. f.Body.Gyro.Mag.Mean** The average of the means of the Fast Fourier Transformation of angular velocity magnitude.

**66. f.Body.Gyro.Mag.StdDev** The average of the standard deviations of the Fast Fourier Transformation of angular velocity magnitude.

**67. f.Body.Gyro.Jerk.Mag.Mean** The average of the means of the Fast Fourier Transformation of angular velocity jerk magnitude.

**68. f.Body.Gyro.Jerk.Mag.StdDev** The average of the standard deviations of the Fast Fourier Transformation of angular velocity jerk magnitude.

















