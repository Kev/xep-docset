import os
import os.path
import re
import sqlite3
import sys
import xml.dom.minidom

if len(sys.argv) < 2:
    print >>sys.stderr, "Usage: %s database" % (sys.argv[0],)
    sys.exit(1)

verbose = True
database_file = sys.argv[1]
index = []
xepre = re.compile('xep-0*([1-9][0-9]*).xml')

for root, dirs, files in os.walk('xeps'):
    for fn in files:
        match = xepre.match(fn)
        if not match:
            continue

        i = int(match.group(1))
        path = 'xep-%04d.html' % (i,)
        type = 'Extension'
        name = "xep%d" % i
        index += ((name, type, path),)
        name = "xep%04d" % i
        index += ((name, type, path),)
        dom = xml.dom.minidom.parse(os.path.join(root, fn))
        header = dom.getElementsByTagName('header')
        title = header[0].getElementsByTagName('title')[0]
        for child in title.childNodes:
            if child.nodeType == child.TEXT_NODE:
                title = child.data
        if title != "N/A":
            index += ((title, type, path),)
        shortname = header[0].getElementsByTagName('shortname')
        if len(shortname) > 0:
            for child in shortname[0].childNodes:
                if child.nodeType == child.TEXT_NODE:
                    shortname = child.data
            if shortname != 'NOT_YET_ASSIGNED':
                index += ((shortname, type, path),)

with sqlite3.connect(database_file) as conn:
    cursor = conn.cursor()

    cursor.execute('DROP TABLE IF EXISTS searchIndex;')
    cursor.execute('CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);')
    cursor.execute('CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);')

    cursor.executemany("INSERT OR IGNORE INTO searchIndex('name', 'type', 'path') VALUES (?, ?, ?)", index)

if verbose:
    print "Generated %s for %d XEPs, %d items in total" % (database_file, len(set(item[2] for item in index)), len(index),)
