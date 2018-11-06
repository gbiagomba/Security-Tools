#!/usr/bin/env bash

for i in $(seq 0 40); do
	python nmapxmltocsvV2.py TLS-$i.xml TLS-$i.csv
	cat TLS-$i.csv >> ../Reports/TLS.CSV
done
