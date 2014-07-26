#
# Getting & Cleaning Data - Course Project 
# 
# Author - Rafael Espericueta
#

# Read in all pertinent data files.

# Feature Name
# This file is a list of feature names.  We are to only keep features that
# are means or standard deviations. The substrings "mean" and "std" indicate
# the columns we wish to keep.
#
# NOTE: This is where we accomplish task 4, to appropriately label the data set
#       with descriptive activity names.
#
features <- read.table("features.txt")
features <- features[grepl("mean", features$V2) | grepl("std", features$V2), c("V1", "V2")]
# Make sure the column names are valid.
features$V2 <- make.names(features$V2, unique = TRUE, allow_ = TRUE)
# Delete any ".." substrings in the column names. 
features$V2 <- lapply(features$V2, function(s) { gsub("[.][.]", "", s) })
# Change any initial "t" in each name to "Time.", standing for "time series".
features$V2 <- lapply(features$V2, function(s) { sub("^t", "Time.", s) })
# Change an initial "f" in each name to "Freq." for "frequency", as this is FFT transformed.
features$V2 <- lapply(features$V2, function(s) { sub("^f", "Freq.", s) })


# Training data
subtrain <- read.table("subject_train.txt");  colnames(subtrain)[1] <- "Subject"
Xtrain <- read.table("X_train.txt")
Ytrain <- read.table("y_train.txt");  colnames(Ytrain)[1] <- "Activity"

# Only keep training data columns that are means or stds.
Xtrain <- subset(Xtrain, select = features$V1);  colnames(Xtrain) <- features$V2

# Test data
subtest <- read.table("subject_test.txt");  colnames(subtest)[1] <- "Subject"
Xtest <- read.table("X_test.txt")
Ytest <- read.table("y_test.txt");  colnames(Ytest)[1] <- "Activity"

# Only keep test data columns that are means or stds.
#
# NOTE: This accomplishes task 2, extracting only the measurements on 
#       the mean and standard deviation for each measurement. 
#
Xtest <- subset(Xtest, select = features$V1);  colnames(Xtest) <- features$V2

# Concatenate subject column with data and with label column.
Xtrain <- cbind(subtrain, Xtrain, Ytrain)
Xtest <- cbind(subtest, Xtest, Ytest)

# Combine the training and test sets into one data frame.
#
# NOTE: This completes task 1, merging the training and test 
#       sets to create one data set.
#
alldat <- rbind(Xtrain, Xtest)

# Change the Activity column to have descriptive names instead of numbers.
#
# NOTE: This accomplishes task 3, using descriptive activity names to 
#       name the activities in the data set.
#
activities <- c("Walking", "Walking_upstairs", "Walking_downstairs",
                "Sitting", "Standing", "Laying")
alldat$Activity <- activities[alldat$Activity]

sum(is.na(alldat)) == 0    # This is true, so there are no NA missing values.

# Discussion in the forums suggested duplicate columns, so lets have a peek...
# 
# This code reveals any columns that hold identical data.
col_length <- dim(alldat)[1];  row_length <- dim(alldat)[2]
for (i in 2:(row_length - 1)) {
  for (j in (i + 1):(row_length - 1)) {
    if ((j > i) & (sum(alldat[,i] == alldat[,j]) == col_length)) {
      print(c(i,  j))
    }
  }
}
# The result: columns 32 and 34 have duplicate data, as do 
# columns 33 and 35. The names of these columns:
nam <- names(alldat)
nam[32]; nam[34]  # "Time.BodyAccMag.mean", "Time.GravityAccMag.mean"
# Double checking:
sum(alldat$Time.BodyAccMag.mean == alldat$Time.GravityAccMag.mean) == col_length
nam[33]; nam[35]  # "Time.BodyAccMag.std", "Time.GravityAccMag.std"
# Double checking:
sum(alldat$Time.BodyAccMag.std == alldat$Time.GravityAccMag.std) == col_length
# Delete two redundant columns:
alldat$Time.BodyAccMag.mean <- NULL;  alldat$Time.BodyAccMag.std <- NULL

# While we're at it, let's check for any duplicate rows:
dim(alldat) == dim(alldat[!duplicated(alldat),])  # TRUE TRUE
# The expression alldat[!duplicated(alldat),]) returns the data frame alldat
# with any duplicate rows removed. The dimensions are the same, so there
# were no duplicate rows.


# Output our tidy dataframe, alldat, to file, "tidy_data.txt".
write.table(alldat, "tidy_data.txt", sep="\t")
# THIS is how to read that output file:
# td <- read.table("tidy_data.txt", sep="\t")
# sum(td != alldat) == 0   # TRUE, so the file was saved correctly


#
# Generate a mean for each combination of subject, activity, and measurement.
#

# Make lists of the unique subject identifiers and activities.
subjects <- unique(alldat$Subject);  activities <- unique(alldat$Activity)

#
# Create a new data frame containing the means of all rows having the
# same subject and activity.
#
# NOTE: This is where we accomplish task 5, to create a second, independent
#       tidy data set with the average of each variable for each activity 
#       and each subject.
#
first = TRUE  # flags the first time we run the inner loop
for (i in 1:length(subjects)) {
  for (j in 1:length(activities)) {
    # Subset out all records for this subject and this activity.
    s <- subset(alldat, Subject==subjects[i] & Activity==activities[j])
    s_names <- names(s)  # save column names for our new tidy data frame
    sm <- colMeans(s[, -79]) # no mean for activity
    smT <- t(sm)   # transpose it to be a row
    smT <- data.frame(smT)  # convert to data frame
    newRow <- cbind(smT, s[1, 79])  # append the activity column as last column
    newRow <- data.frame(newRow)  # convert to data frame
    names(newRow) <- s_names  # name the columns
    if (first) {
      alldat.mean <- newRow   # first row of new data frame
      first = FALSE
    } else {
      alldat.mean <- rbind(alldat.mean, newRow)  # append row to data frame
    } 
  }
}

# Output our 2nd tidy dataframe, alldat.mean, to file, "tidy_data_means.txt".
write.table(alldat.mean, "tidy_data_means.txt", sep="\t", row.names=FALSE)
# THIS is how to read that output file:
# td <- read.table("tidy_data_means.txt", header = TRUE, sep="\t")

