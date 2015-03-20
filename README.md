Getting and Cleaning Data
=========================

##Overview

This is a repository for project 2 of the Getting and Cleaning Data Coursera course (Johns Hopkins University).


## Setting Up

1. Download the following file and save it to your computer (eg. your Desktop):
  * https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

2. Extract it using a decompression program like 7zip. Remember this directory, you'll need it later. During the extraction, a folder named "./UCI HAR Dataset" will be created containing some data which is for information purposes only along with the following 8 essential files without which the script will fail:

  1. ./test/x_train.txt

  2. ./test/y_train.txt

  3. ./test/subject_train.txt

  4. ./train/x_train.txt

  5. ./train/subject_train.txt

  6. ./train/y_train.txt

  7. ./features.txt

  8. ./activity_labels.txt

3. Download and save run_analysis.R to your computer and source it using the source() command. (type ?source in the RStudio console if you don't know how to do this)


## Running the script

1. In RStudio at the r console, you can do one of the following to run the script:  1. Use the setwd() command to navigate to the "./UCI HAR Dataset" path you created in step 2 of the setting up section. You can then run analyze() to run the script (For help using the setwd() command, type ?setwd in the RStudio at the r console)

  2. Pass the path as a parameter to the analyze() function (eg. analyze("./UCI HAR Dataset"))

2. After successful completion of the script, 2 files will be created:

  1. ./data-cleaned.txt (Contains the merged data from the training and test sets, as well as the corresponding tidy labels.)

  2. ./data-averages.txt (Contains all the averaged data from the cleaned data table created in the other file. It should contain 180 rows and 68 columns as there are 30 subjects and 6 activities (30*6), so for each activity and each subject we calculated means 30 * 6 = 180 rows.)
