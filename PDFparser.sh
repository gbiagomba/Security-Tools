#!/bin/bash
for PDF in $(cat filelist);do
/home/gilbia01/xpdfbin-linux-3.04/bin64/pdfinfo $PDF
done
