#!/usr/bin/env python

import json
import subprocess
import sys

try:
    docset = {
        "name": "XMPP Extension Protocols",
        "version": "/" + sys.argv[3],
        "archive": "XMPP_Extension_Protocols.tgz",
        "author": {
            "name": "Kevin Smith",
            "link": "https://github.com/Kev/xep-docset",
        }
    }
    with open(sys.argv[2], "w") as f:
        json.dump(docset, f)
except:
    print "Failed to generate", sys.argv[2], "from", sys.argv[1]
    os.exit(1)
