#!/usr/bin/python

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
		out = "ip" + ',' + "hostname" + ',' + 'LMNR' + 'NBT,' + 'SMB' + ',' + 'TLSv1.1' + ',' + "port" + ',' + "port state" + ',' + 'os_name' + '\n'
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
    
                vulners = ""
                ssl_enum_ciphers = ""
                  
                # ssl3 = "No"
                # tls11 = "No"
                # tls10 = "No"
                # for script in host.iter('script'):
                #     if script.get('id') == 'vulners':
                #         vulners = script.find('elem').text
                #
                #     if script.get('id') == 'ssl-enum-ciphers':
                #         ciphers = script.get('id')
                #         tables = script.get('output')
                #         if 'SSLv3' in tables:
                #             ssl3 = 'Yes'
                #         else:
                #             ssl3 = 'No'
                #         if 'TLSv1.0' in tables:
                #             tls10 = 'Yes'
                #         else:
                #             tls10 = 'No'
                #         if 'TLSv1.1' in tables:
                #             tls11 = 'Yes'
                #         else:
                #             tls11 = 'No'




                        
                
                for match in host.iter('osmatch'):
                    acc = match.get('accuracy')
                    os_name = match.get('name')
                    line = match.get('line')

                 
                #print('-'*90 + '\n{0}'.format(ip) + '\n' + vulners + '\n' + ssl_enum_ciphers)

		for port in host.find('ports').findall('port'):
                        ssl3 = "No"
                        tls10 = "No"
                        tls11 = "No"
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

                        if port.find('state') is not None:
                                if port.find('state').get('state') is not None:
                                    port_state = port.find('state').get('state')

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
                        
                        if port.find('script') is not None:
                                
                                for script in port.findall('script'):
                                        if script.get('id') == 'ssl-enum-ciphers':
                                            out = script.get('output')
                                            if 'SSLv3' in out:
                                                ssl3 = 'Yes'
                                            else:
                                                ssl3 = 'No'
                                            if 'TLSv1.0' in out:
                                                tls10 = 'Yes'
                                            else:
                                                tls10 = 'No'
                                            if 'TLSv1.1' in out:
                                                tls11 = 'Yes'
                                            else:
                                                tls11 = 'No'

                	out = ip + ',' + hostname + ',' + ssl3 + ',' + tls10 + ',' + tls11 + ',' + portnum + ',' + port_state + ',' + os_name + '\n'
			fo.write (out)
	
	fo.close()
	
if __name__ == "__main__":
   main(sys.argv)
