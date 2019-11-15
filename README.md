# Getting-and-Cleaning-Data-Course-Project
##Manoli Heyneke
##November 15, 2019

This repository contains work done as part of an course project required for the Getting and cleaning data course which is part of the Coursera Data Science specialization.

The goal of the project is to take a number of text files that each contain different elements of a study measuring accelerometer and gyroscope data obtained from smartphones and then to combine these text files into a single, tidy dataset, which is then saved as a text and comma seperated file.

This repo contains, in addition to the README, a Codebook for the generated tidy dataset as well as the R script that can be used to reproduce the tidy data, given the raw data text files.

The run_analysis.R script is structured as follows:

Import required library
Extract and read data
Label data
Join train and test data
Variable extraction based on variable name
Determine average of each variable for each subject and activity
Variable name cleaning
Export data
Refer to codebook for more detailed description of run_analysis.R script
