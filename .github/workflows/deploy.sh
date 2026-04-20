#!/usr/bin/bash

# 1. Build the web app
# Replace 'your_repo_name' with your actual repository name
flutter build web --release --base-href "/your_repo_name/"

# 2. Navigate to the build directory
cd build/web

# 3. Initialize git and push to gh-pages
git init
git add .
git commit -m "Deploy to GitHub Pages"

# 4. Force push to the gh-pages branch
# Replace USERNAME and REPO_NAME
git push -f https://github.com/USERNAME/REPO_NAME.git master:gh-pages

# 5. Clean up: go back to project root
cd ../..