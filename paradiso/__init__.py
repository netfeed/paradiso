# -*- coding: utf-8 -*-
# Copyright (c) 2009 Victor Bergöö
# This program is made available under the terms of the MIT License.

import sys
import os
import re
import optparse
import subprocess

from paradiso.playlist import Playlist, FilePlaylist

playlists = {
    'playlist' : Playlist,
    'file_playlist' : FilePlaylist
}

def showtime(fname, fullscreen, device=None):
    fpath = os.path.abspath(fname)
    
    player = ['mplayer']
    if (fullscreen):
        player.append('-fs')
    player.extend(['-monitoraspect', '16:9', '-aspect', '16:9'])
    player.append('-really-quiet')

    if device:
        if sys.platform == 'darwin':
            player.extend(['-vo', 'corevideo:device_id=%d' % device])
        else:
            raise ValueError("I'm sorry, i can't handle display options for %s" % sys.platform)

    sys.stdout.write("Playing %s\n" % fpath)

    #if re.search('(rar)$', fname):
#    if fname.endswith('rar'):
#        rar_parameters = ['unrar', 'p', '-inul', fpath]
#        player.append('-')
#       rar = subprocess.Popen(rar_parameters, stdout=subprocess.PIPE)
#        p = subprocess.Popen(player, stdin=rar.stdout)
#    else:
    player.append(fpath)
    p = subprocess.Popen(player)
    
    p.communicate()
        
def main(options, args):
    key = 'playlist'
    if options.playlist:
        key = 'file_playlist'
    
    counter = 1
    with playlists[key](options.write, options.path, *args) as playlist:
        for item in playlist:
            try:
                showtime(item, options.fullscreen, options.device)
                if options.delete and playlist.rpop() is None:
                    raise ValueError("Something went wrong while poping the playlist")
            except KeyboardInterrupt:
                break
            
            if options.amount and counter >= options.amount:
                break
            counter += 1

    return 0

def parse_cmdline():
    parser = optparse.OptionParser()
    parser.add_option("-d", "--delete", dest="delete", default=False, action="store_true")
    parser.add_option("-f", "--fullscreen", dest="fullscreen", default=False, action="store_true")
    parser.add_option("-F", "--filepath", dest="path", default=None, type="string")
    parser.add_option("-p", "--playlist", dest="playlist", default=False, action="store_true")
    parser.add_option("-w", "--write", dest="write", default=False, action="store_true")
    parser.add_option("-D", "--device", dest="device", default=None, type="int")
    parser.add_option("-n", "--amount", dest="amount", default=None, type="int")
    
    return parser.parse_args()