import os

def create_playlist(playlist, fpath, append=False):
    mode = 'a' if append else 'w'
        
    with open(fpath, mode) as f:
        for item in playlist:
            f.write("%s\r\n" % item)

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
        if self.path is not None and self.write:
            create_playlist(self.items, self.path)

    def __iter__(self):
        for item in list(self.items):
            yield item

    def rpop(self, index=0):
        self.items.pop(index)
        return True

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

        for fpath in self.items.iterkeys():
            if len(self.items[fpath]) == 0:
                os.remove(fpath)
            
            create_playlist(self.items[fpath], fpath)

    def __enter__(self):
        for fpath in self._fpaths:
            with open(fpath, 'r') as f:
                for line in f.readlines():
                    line = line.strip("\r\n")
                    if not os.path.exists(line):
                        continue

                    if fpath not in self.items:
                        self.items[fpath] = []
                    self.items[fpath].append(line)
        
        return self

    def __iter__(self):
        for key in self._fpaths:
            self._current_file = key
            for item in list(self.items[key]):
                yield item

    def rpop(self, index=0):
        if self._current_file is None:
            return False

        try:
            self.items[self._current_file].pop(index)
        except ValueError, e:
            return False

        return True