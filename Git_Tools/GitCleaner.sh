#this program was written to remove the github projects I acidentially downloaded to the root of the HDD
#Git_Mngr had a bug where it downloaded new projects to the root of the HDD, this is to clean this up

for project in $(cat GitPRJ.txt);do
	rm -rf $project
done
