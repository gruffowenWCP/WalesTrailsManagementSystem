# Load Libraries ---------------------------------------------------------------------------------------------------

library(tidyverse)
library(reshape2)
library(ggthemes)

# Import the data ---------------------------------------------------------------------------------------------------

issues <- 
  read.csv("Z:/Access Recreation & Education/Access & Recreation Programmes & Projs/Wales Coast Path & National Trails/WTMS - Annual Results/WCP - 2020 - 2021/Conwy/Issues_Conwy_2020-10-09.csv")

furniture <-  
  read.csv("Z:/Access Recreation & Education/Access & Recreation Programmes & Projs/Wales Coast Path & National Trails/WTMS - Annual Results/WCP - 2020 - 2021/Conwy/Furniture_Conwy_2020-10-09.csv")

furniture_qs_matching <- read.csv("Z:/Access Recreation & Education/Access & Recreation Programmes & Projs/Wales Coast Path & National Trails/WTMS - Annual Results/WCP - 2020 - 2021/1 - QS Category Mapping/InfraType_QS-Category - Mapper_21-02-20.csv")

issue_qs_matching <- read.csv("Z:/Access Recreation & Education/Access & Recreation Programmes & Projs/Wales Coast Path & National Trails/WTMS - Annual Results/WCP - 2020 - 2021/1 - QS Category Mapping/MaintType_QS-Category - Mapper_21-02-20.csv")

distances <- read.csv("Z:/Access Recreation & Education/Access & Recreation Programmes & Projs/Wales Coast Path & National Trails/WTMS - Annual Results/WCP - 2020 - 2021/1 - QS Category Mapping/TrailDistance.csv")

# Subset the variables we're interested in ---------------------------------------------------------------------------------------------------

## Issues
issues <- issues %>% 
  select( 
    Code = IssueCode,
    PromotedRoute,
    ManagingAuth,
    Region,
    IssueType,
    IssueTypeGroup,
    StatusDesc,
    PriorityDesc,
    Complete,
    Firm,
    ProtrusionFree,
    SafelySited,
    HandpostPresent,
    StepsInPlace,
    SwingFreely,
    LatchesAndBolts,
    HorseLatch,
    BackpackNegotiable,
    LogoPresent,
    OrientedCorrectly,
    ClearlyVisible,
    Bilingual,
    RouteName,
    Action,
    DateLastUpdated,
    PromotedRoute
  )

## Furniture

furniture <- furniture %>% 
  select(
    Code = InfraCode,
    PromotedRoute,
    ManagingAuth,
    Region,
    FurnitureType,
    FurnitureGroupType,
    LatestSurveyCondition,
    LatestSurveyDate
  )



# Apply Grouping Variables ---------------------------------------------------------------------------------------------------

## Issues

issues <- left_join(issues, issue_qs_matching, by = "IssueType")

### This kind of join will throw a warning that it is joining factors with different levels and will coerce to char vector
### so I want to coerce that column back to Factor:

issues$IssueType <- as.factor(issues$IssueType)

issues <- mutate(issues, RecordType = "Issue")


## Furniture

furniture <- left_join(furniture, furniture_qs_matching, by = "FurnitureType")

### This kind of join will throw a warning that it is joining factors with different levels and will coerce to char vector
### so I want to coerce that column back to Factor:

furniture$FurnitureType <- as.factor(furniture$FurnitureType)

furniture <- mutate(furniture, RecordType = "Furniture")

# Add trail distance to Issue & Furniture records

issues <- left_join(issues, distances, by = "Region")

furniture <- left_join(furniture, distances, by = "Region")

# Filter out redundant records ---------------------------------------------------------------------------------------------------

# Issues - filter out "HistoricRedundant" records and any records which aren't considered under Quality Standards.
issues <- filter(issues, StatusDesc != "HistoricRedundant", QS_Group1 != "Not QS")

# Furniture - filter out "Not Present" records and any records which aren't considered under Quality Standards.
furniture <- filter(furniture, LatestSurveyCondition != "Not Present", QS_Group1 != "Not QS")

# Bind Unresolved Issue Records and Present Furniture Records together (mostly for counting) ---------------------------------------------------------------------------------------------------

unresolved_issues <- filter(issues, StatusDesc == "Unresolved")
allrecords <- rbind(select(furniture, RecordType, QS_Group1, QS_Group2, QS_Group3), select(unresolved_issues, RecordType, QS_Group1, QS_Group2, QS_Group3))


# Tidy-up unecessary data frames

rm(furniture_qs_matching, issue_qs_matching)
