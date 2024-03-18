---
title: "Coursework 1"
author:
- name: School of Mathematical Sciences 
- Masturina Mohd Zainudin 
date: "March 2024"
output:
  html_document:
    toc: true
    toc_float: true
editor_options: 
  markdown: 
    wrap: 72
---

```{r, echo=FALSE}
htmltools::img(src = knitr::image_uri("QMlogo.png"), 
               alt = 'logo', 
               style = 'position:absolute; top:0; right:0; padding:10px; width:30%;')
```

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

### 1.0 Prophet - What is it about?

Meta, formerly known as Facebook, developed Prophet. It's not a product
you directly interact with, but rather a software tool used for time
series forecasting.

```{r, echo=FALSE}
htmltools::img(src = knitr::image_uri("ProphetLogo.png"), 
              alt = 'logo',
    style = 'display:block; margin:auto; width:50%;')
```

**Prophet's functionalities that offer valuable advantages for time
series analysis:**

*Makes predictions about future trends:*

-   It analyses historical data to identify patterns and seasonality

-   Then forecast what might happen next

-   Helpful for businesses that need to predict things like sales,
    website traffic or resource allocation.

*Works well with specific data:*

-   Prophet is designed for time series data, which means data points
    are collected at regular intervals over time.

-   Good at handling data that has trends and seasonal patterns.

-   Example: daily sales figures or website visits that spike around
    holidays.

*Relatively easy to use:*

-   User friendly - library available to use in RStudio & Python


### 1.1 Getting started - install packages 

- Install by typing `install.packages("prophet")` at console when install it for the first time. 

- Meta suggests using the latest release. Then also install:
        i.  first run `install.packages("remotes")` and then
        ii. run `remotes::install_github('facebook/prophet@*release', subdir='R')`
        

### 1.2 What is CO2?

Mauna Loa Atmospheric CO2 Concentration Atmospheric concentrations of
CO_2 are expressed in parts per million (ppm) and reported in the
preliminary 1997 SIO manometric mole fraction scale. 

Format: A time series of 468 observations; monthly from 1959 to 1997. 

Details: The values for February, March and April of 1964 were missing and have been
obtained by interpolating linearly between the values for January and
May of 1964.


```{r}
require(graphics)
plot(co2, ylab = expression("Atmospheric concentration of CO"[2]),
     las = 1)
title(main = "co2 data set")
```


Overview of CO_2 Dataset

```{r}
str(co2)
head(co2)
summary(co2)
```


### 1.3 Purpose of the project 

**The purpose of this project is to analyse and forecast CO2 concentration levels over time. It utilises the concept of time series analysis.**

Time series analysis involves techniques for:

- *Understanding trends:* 

Identifying the overall direction or pattern in which the data is moving over time (e.g., increasing, decreasing, or staying relatively constant).


- *Identifying seasonality:* 

Detecting recurring patterns within the data that occur at specific time intervals (e.g., seasonal variations in CO2 levels).


- *Forecasting future values:*

Leveraging past data to make informed predictions about future values in the time series (e.g., predicting CO2 concentrations for the upcoming quarters).

### 2.0 Prophet Model for CO2 Forecasting

#### Run required library
```{r eval=FALSE, include=TRUE}
library(prophet)
library(remotes)
require(graphics)

dataframe <- read.csv('https://raw.githubusercontent.com/facebook/prophet/main/examples/example_wp_log_peyton_manning.csv')
```

#### Create a data frame for CO2 data
Creates a dataframe co2.df with dates represented in year and month format (ds) extracted from the co2 object and CO2 concentration values (y) assigned to the dataframe.

```{r}
co2.df = data.frame(ds = zoo::as.yearmon(time(co2)), y = co2)

#check head, tail of dataframe
head(co2.df)
tail(co2.df)
```

#### Fit a Prophet model to the CO2 data
```{r}
co2_prophet_model = prophet::prophet(co2.df)
```

#### Generate future timestamps for forecasting
Creates a dataframe ("future") containing future timestamps for forecasting based on the fitted Prophet model (co2_prophet_model).

The timestamps are spaced at quarterly intervals, and the function generates timestamps for 8 future periods.

These future timestamps will be used to make predictions using the Prophet model.
```{r}
future = prophet::make_future_dataframe(co2_prophet_model, periods = 8, freq = "quarter")

#check head & tail of future timestamps
head(future)
tail(future)
```

#### Predict CO2 concentrations for future dates
```{r}
co2_forecast = predict(co2_prophet_model, future)

#check head & tail of co2_forecast 
head(co2_forecast)
tail(co2_forecast)
```

#### Plot the original CO2 data and forecasted values
```{r}
plot(co2_prophet_model, co2_forecast, main = "co2 data & forecast", xlab = "Year", ylab = "co2")

```

### 2.1 Time Series Analysis

Using decompose funtion, where it will decompose a time series into seasonal, trend and irregular components using moving averages. Also deals with additive or multiplicative seasonal component.

```{r}
require(graphics)
decomposed <- decompose(co2)
decomposed$figure
plot(decomposed)
```

#### Trend

Trend represents the long-term movement or directionality of the time series data. 

In the context of Prophet data, the trend component captures the overall *increasing* pattern over time


```{r}
decomposed <- decompose(co2)
plot(decomposed$trend, main = "Trend of CO2 Levels", xlab = "Year", ylab = "Trend")
```


#### Seasonal decomposition

Seasonality refers to the repetitive patterns or fluctuations that occur at regular intervals within the time series data.

In Prophet data, seasonality captures recurring patterns that repeat over fixed periods, such as daily, weekly, monthly, or yearly cycles. 

For instance, if CO2 concentrations exhibit higher levels during certain months of the year due to seasonal factors, this would be captured in the seasonality component. For example, holidays like Christmas or New Year's Day might affect CO2 concentrations due to changes in human activities.

```{r}
decomposed <- decompose(co2)
plot(decomposed$seasonal, main = "Seasonal Component of CO2 Levels", xlab = "Year", ylab = "Seasonal Component")
```





#### Noise

Noise (Error Term): Represents the random fluctuations or unmodeled variability in the data.

There are slight random fluctuations of the data, especially on year 1970 and early 1990.

```{r}
noise <- co2 - decomposed$trend - decomposed$seasonal
plot(noise, main = "Noise in CO2 Levels", xlab = "Year", ylab = "Noise")
```




### 2.2 Linear Regression Model

Linar Regression Model to understand the underlying trends in the time series data and comparing it to the predictions made by the Prophet model.

The intercept represents the estimated CO2 concentration at the starting point of the time series, while the slope indicates the rate of change in CO2 concentrations over time.

Positive slope values indicate an increasing trend.

By fitting a linear regression model alongside the Prophet model, one can compare the linear trend estimated by the regression model with the trend component predicted by Prophet.

This comparison helps assess the linearity of the underlying trend and evaluate whether the Prophet model adequately captures the trend in the data.

```{r}

lm_model <- lm(y ~ ds, data = co2.df)

# Summary of the linear regression model
summary(lm_model)

# Plot the linear regression line
plot(co2.df$ds, co2.df$y, main = "CO2 Levels over Time with Linear Regression",
     xlab = "Year", ylab = "CO2 Level", type = "l")
abline(lm_model, col = "red")

```


### 2.3 Result

The primary result of the Prophet model is the forecasted values for CO2 concentrations for future time periods. 

These forecasted values represent the model's predictions of CO2 levels based on the observed trends, seasonality, noise and some other factors captured in the data.

In term of trend, it can be observed that CO2 level are generally increasing by year.

Seasonality in general refers to patterns that repeat over a fixed and known period, typically within a year or less. Patterns are often linked to natural or cultural events, such as holidays, weather patterns, or annual business cycles. Examples include higher CO2 emission during festive session. Seasonal patterns exhibit regular, predictable fluctuations with consistent shape and amplitude each year. 

Noise in Prophet meta time series can affect the accuracy and reliability of the model's predictions. Excessive noise may obscure underlying patterns and make it challenging to extract meaningful insights from the data. However, moderate levels of noise are expected in real-world data and are typically handled by the model through the estimation of prediction intervals.
Handling Noise:

Techniques to reduce its impact must be explored, such as data preprocessing, outlier detection, or model refinement. Additionally, evaluating the prediction intervals provided by the model can help quantify the uncertainty associated with the forecasts and account for the presence of noise.

Understanding the presence of noise in Prophet Meta time series is essential for interpreting the model's forecasts and making informed decisions based on the predicted values. It is important to recognise that noise is an inherent aspect of the data and to consider its implications when analysing and interpreting the results.





### 3.0 Exploring Prophet with new dataframe

Load Prophet library and insert new dataframe from [Prophet website](https://facebook.github.io/prophet/docs/quick_start.html#r-api)

```{r}
library(prophet)
df <- read.csv('https://raw.githubusercontent.com/facebook/prophet/main/examples/example_wp_log_peyton_manning.csv')
model <- prophet(df)
futures <- make_future_dataframe(model, periods = 365)


#check head and tail 
head(futures)
tail(futures)


forecast <- predict(model, futures)
tail(forecast[c('ds', 'yhat', 'yhat_lower', 'yhat_upper')])
```


Plot the forecast for a year of the new dataframe which consists of data from late December 2007 to January 2017.

```{r}
plot(model, forecast, main = "Forecast", xlab="year", ylab="forecast")
```

Produce plot components of Prophet which contains trend with a forecasted data in period of 365 days, weekly plot which shows that highest value recorded is on Monday, and lowest is on Saturday. Also, yearly plot which shows that highest is around late January to early February, and lowest is around end of June. 

```{r}
prophet_plot_components(model, forecast)
```

Create an interactive plot of the forecast using dyplot command

```{r}
dyplot.prophet(model, forecast)
```














