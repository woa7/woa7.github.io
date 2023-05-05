#!/usr/bin/python

for mask in range(8, 30):
  bin = ('1'*mask) + ('0'*(32-mask))
  string = '.'.join([
    str(int(bin[0:8], 2)),
    str(int(bin[8:16], 2)),
    str(int(bin[16:24], 2)),
    str(int(bin[24:], 2))
  ])
  print 'iseq ${mask} %d && set mask %s ||' % (mask, string)
