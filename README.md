# Smart meter data and code for Big Data section of European Masters in Official Statistics course

## Overview

The European Master in Official Statistics is a network of Master programmes providing post-graduate education in the area of official statistics at the European level. On 12 January 2017, there was a session on big data and data science in official statistics at Southampton University. This repository shows the data, questions and answers used in the exercise at the end of the session.

## What does this repository do?

The data provided is half hourly open smart meter data. The exercise asks the student to build a model which distinguishes between weekends and weekdays using only the data provided. Questions and answers are shown.

## How do I use it?

### Requirements/Pre-requisites

R is required to perform this analysis, along with the R packages:
* ggplot2
* chron
* reshape2
* caret
* e1071
* timeDate

### Running the project

*Analyse smart meter data - to complete by students.R* will not run as it is. It requires students to complete the code correctly to run

*Analyse smart meter data - answers.R* requires the user to set the work directory of the location of the *Building3Electricity.csv* file by using
`setwd()`

### Data

Source data: [Open smart meter data from data.gov.uk website](https://data.gov.uk/dataset/energy-consumption-for-selected-bristol-buildings-from-smart-meters-by-half-hour)

## Useful links 

[European Master in Official Statistics](http://ec.europa.eu/eurostat/web/european-statistical-system/emos)  

## Contributors

[Karen Gask](https://github.com/gaskyk) and [Alessandra Sozzi](https://github.com/AlessandraSozzi), both working for the [Office for National Statistics Big Data project](https://www.ons.gov.uk/aboutus/whatwedo/programmesandprojects/theonsbigdataproject)

## Licence

Released under the [GNU General Public License, version 3](https://github.com/ONSBigData/Who-you-work-with/blob/master/LICENSE).
