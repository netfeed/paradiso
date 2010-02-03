#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 2009 Victor Bergöö
# This program is made available under the terms of the MIT License.

import sys
import os
import optparse

from paradiso.playlist import Playlist, read_playlist_file, create_playlist

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print "paradiso-playlist [-a] <playlist> <files|dirs>"
        sys.exit(1)
    
    parser = optparse.OptionParser()
    parser.add_option("-a", "--append", dest="append", default=False, action="store_true")
    options, args = parser.parse_args()
    
    if os.path.exists(args[0]) and not options.append:
        print "%s already exists, use -a if you want to add files to it" % args[0]
    
    items = []
    if options.append:
        items = read_playlist_file(args[0])
    items.extend(args[1:])
    
    playlist = Playlist(True, args[0], *items)
    create_playlist(playlist, args[0], options.append)
