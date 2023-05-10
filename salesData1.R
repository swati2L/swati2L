library(dplyr)
library(ggplot2)
install.packages("plotrix")
library(plotrix)
#compare sales by region for 2016 with sales 2015 using bar chart
salesdata_copy<-SalesData|>group_by(region=Region)|>summarise(total_sales2015=sum(Sales2015),
                                                                total_sales2016=sum(Sales2016))
salesdata_copy<-salesdata_copy|>pivot_longer(c(total_sales2015,total_sales2016),
                  names_to = "year",values_to ="sales")
salesdata_copy$year[salesdata_copy$year=="total_sales2015"]<-"2015"
salesdata_copy$year[salesdata_copy$year=="total_sales2016"]<-"2016"


ggplot(salesdata_copy, aes(fill=year, y=sales, x=region)) +
  geom_bar(position='dodge', stat='identity')+geom_text(aes(label=sales))

View(salesdata_copy)

#pie chart for sales for each region of 2016
pie_chart<-SalesData|>group_by(Region)|>summarise(total_sales=sum(Sales2016))
View(pie_chart)
piepercent<-round(pie_chart$total_sales/sum(pie_chart$total_sales)*100,1)
labels<-pie_chart$Region
labels<-paste(labels,":",piepercent)
labels<-paste(labels,"%",sep = " ")

pie(pie_chart$total_sales,labels = labels,col = c("red","green","blue"),
main = "2D pie chart")
pie3D(pie_chart$total_sales,labels = labels,col = c("red","green","blue"),
main="3D pie chart")

#compare sales of 2016 & 2015 with region and tier
region_tier<-SalesData|>group_by(Region,Tier)|>
summarise(sales_2015=sum(Sales2015),sales_2016=sum(Sales2016))

region_tier<-region_tier|>gather(c(sales_2015,sales_2016),
key = "year",value=sales,c(Region,Tier))                                                        
View(region_tier)
ggplot(region_tier,aes(Tier,sales,fill = year)) + geom_bar(stat = "identity", position = "dodge")
+ facet_grid(Tier~ Region)

#In east region which state registered a decline in 2016 as compared to 2015
east_region<-SalesData|>group_by(State)|> filter(Region=="East")|>summarise(s_2016=sum(Sales2016),s_2015=sum(Sales2015))
east_region=gather(east_region,key = Year,value = Sales,-State)
View(east_region)
ggplot(east_region,aes(State,Sales,fill=Year))+geom_bar(stat = "identity",position = "dodge")+ggtitle("comparision of sales2015 to sales2016")

#in the High tier which division saw a decline in number of unit sold in 2016 as compared to 2015
high_tier<-SalesData|>group_by(Division)|> filter(Tier=="High")|>summarise(unit_2016=sum(Units2016),unit_2015=sum(Units2015))
View(high_tier)
high_tier<-pivot_longer(high_tier,c(unit_2016,unit_2015),names_to = "Division",values_to = "Unit")
ggplot(high_tier,aes(Division,Sales,fill=Year))+geom_bar(stat = "identity",position = "dodge")+ggtitle("comparison of 2015units to 2016units")

#Compare qtr wise sales in 2015 and 2016 in a bar plot
SalesData$QTR=if_else(SalesData$Month=="Jan"|SalesData$Month=="Feb"|SalesData$Month=="Mar","Q1",
              if_else(SalesData$Month=="Apr"|SalesData$Month=="May"|SalesData$Month=="Jun","Q2",
              if_else(SalesData$Month=="Jul"|SalesData$Month=="Aug"|SalesData$Month=="Sep","Q3","Q4")))
SALES_QTR<-SalesData|>group_by(QTR)|>summarise(qtr15=sum(round(Sales2015,1)),qtr16=sum(round(Sales2016,1)))          
View(SALES_QTR)

SALES_QTR<-pivot_longer(SALES_QTR,c(qtr16,qtr15),names_to = "Year",values_to = "sales")
ggplot(SALES_QTR,aes(QTR,sales,fill=Year))+geom_bar(stat = "identity",position = "dodge")+ggtitle("quarter wise comparison")

#determine the composition of qtr wise sales in and 2015 with regards to all the tiers in a pie chart (draw
#4 pie charts representing a qtr for each year)
q1<-SalesData|>group_by(Tier)|>filter(QTR=="Q1")|>summarise(totalsales15=sum(Sales2015))
q2<-SalesData|>group_by(Tier)|>filter(QTR=="Q2")|>summarise(totalsales15=sum(Sales2015))
q3<-SalesData|>group_by(Tier)|>filter(QTR=="Q3")|>summarise(totalsales15=sum(Sales2015))
q4<-SalesData|>group_by(Tier)|>filter(QTR=="Q4")|>summarise(totalsales15=sum(Sales2015))

q1<-round(q1$totalsales15/sum(q1$totalsales15)*100,1)
q2<-round(q2$totalsales15/sum(q2$totalsales15)*100,1)
q3<-round(q3$totalsales15/sum(q3$totalsales15)*100,1)
q4<-round(q4$totalsales15/sum(q4$totalsales15)*100,1)

lbls1 = q1$Tier|>paste(":",q1)|>paste("%",sep = "")         
lbls2 = q2$Tier|>paste(":",q2)|>paste("%",sep = "")         
lbls3 = q3$Tier|>paste(":",q3)|>paste("%",sep = "")         
lbls4 = q4$Tier |>paste(":",q4)|>paste("%",sep = "")   

par(mfrow = c(2,2)) 

pie(q1$totalsales15,labels = lbls2 ,col = c("red","blue","green"),radius = 1,main = "Q1")
pie(q2$totalsales15,labels = lbls2 ,col = c("red","blue","green"),radius = 1,main = "Q2")
pie(q3$totalsales15,labels = lbls3 ,col = c("red","blue","green"),radius = 1,main = "Q3")
pie(q4$totalsales15,labels = lbls4 ,col = c("red","blue","green"),radius = 1,main = "Q4")

