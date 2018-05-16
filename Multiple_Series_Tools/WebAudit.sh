echo "What is the name of the target file?"
read targets
echo
echo "What is the name of the workspace?"
read workspace

PTH=$(pwd)

sniper -w $workspace -f $PTH/$targets -m nuke

for url in $(cat $targets);do
	dirb $url /root/.ZAP/fuzzers/dirbuster/directory-list-1.0.txt -o dirb_output.txt -w
	nikto -C all -h $url -o Nikto_Output.txt
done
