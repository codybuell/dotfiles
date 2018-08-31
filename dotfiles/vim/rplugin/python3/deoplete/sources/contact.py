import re

from .base import Base
from subprocess import PIPE, Popen

class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)

        self.__pattern = re.compile(r'[A-Z][A-z]*$')
        self.__binary = self.__find_lbdbq_binary()
        self.__candidates = None

        self.filetypes = []
        self.mark = '[@]'
        self.matchers = ['matcher_length', 'matcher_full_fuzzy']
        self.name = 'contact'
        self.sorters = ['sorter_smart']
        self.max_candidates = 0
        self.limit = 1000000

    def gather_candidates(self, context):
        result = self.__pattern.search(context['input'])
        if result is not None:
            if not self.__candidates:
                self.__cache()
            return self.__candidates

    def get_complete_position(self, context):
        match = self.__pattern.search(context['input'])
        return match.start() if match is not None else -1

    def on_event(self, context):
        self.__cache()

    def __force_decode(self, string, codecs=['ISO-8859-1', 'UTF8', 'ASCII', 'CP1252']):
        for i in codecs:
            try:
                return string.decode(i)
            except UnicodeDecodeError:
                pass

    def __cache(self):
        self.__candidates = []
        data = self.__lbdbq('.')
        if data:
            for line in data:
                try:
                    address, name, source = line.strip().split('\t')
                    if name:
                        completion = name
                    self.__candidates.append({'word': completion, 'kind': address})
                except:
                    pass

    def __find_lbdbq_binary(self):
        return self.vim.call('exepath', 'lbdbq')

    def __lbdbq(self, query):
        if not self.__binary:
            return None
        command = [self.__binary, query]
        try:
            process = Popen(command, stderr = PIPE, stdout = PIPE)
            out, err = process.communicate()
            if not process.returncode:
                # lines = out.decode('ISO-8859-1').split('\n')
                lines = self.__force_decode(out).split('\n')
                if len(lines) > 1:
                    lines.pop(0)
                    return lines
        except:
            pass
