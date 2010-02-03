# -*- coding: utf-8 -*-
# Copyright (c) 2009 Victor Bergöö
# This program is made available under the terms of the MIT License.

import os

def create_playlist(playlist, fpath, append=False):
    mode = 'a' if append else 'w'
        
    with open(fpath, mode) as f:
        for item in playlist:
            f.write("%s\r\n" % item)

def read_playlist_file(fpath):
    items = []
    with open(fpath, 'r') as f:
        for line in f.readlines():
            items.append(line.strip("\r\n"))
    return items

class Playlist(object):
    def __init__(self, write=False, path=None, *args):
        self.items = []
        self.write = write
        self.path = path
        
        for item in args:
            path = os.path.abspath(item)
            if os.path.isdir(path):
                for dirpath, dirnames, filenames in os.walk(path, topdown=True):
                    for file in filenames:
                        self.items.append(os.path.join(dirpath, file))
            else:
                self.items.append(path)
        
    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        if self.path is None:
            return
        
        if not self.write:
            return
        
        if os.path.exists(self.path) and len(self.items) == 0:
            os.remove(self.path)
            return
        
        create_playlist(self.items, self.path)

    def __iter__(self):
        for item in list(self.items):
            yield item
            
    def __len__(self):
        return len(self.items)

    def rpop(self, index=0):
        if len(self.items) == 0:
            return None
        
        return self.items.pop(index)

class FilePlaylist(object):
    def __init__(self, write=False, path=None, *args):
        self.items = {}
        self.write = write

        self._fpaths = args
        self._current_file = None

    def __exit__(self, type, value, traceback):
        if type is ValueError:
            import traceback
            print traceback.format_exc()

        if not self.write:
            return

        for fpath in self.items:
            self.items[fpath].__exit__(type, value, traceback)

    def __enter__(self):
        for fpath in self._fpaths:
            items = read_playlist_file(fpath)
            self.items[fpath] = Playlist(self.write, fpath, *items)
        
        return self

    def __iter__(self):
        for key in self._fpaths:
            self._current_file = key
            for item in self.items[key]:
                yield item

    def rpop(self, index=0):
        if self._current_file is None:
            return None

        if len(self.items[self._current_file]) == 0:
            return None

        return self.items[self._current_file].rpop(index)
