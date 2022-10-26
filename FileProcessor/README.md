# steps to use
1. put your clientID and clientSecret with your tenant
2. put your user UPN and your mailfolder ID in the while loop

works using a subfolder in a mailbox, only receive emails with an specific title and 1 attachment
title is used to select destination folder, each title is a queue in FileProcessor to print attachment with specific tray

# Tip 
to retreive subfolder id on mailbox you can use this query https://graph.microsoft.com/beta/users/UPN/mailFolders/
