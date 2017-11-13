install.packages("reshape2")

libray(reshape2)

filename <- "datafile.zip"
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(url,file.path(path,filename))
unzip(zipfile = filename)

#Load activity_labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <-  read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

#Extract mean and standard deviation data
requiredfeatures <- grep(".*mean.*|.*std.*", features[,2])
requiredfeatures.labels <- features[requiredfeatures,2]
requiredfeatures.labels = gsub('-mean', 'Mean', requiredfeatures.labels)
requiredfeatures.labels = gsub('-std', 'Std', requiredfeatures.labels)
requiredfeatures.labels = gsub('[-()]', '', requiredfeatures.labels)

#Load train dataset
train <- read.table("UCI HAR Dataset/train/X_train.txt")[requiredfeatures] 
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt") 
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt") 
train <- cbind(trainSubjects, trainActivities, train)

#Load test dataset
test <- read.table("UCI HAR Dataset/test/X_test.txt")[requiredfeatures] 
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt") 
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt") 
test <- cbind(testSubjects, testActivities, test)

#merge datasets
combinedData <- rbind(train,test)
colnames(combinedData) <- c("subject", "activity",requiredfeatures.labels)


combinedData$activity <- factor(combinedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
combinedData$subject <- as.factor(combinedData$subject)

combinedData.melt <- melt(combinedData, id = c("subject", "activity"))
combinedData.mean <- dcast(combinedData.melt, subject + activity ~ variable, mean)

write.table(combinedData.mean, "tidyData.txt", row.names = FALSE, quote = FALSE)


