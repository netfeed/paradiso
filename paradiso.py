#!/usr/bin/env python

import sys
import os

import paradiso

if __name__ == '__main__':
    if (len(sys.argv) == 1):
        sys.stderr.write("{script}: see '{script} -h' for usage\r\n".format(script=os.path.basename(sys.argv[0])))
        sys.exit(1) 
    
    sys.exit(paradiso.main(*paradiso.parse_cmdline()))
