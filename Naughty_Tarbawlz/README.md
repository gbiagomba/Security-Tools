![alt tag](https://cdn-images-1.medium.com/max/1200/1*zHmD0vnFF9phLu2LIlJJpQ.png)

```
  _   _                   _     _           _______         _                    _     _ 
 | \ | |                 | |   | |         |__   __|       | |                  | |   | |
 |  \| | __ _ _   _  __ _| |__ | |_ _   _     | | __ _ _ __| |__   __ ___      _| |___| |
 | . ` |/ _` | | | |/ _` | '_ \| __| | | |    | |/ _` | '__| '_ \ / _` \ \ /\ / / / __| |
 | |\  | (_| | |_| | (_| | | | | |_| |_| |    | | (_| | |  | |_) | (_| |\ V  V /| \__ \_|
 |_| \_|\__,_|\__,_|\__, |_| |_|\__|\__, |    |_|\__,_|_|  |_.__/ \__,_| \_/\_/ |_|___(_)
                     __/ |           __/ |                                               
                    |___/           |___/                                                
```

# Naughty Tar Bawl
This folder contains a collection of encrytpted zip files (yes though not technically a tar file) that contain both non-malicious and malicious binaries from kali Linux (and other projects). The purpose of this folder and its contents is for anti-virus risk acceptance testing. 

# Side note: Encryption
If you are wondering why I password protected the zip file, it is to prevent the AV solution you are testing from reading the contents of the archive, and removing or modifying the zip file(s) the moment you connect the thumbdrive and/or copy the files to disk. BY password protecting the zip files, it makes it so that the AV solution can not identify which files are malicious and which are not unless you extra the contents.

# HOWTO: Usage
All you have to do is:
```
1. Copy the file(s) to a flash drive 
2. Unplug the flash drive 
3. Connect the flashdrive to your test machine 
4. Copy the files to disk OR Unzip the files on the flashdrive 
5. See if the AV catches the malicious binaries
6. Repeat steps 2-5 to infinium
```
You can also make a non-encrypted version and see if the AV detects the malicious binaries inside the zip file.

# Zip File Password
The zip files all share the same password! (see below):
```
P4ssw0rd!
```

# AV Evasion Checklist
Use the screenshot below to help you assessment
![alt tag](https://www.nextron-systems.com/wp-content/uploads/2018/06/Screen-Shot-2018-05-12-at-11.55.11.png)
1. https://www.nextron-systems.com/2018/05/12/new-antivirus-event-analysis-cheat-sheet-version-1-2/
2. https://www.nextron-systems.com/wp-content/uploads/2018/06/Software-Problem-Solving-Cheat-Sheet.pdf
3. https://www.nextron-systems.com/wp-content/uploads/2018/05/Antivirus_Event_Analysis_CheatSheet_1.2.pdf

# Got questions?
Submit an issue and I will address your concerns there
