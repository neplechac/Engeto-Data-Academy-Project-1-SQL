# **ENGETO Data Academy** 
## **Project 1 - SQL**
### Introduction
In your analytical department of an independent company that focuses on the living standards of citizens, you have decided to answer a few defined research questions that address the availability of basic food products to the general public. Your colleagues have already identified the basic questions they will attempt to answer and provide this information to the press department. This department will present the findings at the next conference focusing on this area.

To do this, they need you to **prepare a robust data set showing how the food availability compares to average income over a period of time.**

As a supplementary material, also prepare a table with GDP, GINI coefficient and population of **other European countries** in the same time period as the primary overview for the Czech Republic.

### Solution
### Tables and views
- Primary table `t_ondrej_plechac_project_SQL_primary_final`:
    - `name` – name of the industry/food category/GDP;
    - `year` – year to which the data refer;
    - `value` – average income/price/GDP value;
    - `code` – *100* for average income data, *200* for food prices data, *300* for GDP data;
    - `price_value` and `unit` – specify the units in food prices data (per 1 kg, 0,75 l etc.);
- Secondary table `t_ondrej_plechac_project_SQL_secondary_final`:
    - `country` - name of the country;
    - `year` - year to which the data refer;
    - `GDP` - GDP value (not available for every country/year);
    - `gini` - gini value (not available for every country/year);
    - `population` - population count;
- Additional views for query optimization.

### Research questions
**1. Have wages in all sectors been rising over the years, or have they been falling in some?**  
The data show that, according to the period under review, i.e. between 2000 and 2021, average wages in all sectors increased overall. However, in certain years we can observe a year-on-year decline in some sectors, most notably in 2013.

**2. How many litres of milk and kilograms of bread can be bought in the first and last comparable period in the available prices and income data?**  
For the average income one could buy 1,465 litres of milk or 1,312 kilograms of bread in 2006 and 1,669 litres of milk or 1,365 kilograms of bread in 2018.

**3. Which food category is increasing in price the slowest (lowest percentage increase year-on-year)?**  
The lowest overall increase is recorded for crystalline sugar and tomatoes – these two categories have even become less expensive over the years and their price in 2018 is thus lower than in 2006 (-27.52% decrease for crystalline sugar and -23.07% decrease for tomatoes).

**4. Has there been a year in which the year-on-year increase in food prices was significantly higher than income growth (greater than 10%)?**  
No, there has not been any. The most notable difference (6.66%) can be seen in 2013, when food prices rose by 5.1% year-on-year but average income fell by 1.56%. In the other direction, the biggest difference (9.48%) can be found in 2009, when food prices fell by 6.41% year-on-year but average income rose by 3.07%.

**5. Is GDP affecting average income and food price changes? That is, if GDP rises more significantly in one year, will this be reflected in a more substantial rise in food prices or average income in the same or the following year?**  
If we consider an annual GDP increase of more than 5% to be significant, such an increase occurred three times in the observed period (2007, 2015 and 2017).

However, while there were larger increases in average income and food prices in 2007 and 2017 and in the years immediately following, the increase in average income and food prices in 2015 and 2016 was not very large despite the significant growth of GDP. Food prices even declined slightly in both these years. Therefore, it cannot be said with certainty from the available data that the level of GDP has an impact on changes in food prices and average income.




