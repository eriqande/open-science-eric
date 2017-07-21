+++
date = "2014-12-19"
draft = false
title = "Accessing MS SQLserver with R from my Mac"
math = true
+++

A few years back I had used `unixODBC` and `freeTDS` to be able to connect from my Mac to the
Microsoft SQLserver that is here in the lab.  Since then I have switched computers
and upgraded operating systems, etc., and need to redo it.  My goal here is to be
able to use the RODBC package to slurp data from the SQL tables into R.

I have a whole collection of notes from the last time I did this.  It looks like there
are some nice instructions [here](http://hiltmon.com/blog/2013/09/18/setup-odbc-for-r-on-os-x/)
for connecting to postgreSQL.  Which might be a good resource.  

Let's try it:

## Install unixODBC

This can be done via homebrew, and maybe I will try that first, though last time I built it
from source by hand. In the terminal:

```sh
brew update
brew install unixodbc
```

That seemed very easy.

## Install freeTDS

Last time I built this by hand, too, but it looks like we should be able to brew it today:

```sh
brew install freetds --with-unixodbc  
```

The --with-unixodbc is esential, as otherwise you won't get the file `/usr/local/lib/libtdsodbc.so`.
That required a fair bit of crunching and had some caveats, but it looks like it completed without too
much trouble.


## Configuration files, etc

It looks like there are two different files that need to be modified to set up access to a particular
server or data base.  They are `/usr/local/etc/freetds.conf` and `/usr/local/etc/odbc.ini`.

### /usr/local/etc/freetds.conf

After the installations above, this file exists and has a section that looks like this:

```sh
# A typical Microsoft server
[egServer70]
  host = ntmachine.domain.com
	port = 1433
	tds version = 7.0
```

I modified that (use any text editor) to look like this:

```sh
# Big Creek Pit Tag data on Microsoft SQL-server at lab
[bcpittags]
  host = 161.55.237.11
	port = 1433
	tds version = 8.0
	client charset = UTF-8
```

### /usr/local/etc/odbc.ini

This file was present on my system after I installed `freetds`.  Apparently one can put a comparable
file into their home directory if desired, but I am fine sticking it in at the system level.  Here is 
what I put in it:

```sh
[bcpittags]
Driver=/usr/local/lib/libtdsodbc.so
Trace=No
Server=161.55.237.11
Port=1433
TDS_Version=8.0
Database=bcpittags
```

## Connecting

I tried connecting with my old username and password, and it failed, but then I tried
setting up and accessing Doug Jackson's data base with his username and password and it worked.

So, my account must have gotten deactivated (or the password changed) in the last upgrade to
pinniger.  I found that Rundio can connect to `bcpittags` from my machine using
his name and password (censored):

```sh 
isql -v  bcpittags daver ********
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| quit                                  |
|                                       |
+---------------------------------------+
```

Hooray!  Now, all that remains is checking to see that we can get to it from R.


## Connecting from R via RODBC

First, I got the RODBC package.  I had to build it from source:

```r
install.packages("RODBC", type = "source")
```

Then, I tried this:

```r
library("RODBC")

# create a connection
bcp <- odbcConnect("bcpittags", uid="daver", pwd="********")

# see what it looks like:
bcp

#> RODBC Connection 1
#> Details:
#>   case=nochange
#>   DSN=bcpittags
#>   UID=daver
#>   PWD=******
  

# try to run a query
lcbd <- sqlQuery(bcp, "SELECT * FROM MS_DC_genotyped_HDX_last_capt_and_beach_detect_UPDATED")

# did we  get something?
dim(lcbd)

#> [1] 919  14
```

Cool! It is working!


