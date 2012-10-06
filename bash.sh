#!/bin/bash
set -e

##
# Functions
##

function pause {
    read -p ""
}

function gitlg {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset %C(blue)(%an <%ae>)%Creset' --abbrev-commit --date=relative
}

function showlg {
    echo && echo $1 && gitlg | more && echo
    pause
}

function commitFile {
    echo foobar > $1
    git add $1
    git commit -m "$1 added" --quiet
}


##
# Setup
##

mkdir git
cd git
git init >> /dev/null

##
# Initial commit
##

commitFile initial

##
# Feature-x
##

git checkout -b feature-x --quiet
for((i=1;i<=5;i++)); do commitFile $i; done
showlg 'feature-x log'

##
# Switch back to master
##

git checkout master --quiet

##
# Feature-y
##

git checkout -b feature-y --quiet
for((i=6;i<=10;i++)); do commitFile $i; done
showlg 'feature-y log'

##
# Create stage-n
##

git checkout master --quiet
git branch stage-n

##
# Create stage-n-feature-x and rebase onto stage-n
#
# Merge stage-n-feature-x onto stage-n
##

git checkout feature-x --quiet
git checkout -b stage-n-feature-x --quiet
git rebase stage-n --quiet

git checkout stage-n --quiet
git merge stage-n-feature-x --no-ff -m "Merge branch 'feature-x'" --quiet
showlg 'stage-n log (merged stage-n-feature-x)'

##
# Create stage-n-feature-y and rebase onto stage-n
#
# Merge stage-n-feature-y onto stage-n
##

git checkout feature-y --quiet
git checkout -b stage-n-feature-y --quiet
git rebase stage-n --quiet

git checkout stage-n --quiet
git merge stage-n-feature-y --no-ff -m "Merge branch 'feature-y'" --quiet
showlg 'stage-n log (merged stage-n-feature-y)'

##
# FF Merge stage-n onto master
##

git checkout master --quiet
git merge stage-n --ff-only --quiet
showlg 'master log (ff merged stage-n)'

##
# Cleanup - Don't need feature branches anymore if they are merged into master
##

git branch -D stage-n-feature-y >> /dev/null
git branch -D stage-n-feature-x >> /dev/null
git branch -D stage-n >> /dev/null
git branch -D feature-y >> /dev/null
git branch -D feature-x >> /dev/null
showlg 'master log (cleaned)'

