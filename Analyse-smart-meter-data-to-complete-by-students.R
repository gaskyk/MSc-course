###################################################
###                                             ###
###  Exercise:                                  ###
###  Analysing smart meter data                 ###
###                                             ###
###################################################

## Smart meters can digitally send meter readings to
## your energy supplier. They typically record gas
## or electricity readings every half hour, which 
## can be used to analyse regular patterns of use
## such as distinguishing between weekdays and
## weekends.

## Large scale trials have been done with domestic
## customers but today we will use open data from
## a commercial building in Bristol. The data is
## freely available from the data.gov.uk website.

## Today we will:
## 1. Read the data into R and tidy it up
## 2. Produce some summary statistics
## 3. Produce charts of patterns
## 4. Build a logistic regression model to
##    distinguish between weekends and weekdays.

## Step 1: Read in the data to R and tidy it up
## First import required libraries
library(ggplot2) # This is for nice charts
library(chron) # For chronological data
library(reshape2) # For reshaping data (eg.wide to long)
library(caret) # For machine learning
library(e1071) # For a confusion matrix
library(timeDate) # For extracting calendars

## Import the data and view it

## TASK 1: Read in the csv data including the headers
raw_data <- ...
View(raw_data)

## Some of these fields are not needed so delete them
## Delete the first four columns of raw_data
raw_data <- raw_data[-c(0:4)]  

## We also might want to tidy up the time column names
## so that they are easier to use (shouldn't contain dots)
## There are 48 half hours in the data
colnames(raw_data) <- c("Date","t1","t2","t3","t4","t5",
                        "t6","t7","t8","t9","t10",
                        "t11","t12","t13","t14","t15",
                        "t16","t17","t18","t19","t20",
                        "t21","t22","t23","t24","t25",
                        "t26","t27","t28","t29","t30",
                        "t31","t32","t33","t34","t35",
                        "t36","t37","t38","t39","t40",
                        "t41","t42","t43","t44","t45",
                        "t46","t47","t48")

## Now let's look at the structure of the data
## eg. whether it is numeric, date or character format

## TASK 2: Explore the structure of the data
...

## The Date field is a factor but we want it to be in
## date format so that we can manipulate it easier
raw_data$Date <- as.Date(raw_data$Date, format="%d/%m/%Y")

## Step 2. Produce some summary statistics
## Let's show the means for each half hour
## We don't want the mean for the date so we calculate
## it for all but the first column
means <- apply(raw_data[,2:49], 2, mean)
means

## Step 3. Produce charts of patterns
## First we have to convert 'means' to a data frame
means <- as.data.frame(means)
means$time <- times(0:47/48, format="h:m")

## TASK 3: Change the means$time variable to character format
means$time <- ...

ggplot(data=means, aes(x=time, y=means, group=1)) + geom_line() +
  labs(x="Time", y="Mean consumption (kWh)", title="Mean daily consumption") +
  ylim(0,70) + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.4)) + 
  scale_x_discrete(breaks = unique(means$time)[seq(1,48,2)])

## Now let's add another field to see if the date is a 
## weekend or weekday
## is.weekend returns TRUE or FALSE whether the date is a weekend or not.
## This function is available from the chron package
raw_data$Wday <- factor(is.weekend(raw_data$Date), 
                        levels=c(TRUE, FALSE), labels=c('weekend', 'weekday'))


## Let's create mean electricity consumption by weekend
## and weekday
means_wday <- aggregate(raw_data[,2:49], list(raw_data$Wday), mean, na.rm=TRUE)

## Graph the mean consumption by weekend / weekday
## Reformat the data to a long format first
means_wday <- as.data.frame(t(means_wday[,2:49]))
colnames(means_wday) <- c("Weekend","Weekday")
means_wday$time <- times(0:47/48, format="h:m")
means_wday$time <- as.character(means$time)
means_wday_long <- melt(means_wday, id.vars = c("time"))
means_wday_long$value <- as.numeric(means_wday_long$value)
ggplot(data=means_wday_long, aes(x=time, y=value, group = variable, colour = variable)) +
  geom_line() + labs(x="Time", y="Mean consumption (kWh)", title="Mean daily consumption by weekday or weekend") +
  ylim(0,80) + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.4)) + 
  scale_x_discrete(breaks = unique(means$time)[seq(1,48,2)])

## Step 4. Build a logistic regression model to
## distinguish between weekends and weekdays

## Back to the raw data. We can see from the graph that
## we might be able to distinguish between weekends and
## weekdays by examining the electricity consumption
## during the day, perhaps between 6am and 6pm

## Let's calculate the mean consumption by day 
## (6am to 6pm) and night

## TASK 4: Use the apply function to calculate the means of columns 13-37
## for the daytime mean electricity usage
raw_data$day_mean <- ...

raw_data$night_mean <- apply(raw_data[,c(2:12,38:49)], 1, mean)

## We can see that we might be able to distinguish
## between weekdays and weekends based on the day and
## night consumption
ggplot(data=raw_data, aes(x=night_mean, y=day_mean)) +
  geom_point(aes(color=Wday), size=4) + 
  labs(x="Mean nighttime consumption", y="Mean daytime consumption", title="Mean day and night consumption by weekday or weekend")

## Keep only key fields to do logistic regression on

## TASK 5: Create a new data frame for regression from the Wday, day_mean
## and night_mean columns respectively
regression_input <- ...

## Rename the columns
colnames(regression_input) <- c("Wday", "day_mean", "night_mean")

## Need to convert weekends / weekdays to 1 and 0 
## respectively
regression_input$Wday <- ifelse(as.character(regression_input$Wday) == "weekend", 1, 0)

## Now we need to split the dataset into training and
## testing datasets. If we fit the model on the whole
## data it will be overfitting on this and less good
## at predicting unseen data. By building a model on the
## training dataset then seeing how it performs on the
## (unseen) training dataset we get an empirical measure
## of how well the model performs.

## The raw data is randomly split into training and 
## testing data
set.seed(1235)
inTrain <- createDataPartition(y=regression_input$Wday, p=0.8, list=FALSE)
## p means 80% is training data, 20% testing
training <- regression_input[inTrain, ]
testing <- regression_input[-inTrain, ]

## Fit the logistic regression model on the training
## dataset
model <- glm(Wday ~., family=binomial(link='logit'), data=training)

## TASK 6: Summarise the model using the summary function
summary(...)

## Now see how well the model compares to the real
## data in the testing dataset
predictions <- predict(model, newdata=testing, type="response")

## TASK 7: Round the predictions values
predictions <- ...

confusionMatrix(predictions, testing$Wday)

## So we can predict with 97% accuracy whether the day
## falls at a weekend or weekday based on mean day and
## night electricity consumption

## TASK 8: The model doesn't work well for bank holidays where
## the commercial building may not be in much use. Can you use
## the holidayLONDON function (part of the timeDate package)
## to improve the prediction for bank holidays?


