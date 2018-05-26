PART 1 - REGRESSION

In this part of this project you will practice and experiment with linear regression using data from gapminder.org. I recommend spending a little time looking at material there, it is quite an informative site.

We will use a subset of data provided by gapminder provided by Jennifer Bryan described in it’s github page.

The following commands load the dataset

library(gapminder)
data(gapminder)
gapminder

For this exercise you will explore how life expectancy has changed over 50 years across the world, and how economic measures like gross domestic product (GDP) are related to it.

Exercise 1: Make a scatter plot of life expectancy across time.

Question 1: Is there a general trend (e.g., increasing or decreasing) for life expectancy across time? Is this trend linear? (answering this qualitatively from the plot, you will do a statistical analysis of this question shortly)

A slightly different way of making the same plot is looking at the distribution of life expectancy across countries as it changes over time:

library(tidyverse)
library(ggplot2)

gapminder %>%
  ggplot(aes(x=factor(year), y=lifeExp)) +
    geom_violin() +
    labs(title="Life expectancy over time",
         x = "year",
         y = "life expectancy")


This type of plot is called a violin plot, and it displays the distribution of the variable in the y-axis for each value of the variable in the x-axis.

Question 2: How would you describe the distribution of life expectancy across countries for individual years? Is it skewed, or not? Unimodal or not? Symmetric around its center?

Based on this plot, consider the following questions.

Question 3: Suppose I fit a linear regression model of life expectancy vs. year (treating it as a continuous variable), and test for a relationship between year and life expectancy, will you reject the null hypothesis of no relationship? (do this without fitting the model yet. I am testing your intuition.)

Question 4: What would a violin plot of residuals from the linear model in Question 3 vs. year look like? (Again, don’t do the analysis yet, answer this intuitively)

Question 5: According to the assumptions of the linear regression model, what should that violin plot look like?

Exercise 2: Fit a linear regression model using the lm function for life expectancy vs. year (as a continuous variable). Use the broom::tidy to look at the resulting model.

Question 6: On average, by how much does life expectancy increase every year around the world?

Question 7: Do you reject the null hypothesis of no relationship between year and life expectancy? Why?

Exercise 3: Make a violin plot of residuals vs. year for the linear model from Exercise 2 (use the broom::augment function).

Question 8: Does the plot of Exercise 3 match your expectations (as you answered Question 4)?

Exercise 4: Make a boxplot (or violin plot) of model residuals vs. continent.

Question 9: Is there a dependence between model residual and continent? If so, what would that suggest when performing a regression analysis of life expectancy across time?

Exercise 5: Use geom_smooth(method=lm) in ggplot as part of a scatter plot of life expectancy vs. year, grouped by continent (e.g., using the  color aesthetic mapping).

Question 10: Based on this plot, should your regression model include an interaction term for continent and year? Why?

Exercise 6: Fit a linear regression model for life expectancy including a term for an interaction between continent and year. Use the broom::tidy function to show the resulting model.

Question 11: Are all parameters in the model significantly different from zero? If not, which are not significantly different from zero?

Question 12: On average, by how much does life expectancy increase each year for each continent? (Provide code to answer this question by extracting relevant estimates from model fit)

Exercise 7: Use the anova function to perform an F-test that compares how well two models fit your data: (a) the linear regression models from Exercise 2 (only including year as a covariate) and (b) Exercise 6 (including interaction between year and continent).

Question 13: Is the interaction model significantly better than the year-only model? Why?

Exercise 8: Make a residuals vs. year violin plot for the interaction model. Comment on how well it matches assumptions of the linear regression model. Do the same for a residuals vs. fitted values model. (You should use the broom::augment function).


PART 2 - CLASSIFICATION

Data
We will use Mortgage Affordability data from Zillow to experiment with classification algorithms. The data was downloaded from Zillow Research page: https://www.zillow.com/research/data/

It is made available here: http://www.hcbravo.org/IntroDataSci/misc/Affordability_Wide_2017Q4_Public.csv

Preparing data
First, we will tidy the data. Please include this piece of code in your submission.

library(tidyverse)
library(lubridate)
theme_set(theme_bw())
csv_file <- "Affordability_Wide_2017Q4_Public.csv"

tidy_afford <- read_csv(csv_file) %>%
  filter(Index == "Mortgage Affordability") %>%
  drop_na() %>%
  filter(RegionID != 0, RegionName != "United States") %>%
  dplyr::select(RegionID, RegionName, matches("^[1|2]")) %>%
  gather(time, affordability, matches("^[1|2]")) %>%
  type_convert(col_types=cols(time=col_date(format="%Y-%m")))
tidy_afford

tidy_afford %>%
  ggplot(aes(x=time,y=affordability,group=factor(RegionID))) +
  geom_line(color="GRAY", alpha=3/4, size=1/2) +
  labs(title="County-Level Mortgage Affordability over Time",
          x="Date", y="Mortgage Affordability")


The prediction task
The prediction task we are going to answer is:

Can we predict if mortgage affordability will increase or decrease a year from now"

Specifically, we will do this for the last observation in the dataset (quarter 4 (Q4) of 2017). To create the outcome we will predict we will compare affordability for Q4 of 2017 and to Q4 of 2016 and label it as up or down depending on the sign of the this difference. Let’s create the outcome we want to predict (again, copy this bit of code to your submission):

outcome_df <- tidy_afford %>%
  mutate(yq = quarter(time, with_year=TRUE)) %>%
  filter(yq %in% c("2016.4", "2017.4")) %>%
  select(RegionID, RegionName, yq, affordability) %>%
  spread(yq, affordability) %>%
  mutate(diff = `2017.4` - `2016.4`) %>%
  mutate(Direction = ifelse(diff>0, "up", "down")) %>%
  select(RegionID, RegionName, Direction)
outcome_df

Now, you have a dataframe with outcomes (labels) for each county in the dataset.

The goal is then given predictors Xi for county i, build a classifier for outcome Gi∈{up,down}.

For your classifiers you should use data up to 2016.

predictor_df <- tidy_afford %>%
  filter(year(time) <= 2016)
Your project
Your goal for this project is to do an experiment to address a (one, single) technical question about our ability to make this prediction. There is a list of possible questions you may address below. Each of them asks two compare two specific choices in the classification workflow (e.g., two classification algorithms, two feature representations, etc.). You will implement each of the two choices and use 10-fold cross validation (across RegionID’s) to compare their relative performance. You will also create an AUROC curve to compare them.

Possible Questions
Feature representation and preprocessing
Does standardizing affordability for each region affect prediction performance? Compare standardized to non-standardized affordability.
Is using quarter to quarter change (continuous or discrete) improve prediction performance? Compare quarter to quarter change in affordability as predictors to affordability as predictor?
Should we use the full time series for each region, or should we use only the last few years? Compare full time series to a subset of the time series?
Should we expand the training set to multiple time series per region? For example, create a similar outcome for each time point in the dataset (change relative to affordability one year ago) and use data from the last couple of years as predictors. Train on the extended dataset and test on the 2017 data above?
Should we do dimensionality reduction (PCA) and use the embedded data to do prediction?
Create your own question!
Classification Algorithm
Is a decision tree better than logistic regression?
Is a random forest better than a decision tree?
Is K-nearest neighbors bettern than a random forest?
Create your own question!
Algorithm tuning
Does tuning hyper-parameters using cross-validation improve performance?
Note that you still have to make some choices regardless of the question you choose. For example, to do the feature preprocessing and representation experiments you have to choose a classifier (random forest for example), and decide what to do about hyper-parameters if appropriate.
