#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 2009 Victor Bergöö
# This program is made available under the terms of the MIT License.

import sys
import os

from paradiso.playlist import Playlist, create_playlist

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print "paradiso-playlist <playlist> <files|dirs>"
        sys.exit(1)
    
    append = False
    if os.path.exists(sys.argv[1]):
        append = True
    
    playlist = Playlist(True, sys.argv[1], *sys.argv[2:])
    create_playlist(playlist, sys.argv[1], append)
