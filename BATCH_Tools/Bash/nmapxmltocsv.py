#!/usr/bin/python
#I did not write this script, i got it from github and it was modified by my colleague

import sys
import argparse
import xml.etree.ElementTree as ET

def main(argv):
	inputfile = ''
	outputfile = ''
	parser = argparse.ArgumentParser(description="Parse Nmap XML output and create CSV")
	parser.add_argument('inputfile', help='The XML File')
	parser.add_argument('outputfile', help='The output csv filename')
	parser.add_argument('-n', '--noheaders', action='store_true', help='This flag removes the header from the CSV output File')
	args = parser.parse_args()
	inputfile=args.inputfile
	outputfile = args.outputfile
	
	try:
		tree = ET.parse(inputfile)
		root = tree.getroot()
	except ET.ParseError as e:
		print "Parse error({0}): {1}".format(e.errno, e.strerror)
		sys.exit(2)
	except IOError as e:
		print "IO error({0}): {1}".format(e.errno, e.strerror)
		sys.exit(2)
	except:
		print "Unexpected error:", sys.exc_info()[0]
		sys.exit(2)
	
	fo = open(outputfile, 'w+')
	if (args.noheaders != True):
		out = "ip" + ',' + "hostname" + ',' + "port" + ',' + "protocol" + ',' + "service" + ',' + "version" + ',' + 'warnings' + '\n'
		fo.write (out)
        
	for host in root.findall('host'):
		ip = host.find('address').get('addr')
		hostname = ""
		if host.find('hostnames') is not None:
			if host.find('hostnames').find('hostname') is not None:
				hostname = host.find('hostnames').find('hostname').get('name')

                warning = ""
                for table in host.iter('table'):
                    if table.get('key') == 'warnings':
                        ele = table.find('elem')
                        warning = ele.text


		for port in host.find('ports').findall('port'):
                        
			protocol = port.get('protocol')
			if protocol is None:
				protocol = ""
			portnum = port.get('portid')
			if portnum is None:
				portnum = ""
			service = ""
			if port.find('service') is not None:
				if port.find('service').get('name') is not None:
					service = port.find('service').get('name')
			product = ""
			version = ""
			versioning = ""
			extrainfo = ""
			if port.find('service') is not None:
				if port.find('service').get('product') is not None:
					product = port.find('service').get('product')
					versioning = product.replace(",", "")
				if port.find('service').get('version') is not None:
					version = port.find('service').get('version')
					versioning = versioning + ' (' + version + ')'
				if port.find('service').get('extrainfo') is not None:
					extrainfo = port.find('service').get('extrainfo')
					versioning = versioning + ' (' + extrainfo + ')'
                	out = ip + ',' + hostname + ',' + portnum + ',' + protocol + ',' + service + ',' + versioning + ',' + warning + '\n'
			fo.write (out)
	
	fo.close()
	
if __name__ == "__main__":
   main(sys.argv)
