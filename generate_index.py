import xml.dom.minidom

print 'CREATE TABLE IF NOT EXISTS searchIndex(id INTEGER PRIMARY KEY);'
print 'DROP TABLE searchIndex;'
print 'CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);'
print 'CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);'

def putSQL(name, type, path):
  print "INSERT OR IGNORE INTO searchIndex('name', 'type', 'path') VALUES ('%s', '%s', '%s');" % (name, type, path)

for i in range(1,380):
  path = "xep-%04d.html" % i
  type = 'Extension'
  name = "xep%d" % i
  putSQL(name, type, path)
  name = "xep%04d" % i
  putSQL(name, type, path)
  dom = xml.dom.minidom.parse("xeps/xep-%04d.xml" % i)
  header = dom.getElementsByTagName('header')
  title = header[0].getElementsByTagName('title')[0]
  for child in title.childNodes:
    if child.nodeType == child.TEXT_NODE:
      title = child.data
  if title != "N/A":
    putSQL(title, type, path)
  shortname = header[0].getElementsByTagName('shortname')
  if len(shortname) > 0:
    for child in shortname[0].childNodes:
      if child.nodeType == child.TEXT_NODE:
        shortname = child.data
    if shortname != 'NOT_YET_ASSIGNED':
      putSQL(shortname, type, path)
