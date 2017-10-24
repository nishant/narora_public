# Data Aggregator by Date

This program involves working with large volumes of time series data. In order
to gain valuable insights from the data, it must be efficiently recorded,
parsed, and categorized to display meaningful results to the viewer.

The input represents engagement data at different times for an arbitrary time
interval. The data is divided by categories including but not limited to
impressions, clicks, favorites, and retweets. The purpose of the task is to
aggregate the data by month and engagement category for the requested
time interval.

See **Files** and **Notes** for more information.


## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a local machine.

### Prerequisites
Knowledge about the following technologies is necessary to understand the implementation.

1. Ruby 2.3
2. Regular Expressions


### Installing

Clone this repository for local access via either command:
```
git clone https://github.com/nishant217/narora_public.git

git clone git@github.com:nishant217/narora_public.git
```

### Deployment

Navigate to this project in the cloned directory
```
cd [directoty-path]/data_aggregator
```

Run executable
```
./run
```

## Files
* data_aggregator.rb : contains the implementation
* small_input.txt : sample input for testing
* small_output.txt : sample output for testing
* large_input.txt : more extensive sample input for testing
* run : used to execute program
* out.txt : program output is written to this file

## Notes

### About the Input

Sample Input (small_input.txt):

2015-08, 2016-04

2015-08-15, clicks, 635

2016-03-24, app_installs, 683

2015-04-05, favorites, 763

2016-01-22, favorites, 788

2015-12-26, clicks, 525

2016-06-03, retweets, 101

2015-12-02, app_installs, 982

2016-09-17, app_installs, 770

2015-11-07, impressions, 245

2016-10-16, impressions, 567


* Each line is terminated by a single newline character ' \n'.
* The first line represents the start and end of the requested date interval.
* The start and end dates are separated by a single comma character ',' and zero or more space characters ' '.
* The second line is empty.
* The third line and onwards represent the time series data points.
* Each line represents a single data point, consisting of a date, engagement type, and number of engagements. The fields on each line are also separated by commas and optional spaces.
* Input dates are not expected to be in order.


### About the Output

Sample Output (small_output.txt):

2016-03, app_installs, 683

2016-01, favorites, 788

2015-12, app_installs, 982, clicks, 525

2015-11, impressions, 245

2015-08, clicks, 635


* The output consists of a line for each month in the requested interval, separated by a single newline character '\n' in order of most recent date to earliest date.
* Do not include months where there was no engagement data found.
* Each line consists of a month date (yyyy-mm), and the totals for each engagement type where the total is greater than 0, ordered alphabetically by the type of engagement.
* Each field on a given line must be separated by a single comma character ',' followed by a single space character.

### Other

* There are larger sample input and output files to test with as well.
* Problem correctness, time, and space complexity has been taken under consideration.
* This solution works for both small and large inputs.


## Built With

* [Ruby 2.3](https://www.ruby-lang.org/en/)


## Authors

* **Nishant Arora** - *All Files* - [nishant217](https://github.com/nishant217)
