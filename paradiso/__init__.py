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

def showtime(fname, fullscreen):
    fpath = os.path.abspath(fname)
    
    player = ['mplayer']
    if (fullscreen):
        player.append('-fs')
    player.extend(['-monitoraspect', '16:9', '-aspect', '16:9'])
    
    sys.stdout.write("Playing %s\r\n" % fpath)

    player.append('-really-quiet')

    #if re.search('(rar)$', fname):
#    if fname.endswith('rar'):
#        rar_parameters = ['unrar', 'p', '-inul', fpath]
#        player.append('-')
#       rar = subprocess.Popen(rar_parameters, stdout=subprocess.PIPE)
#        p = subprocess.Popen(player, stdin=rar.stdout)
#    else:
    player.append(fpath)
    p = subprocess.Popen(player)
    
    p.wait()
        
def main(options, args):
    key = 'playlist'
    if options.playlist:
        key = 'file_playlist'
    
    with playlists[key](options.write, options.path, *args) as playlist:
        for item in playlist:
            try:
                showtime(item, options.fullscreen)
                if options.delete and not playlist.pop():
                    raise ValueError("Something went wrong while poping the playlist")
            except KeyboardInterrupt:
                break

    return 0

def parse_cmdline():
    parser = optparse.OptionParser()
    parser.add_option("-d", "--delete", dest="delete", default=False, action="store_true")
    parser.add_option("-f", "--fullscreen", dest="fullscreen", default=False, action="store_true")
    parser.add_option("-F", "--filepath", dest="path", default=None, type="string")
    parser.add_option("-p", "--playlist", dest="playlist", default=False, action="store_true")
    parser.add_option("-w", "--write", dest="write", default=False, action="store_true")
    
    return parser.parse_args()