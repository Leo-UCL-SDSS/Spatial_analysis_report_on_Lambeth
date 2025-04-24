ethnicity_input <- read.csv("~/Downloads/Worksheet_Data/All_2021_Census/ts021.csv")
rooms_input <- read.csv("~/Downloads/Worksheet_Data/All_2021_Census/ts053.csv")
qualifications_input <-read.csv("~/Downloads/Worksheet_Data/All_2021_Census/ts067.csv")
employment_input <-read.csv("~/Downloads/Worksheet_Data/All_2021_Census/ts066.csv")
ethnicity <- data.frame(OA=ethnicity_input$OA,White_British=(ethnicity_input$ts0210018/ethnicity_input$ts0210001)*100)
rooms <- data.frame(OA=rooms_input$OA, Low_Occupancy=(rooms_input$ts0530002/rooms_input$ts0530001)*100)
qualifications <- data.frame(OA=qualifications_input$OA, Qualification=(qualifications_input$ts0670007/qualifications_input$ts0670001)*100)
employment <- data.frame(OA=employment_input$OA, Unemployed=(employment_input$ts0660013/employment_input$ts0660001)*100)
merged_data_1 <- merge(ethnicity, rooms, by="OA")


#2 Merge the "merged_data_1" object with Employment to create a new merged data object
merged_data_2 <- merge(merged_data_1, employment, by="OA")

#3 Merge the "merged_data_2" object with Qualifications to create a new data object
census_data <- merge(merged_data_2, qualifications, by="OA")

#4 Remove the "merged_data" objects as we won't need them anymore
rm(merged_data_1, merged_data_2)
write.csv(census_data, "~/Downloads/Worksheet_Data/eng_wales_practical_data.csv", row.names=F)

