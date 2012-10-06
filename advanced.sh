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
# Create stage-1
##

git checkout master --quiet
git branch stage-1

##
# Create stage-1-feature-x and rebase onto stage-1
#
# Merge stage-1-feature-x onto stage-1
##

git checkout feature-x --quiet
git checkout -b stage-1-feature-x --quiet
git rebase stage-1 --quiet

git checkout stage-1 --quiet
git merge stage-1-feature-x --no-ff -m "Merge branch 'feature-x'" --quiet
showlg 'stage-1 log (merged stage-1-feature-x)'

##
# Create stage-1-feature-y and rebase onto stage-1
#
# Merge stage-1-feature-y onto stage-1
##

git checkout feature-y --quiet
git checkout -b stage-1-feature-y --quiet
git rebase stage-1 --quiet

git checkout stage-1 --quiet
git merge stage-1-feature-y --no-ff -m "Merge branch 'feature-y'" --quiet
showlg 'stage-1 log (merged stage-1-feature-y)'

##
# Oops. Testing stage-1 will take ages, and the client wants feature-z ASAP!
#
# Feature-z
##

git checkout master --quiet
git checkout -b feature-z --quiet
for((i=11;i<=15;i++)); do commitFile $i; done
showlg 'feature-z log'

##
# Create stage-2
##

git checkout master --quiet
git branch stage-2

##
# Create stage-2-feature-z and rebase onto stage-2
#
# Merge stage-2-feature-z onto stage-2
##

git checkout feature-z --quiet
git checkout -b stage-2-feature-z --quiet
git rebase stage-2 --quiet

git checkout stage-2 --quiet
git merge stage-2-feature-z --no-ff -m "Merge branch 'feature-z'" --quiet
showlg 'stage-2 log (merged stage-2-feature-z)'

##
# FF Merge stage-2 onto master
##

git checkout master --quiet
git merge stage-2 --ff-only --quiet
showlg 'master log (ff merged stage-2)'

##
# Cleanup - Don't need feature-z / stage-2 branches anymore if they are merged into master
##

git branch -D stage-2-feature-z >> /dev/null
git branch -D stage-2 >> /dev/null
git branch -D feature-z >> /dev/null
showlg 'master log (cleaned - stage-2)'

##
# Oops. Stage-1 hasn't got latest master! Ahh, feature-x and feature-y ain't got latest master!
#
# Reset stage-1 branch
#
# Delete stage-1-feature-? branches
##

git checkout stage-1 --quiet
git reset master --hard --quiet

git branch -D stage-1-feature-x >> /dev/null
git branch -D stage-1-feature-y >> /dev/null

##
# Rebase feature-x and feature-y onto latest master
##

git checkout feature-y --quiet
git rebase master --quiet

git checkout feature-x --quiet
git rebase master --quiet

##
# Create stage-1-feature-x and rebase onto stage-1
#
# Merge stage-1-feature-x onto stage-1
##

git checkout feature-x --quiet
git checkout -b stage-1-feature-x --quiet
git rebase stage-1 --quiet

git checkout stage-1 --quiet
git merge stage-1-feature-x --no-ff -m "Merge branch 'feature-x'" --quiet
showlg 'stage-1 log (merged stage-1-feature-x)'

##
# Create stage-1-feature-y and rebase onto stage-1
#
# Merge stage-1-feature-y onto stage-1
##

git checkout feature-y --quiet
git checkout -b stage-1-feature-y --quiet
git rebase stage-1 --quiet

git checkout stage-1 --quiet
git merge stage-1-feature-y --no-ff -m "Merge branch 'feature-y'" --quiet
showlg 'stage-1 log (merged stage-1-feature-y)'

##
# FF Merge stage-1 onto master
##

git checkout master --quiet
git merge stage-1 --ff-only --quiet
showlg 'master log (ff merged stage-1)'

##
# Cleanup - Don't need feature-y / feature-x / stage-1 branches anymore if they are merged into master
##

git branch -D stage-1-feature-y >> /dev/null
git branch -D stage-1-feature-x >> /dev/null
git branch -D stage-1 >> /dev/null
git branch -D feature-y >> /dev/null
git branch -D feature-x >> /dev/null
showlg 'master log (cleaned - stage-1)'

