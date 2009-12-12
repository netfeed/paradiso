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
        
        self._index = 0

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
            create_playlist(self, self.path)

    def __iter__(self):
        self._index = 0
        tmp = list(self.items)
        for idx in range(len(tmp)):
            yield tmp[idx]
            self._index += 1

    def pop(self):
        self.items.pop(self._index)
        self._index -= 1
        
        return True

class FilePlaylist(object):
    def __init__(self, write=False, path=None, *args):
        self.items = {}
        self.write = write

        self._fpaths = args
        self._current_file = None
        self._current_item = None

    def __exit__(self, type, value, traceback):
        if type is ValueError:
            import traceback
            print traceback.format_exc()

        if not self.write:
            return

        for fpath in self.items.iterkeys():
            if len(self.items[fpath]) == 0:
                os.remove(fpath)
            
            with open(fpath, 'w') as f:
                for item in self.items[fpath]:
                    f.write('%s\r\n' % item)

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
                self._current_item = item
                yield item

    def pop(self):
        if self._current_file is None or self._current_item is None:
            return False

        try:
            self.items[self._current_file].remove(self._current_item)
        except ValueError, e:
            return False

        return True