import os
import os.path
import re
import sqlite3
import sys
import xml.dom.minidom

def getChildText(root, element_name, default=None, first_only=True):
    result = []

    for node in root.getElementsByTagName(element_name):
        for child in node.childNodes:
            if child.nodeType == child.TEXT_NODE:
                result.append(child.data)

        if first_only:
            break

    return ''.join(result) if len(result) else default


if len(sys.argv) < 2:
    print >>sys.stderr, "Usage: %s database" % (sys.argv[0],)
    sys.exit(1)

verbose = True
database_file = sys.argv[1]
index = []
xepre = re.compile('xep-0*([1-9][0-9]*).xml')

for root, dirs, files in os.walk('xeps'):
    for filename in files:
        match = xepre.match(filename)
        if not match:
            continue

        i = int(match.group(1))
        path = 'xep-%04d.html' % (i,)
        index_type = 'Extension'

        index.append(("xep%d" % (i,), index_type, path))
        index.append(("xep%04d" % (i,), index_type, path))

        dom = xml.dom.minidom.parse(os.path.join(root, filename))
        header = dom.getElementsByTagName('header')

        if len(header) == 0:
            print >>sys.stderr, "Warning: %s does not have a header" % (filename,)
            continue

        title = getChildText(header[0], 'title', default='N/A')
        if title != "N/A":
            index.append((title, index_type, path))

        shortname = getChildText(header[0], 'shortname', default='NOT_YET_ASSIGNED')
        if shortname != 'NOT_YET_ASSIGNED':
            index.append((shortname, index_type, path))


with sqlite3.connect(database_file) as conn:
    cursor = conn.cursor()

    cursor.execute("DROP TABLE IF EXISTS searchIndex;")
    cursor.execute("CREATE TABLE searchIndex('id' INTEGER PRIMARY KEY, 'name' TEXT, 'type' TEXT, 'path' TEXT);")
    cursor.execute("CREATE UNIQUE INDEX anchor ON searchIndex ('name', 'type', 'path');")

    cursor.executemany("INSERT OR IGNORE INTO searchIndex('name', 'type', 'path') VALUES (?, ?, ?)", index)

if verbose:
    print "Generated %s for %d XEPs, %d items in total" % (database_file, len(set(item[2] for item in index)), len(index),)
