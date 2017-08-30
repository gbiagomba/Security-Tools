#!/bin/bash
# Decrypt a file that contains multiple PGP message blocks
# Output is placed into a file with all information decrypted
# Usage: ./decryptor [FileToDecrypt.txt] [DecryptionPassword]


if [ $# -lt 3 ] || [ $# -gt 3 ] 
    then 
	echo "Usage: ./decryptor [DecryptionPassword] [InputFile.txt] [OutputFile.txt]" &&
	exit
fi

echo Password for pgp is: $1
echo Input file is: $2
echo Output file is: $3

csplit -b %02d.gpg -f tmpout $2 '/END PGP MESSAGE/1' '{*}'
# Split the encrypted file into separate files with 1 encrypted message per file

gpg --batch --passphrase $1 --decrypt-files tmpout*
# Decrypt all the individual files

rm *.gpg
# Remove all the encrypted individual files

cat tmpout* > hold
# Combine decrypted individual files into decrypted file

rm tmpout*
# Remove remaining junk files

sed -e 's///g' hold > $3
rm hold
# Clean up carriage returns



