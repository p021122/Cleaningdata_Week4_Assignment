library("data.table"); library("reshape2")

#Cleaning the test dataset
activity_labels<- read.table("UCI HAR Dataset/activity_labels.txt")[,2]
activity_labels

features<- read.table("UCI HAR Dataset/features.txt")[,2]

#extract only mean and sd for each measurement
extracted_features_logic<-grepl("mean|std", features)

x_test<- read.table("UCI HAR Dataset/test/X_test.txt")
y_test<- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test<- read.table("UCI HAR Dataset/test/subject_test.txt")

names(x_test)<- features
x_test <- x_test[, extracted_features_logic]

#create a new column to label each observation
y_test[,2] = activity_labels[y_test[,1]]
names(y_test)<- c("Activity_ID", "Activity_Label")

names(subject_test)<- "subject"
test_data<- cbind(as.data.table(subject_test), x_test, y_test)
View(test_data)

#cleaning the train dataset

subject_train<- read.table("UCI HAR Dataset/train/subject_train.txt")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train<-read.table("UCI HAR Dataset/train/y_train.txt")
names(subject_train)<-"subject"
names(x_train)<- features

x_train = x_train[, extracted_features_logic]
y_train[,2]<-activity_labels[y_train[,1]]
names(y_train) <- c("Activity_ID", "Activity_Label")

train_data<- cbind(as.data.table(subject_train), x_train, y_train)
View(train_data)

#merge train and test data
merged_data<-rbind(test_data,train_data)
View(merged_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(merged_data), id_labels)
melt_data      = melt(merged_data, id = id_labels, measure.vars = data_labels)

tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")  
