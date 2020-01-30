# RTG-Julia-ReadingGroup


### Basic instructions for working with a cloned repo

Getting a copy on your computer use
```
shell: git clone https://github.com/WPolonik/RTG-Julia-ReadingGroup
```
This only needs to be done once. 

To get any new changes downloaded do 
```
git pull
```

If you have accidentally made changes to this cloned repo which you don't need, but you want to still download new updates to the remote repo you can do this first:
```
git stash
```



### Instructions for making a pull request

```
mouse: log into your github account
mouse: navigate to https://github.com/WPolonik/RTG-Julia-ReadingGroup
mouse: click the "Fork" button and follow instructions
mouse: navigate to the directory you want to put RTG-Julia-ReadingGroup
shell: git clone  https://github.com/YOUR_USERNAME/RTG-Julia-ReadingGroup
shell: cd RTG-Julia-ReadingGroup
shell: git remote add upstream https://github.com/WPolonik/RTG-Julia-ReadingGroup
```

Now you can check everything is correct by doing `git remote -v` and you should see it is linked to `WPolonik/RTG-Julia-ReadingGroup`

Now you can make edits and add things to your local repo. To save these edits use 

```
shell: git add --all
shell: git commit -m "new stuff"
shell: git push origin master
```

The last line above merges your local repo to your remote repo on github. 

To submit a pull request (i.e. ask WPolonik to merge the changes you've made on 
your forked remote repo):

```
mouse: navigate to https://github.com/YOUR_USERNAME/RTG-Julia-ReadingGroup
mouse: click "submit a pull request"
```

If there are changes to https://github.com/WPolonik/RTG-Julia-ReadingGroup you want to syncronize with your forked local repo do this


```
shell git pull upstream master
```


