@echo off
REM Adding PCI Users
echo Adding users
Net user PCIAudit1 Aud214121 /add
Net user Neo gYm6gP8A /add
net user Morpheus j6vXLEpN /add
net user Oracle H44zNohn /add
REM Making PCI users admins
echo Adding accounts to the Admin Group
net localgroup administrators PCIAudit1 /add
net localgroup administrators Neo /add
net localgroup administrators Morpheus /add
net localgroup administrators Oracle /add