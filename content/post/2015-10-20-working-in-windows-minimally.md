---
title: Working in Windows, minimally
author: Eric C. Anderson
date: '2015-10-20'
slug: working-in-windows-minimally
categories: []
tags: []
---


I used to have a virtual Windows machine set up on my Mac laptop and I would use that
for compiling programs up for Windows, and testing things on the Windows side.  That laptop
was replaced, so I had to set up a new environment for cross compiling.  My goal in this
is to have to deal with Windows as little as possible, and, when I am in the Windows
environment, try to use tools that are familiar (i.e. Rstudio for R programming and 
a bash shell for nearly everything else.)  

In a nutshell here is what I did:

1. VirtualBox for running a virtual machine
2. Windows 7 package that Anthony had for the lab.
3. MinGW/msys for having a Unix-like environment and a C compiler
4. Git for getting files and repositories into the Windows world
5. R and Rstudio.

## Detailed notes

### Setting up VirtualBox

For this, I followed Anthony's detailed instructions:

- Install Virtual Box and open it.
- In the VB manager console click New. Name = `ECA_Win7; Type = Microsoft Windows; Version = Windows 7 (64-bit). Continue. This creates the folder ~/VirtualBox VMs/ECA_Win7`
- Move the contents of the folder I got from Anthony (the virtual machine stuff) into this new VB folder
- Back to VB manager, set the RAM for 2048 or whatever. Continue.
- Hard Drive. Click "Use an existing virtual hard drive file" and navigate to the big .vdi file that was copied into ECA_Win7. Continue.
- That should load up the Win 7 image into the left pane of the VB manager - before you start it up, select it and click Settings.
- On the tab, System -> Motherboard, make sure that 'Enable I/O APIC' is checked. OK.
- You should then be able to Start it up.
- Once you have Windows up, you need go to the VirtualBox VM menu item Devices and "Insert Guest Additions CD Image". Continue. Let it do its thing. Restart.
- Note: to change RAM, # of processors, internet config or access to host folders (Settings->Shared Folders) in VB settings, you need to shut down the client OS (i.e. in Windows, Start -> Shutdown) and then modify things and restart the VM.




### MinGW and msys

For this I did a standard install following the directions [here](http://www.mingw.org)


### Git

I downloaded and installed Git from [https://git-scm.com/download/win](https://git-scm.com/download/win). 
Simple install.  If you want to use it on the `msys` command line, you have to put it in the PATH 
(see below).  But, then you also have to configure it, as usual.  In the `msys` terminal I did this:

```
git config --global user.email "eric.anderson@noaa.gov"
git config --global user.name "Eric C. Anderson (From PC)"

# and while at it, did this too:
git config --global credential.helper wincred
```
and that takes care of it for command line use of `git` in the `msys` window.  However, 
it appears that Rstudio takes the settings from elsewhere (or runs git in the dos prompt and
it is incapable of getting to the `msys`-set configs from there).  So, in the 
PC Command Window (not the `msys` terminal), I did this:

```sh
"C:\Program Files\Git\bin\git.exe" config --global user.email "eric.anderson@noaa.gov"
"C:\Program Files\Git\bin\git.exe" config --global user.name "Eric C. Anderson (From PC)"
```
and while you are at it, you should do this, too:

```sh
"C:\Program Files\Git\bin\git.exe" config --global credential.helper wincred
```
which will let Rstudio cache my password so I can push to my repos without putting my password in
every time.

### msys configuration

In my home directory on `msys` I created a file `.profile` that looks like:

```
exec bash

```
Then I put there a `.bash_profile` with this:

```
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
```
And then a `.bashrc` that I put this into:

```
export PATH='/c/Program Files/Git/bin':$PATH
```
Here I have set the PATH to look in the `bin` directory of the `Git` folder which was
installed into `C:\Program Files`.  The single quotes apparently let `msys` deal with the 
space in the file name. So, I can access `git` from the command line on the `msys` terminal.

### R and Rstudio

I just downloaded these and did standard installs.  Under `Tools -> Global Options` I had
to point it to the git binary at `C:\Program Files\Git\bin\git.exe`.  It all seems to
be working beautifully.  One big note, if I want to be able to push stuff up to my repositories
on GitHub from the virtual machine I need to check them out from GitHub (through Rstudio,
for example) with my GitHub username (`eriqande`). So, for example, the URL I use for my
`newhybrids` repo when making a new Rstudio project is

```
https://eriqande@github.com/eriqande/newhybrids.git
```
Voila!

### A text editor
Anthony recommended [notepad++](https://notepad-plus-plus.org) as a text editor.  I downloaded and
installed it.  Seems to work great.

### Opening files from the command line

At this point, just about everything is working well.  I made a shortcut to `C:\MinGW\msys\1.0\msys.bat` 
which is what gives me an `msys` terminal that starts in my home directory.  Inside that I have a
directory called `git-repos` into which I can clone any repos I need to work on in Windows.  And when
I am done I can push any changes up.

I pretty much abhor using the `Windows Explorer` to navigate around, and double-clicking on things
bothers the sh*t out of me, so the final thing I want to make
sure I can do is open up files on the command
line.  Turns out that there is a `start` command in Windows that is already known in the `msys` bash 
shell, so all I need to do is add this to my `.bashrc`:

```
alias rs='start rstudio'
alias np='start notepad++'
```
Note that those have to be single quotes.

Now, things are pretty clean.  When I get onto my virtual machine I just go to the start menu and choose `msys.bat shortcut` and I get a bash shell.  Then:

```sh
cd git-repos/lobster_checkin
rs lobster_checkin.Rproj
```
opens my `lobster_checkin` project in Rstudio.  

## Conclusion

Phew! I can now compile programs up and test on Windows while having to as little ugly Windows
interaction as possible.  It's all good except that all the Windows updater crap and its general slow
bloatedness that I have to deal with.  But, it's only for a brief tortured time that I have to 
reside in that world...