Coursera - Getting and Cleaning Data - Course Project
=========================

##         Author:  Rafael Espericueta

***

The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

Here are the data for the project: 

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

***

### Reading in the Data

After unzipping the data file, we first read in the file *features.txt*, to modify these original feature names to use in naming our data frame columns. We extracted only those names containing *mean* or *std* as substrings. Further we then made sure the names were valid ones using the *make.names* command. That command replaces illegal characters with dots, so next we removed any pairs of dots, so that for example *cat...V...2* would become *cat.V.2*. We also noted by reading the file *features_info.txt* that features beginning with a "t" represented time series data, and features beginning with a "f" were FFT transformed features (transformed to the frequency domain).  So we
replaced the initial "t" by "Time.", and an initial "f" was replaced by "Freq." for improved readability.

Next we read in the file containing the subject codes *subject_train.txt*, the training data *X_train.txt*, and the training labels *"y_train.txt"*, and then subsetted the training data to only include the columns containing *mean*
or *"std"*. The test data was similarly read in (files: *subject_test.txt*, *X_test.txt*, and *y_test.txt*) and subsetted as before.

The training labels and test labels were appended to the traning and test data frames as final columns using *cbind*, and then the training and test data frames were combined using *rbind* into one data frame, *alldat*. Then the activity codes were tranformed from numeric to plain English for easier readability.

At this point we found the data to be complete, with no NA's present. However, we did discover a couple of columns with different names but containing the same data. It turned out that the columns *Time.BodyAccMag.mean* and *Time.GravityAccMag.mean* contained the same data, so we deleted the column *Time.BodyAccMag.mean*.  Also the column
*Time.BodyAccMag.std* and *Time.GravityAccMag.std* contained the same data, so we deleted the column *Time.BodyAccMag.std*.  We then checked for duplicate rows, but found none.

Our tidy data frame, *alldat*, was then written to the file, *tidy_data.txt*, using the command:  

    write.table(alldat, "tidy_data.txt", sep="\t")

To read this file, use the command:

    td <- read.table("tidy_data.txt", sep="\t")

From the data frame *alldat*, we created a new data frame *alldat.mean* containing the means for each choice of a subject and an activity. Each subject had several measurements for each activity, which were averaged, so we ended up with a data frame with 6 rows for each subject (corresponding to the 6 activities, *Walking*, *Walking_upstairs*, *Walking_downstairs*, *Sitting*, *Standing*, *Laying*). The column names were left as before, though in the new data frame *alldat.mean*, the values are the *means* of those measurements. Appending the designation "Mean" to each name would have made the feature names a bit cumbersome.

Finally we output our second tidy data frame, *alldat.mean*, to the file *tidy_data_mean.txt*, using the command:

    write.table(alldat.mean, "tidy_data_means.txt", sep="\t", row.names=FALSE)
    
Read this file using the command:

    td <- read.table("tidy_data_means.txt", header = TRUE, sep="\t")
    



