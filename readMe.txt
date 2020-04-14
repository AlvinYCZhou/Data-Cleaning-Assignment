Hello! 
Thank you for reviewing my Assignment.

For your convenience, let’s review the 3 principals of tidy data:
• Each variable must have its own column.
• Each observation must have its own row.
• Each type of observational unit forms a table

The two data tables contained in this repo are both tidy, though I think the means_of_measurements.csv is even tidier, because they are:
1. A row only contains information of one observation exclusively;
2. All the data within one data have been standardized into (-1,1);
3. A column only contains one variables. 

Especially for the 3rd statement, in the original data, the variables' name also contains 4 types of information: time/frequency domain signal, specific observation, measurements in mean or std and specific dimension for some measurements, so I separate these informations into four extra columns in means_of_measurements.csv. I didn't apply this to the former data table due to its size, but we could also make it tidier through such method.

You could run the R script in the repo, it contains codes that help installing all the packages needed for the process, you could try it on your Rstudio, and I'll be appreciated if you have any comments or advices.

Thank you and have a nice data cleaning!
