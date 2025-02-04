#!/bin/bash

# Commit any changes to the current branch
git add .
git commit -m "Auto-commit before updating website"

# Switch to the gh-pages branch
git checkout gh-pages

# Pull the latest changes from the remote gh-pages branch
git pull origin gh-pages

# Add and commit the new tutorial
git add tutorials/bash-tutorial.html
git commit -m "Added new tutorial: Bash Scripting Tutorial"

# Push the changes to the remote gh-pages branch
git push origin gh-pages

# Switch back to the main branch
git checkout main
