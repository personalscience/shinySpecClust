# Glucotype Calculator

To generate a glucotype file, run the following from the command line:

```sh
rscript glucotyper.R
```

You'll get something whose first few lines look like this:

```sh
[1] "Prepare test"
pad applied on the interval: 5 min
[1] "Prepare training"
[1] "Predicting"
                   Index   low moderate  severe
1    2016-06-01 00:00:00   NaN      NaN 176.500
2    2016-06-01 00:05:00   NaN      NaN 197.590
3    2016-06-01 00:10:00   NaN      NaN 207.410
4    2016-06-01 00:15:00   NaN      NaN 211.450
```

Pipe the output to a text file if you like.

Next: I'll add something so you can give it command line parameters.

