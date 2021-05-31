# copy from original source folder
robocopy U:\Source c:\gitsource  /mir /r:2 /w:2 /xd .git

# make commit a message
$today = get-date -format "yyyy-MM-dd"
$commitMessage = "daily full commit - $today"
write-output $commitMessage

# change directory to sourcegit
Set-Location -Path c:\sourcegit

# commit and push changed files
#git add .
#git commit -m %commitMessagetoday%
#git pull
#git push origin master

