"""Helper methods used in UltiSnips snippets."""

import string, vim

NORMAL  = 0x1
DOXYGEN = 0x2
SPHINX  = 0x3
GOOGLE  = 0x4
NUMPY   = 0x5
JEDI    = 0x6

SINGLE_QUOTES = "'"
DOUBLE_QUOTES = '"'

class Arg(object):
    def __init__(self, arg):
        self.arg = arg
        name_and_type = arg.split('=')[0].split(':')
        self.name = name_and_type[0].strip()
        self.type = name_and_type[1].strip() if len(name_and_type) == 2 else None

    def __str__(self):
        return self.name

    def __unicode__(self):
        return self.name

    def is_kwarg(self):
        return '=' in self.arg

    def is_vararg(self):
        return '*' in self.name

def get_args(arglist):
    args = [Arg(arg) for arg in arglist.split(',') if arg]
    args = [arg for arg in args if arg.name != 'self']

    return args

def get_quoting_style(snip):
    style = snip.opt("g:ultisnips_python_quoting_style", "double")
    if style == 'single':
        return SINGLE_QUOTES
    return DOUBLE_QUOTES

def triple_quotes(snip):
    style = snip.opt("g:ultisnips_python_triple_quoting_style")
    if not style:
        return get_quoting_style(snip) * 3
    return (SINGLE_QUOTES if style == 'single' else DOUBLE_QUOTES) * 3

def triple_quotes_handle_trailing(snip, quoting_style):
    """
    Generate triple quoted strings and handle any trailing quote char,
    which might be there from some autoclose/autopair plugin,
    i.e. when expanding ``"|"``.
    """
    if not snip.c:
        # Do this only once, otherwise the following error would happen:
        # RuntimeError: The snippets content did not converge: …
        _, col = vim.current.window.cursor
        line = vim.current.line

        # Handle already existing quote chars after the trigger.
        _ret = quoting_style * 3
        while True:
            try:
                nextc = line[col]
            except IndexError:
                break
            if nextc == quoting_style and len(_ret):
                _ret = _ret[1:]
                col = col+1
            else:
                break
        snip.rv = _ret
    else:
        snip.rv = snip.c

def get_style(snip):
    style = snip.opt("g:ultisnips_python_style", "normal")

    if    style == "doxygen": return DOXYGEN
    elif  style == "sphinx": return SPHINX
    elif  style == "google": return GOOGLE
    elif  style == "numpy": return NUMPY
    elif  style == "jedi": return JEDI
    else: return NORMAL

def format_arg(arg, style):
    if style == DOXYGEN:
        return "@param %s TODO" % arg
    elif style == SPHINX:
        return ":param %s: TODO" % arg
    elif style == NORMAL:
        return ":%s: TODO" % arg
    elif style == GOOGLE:
        return "%s (TODO): TODO" % arg
    elif style == JEDI:
        return ":type %s: TODO" % arg
    elif style == NUMPY:
        return "%s : TODO" % arg

def format_return(style):
    if style == DOXYGEN:
        return "@return: TODO"
    elif style in (NORMAL, SPHINX, JEDI):
        return ":returns: TODO"
    elif style == GOOGLE:
        return "Returns: TODO"

def write_docstring_args(args, snip):
    if not args:
        snip.rv += ' {0}'.format(triple_quotes(snip))
        return

    snip.rv += '\n' + snip.mkline('', indent='')

    style = get_style(snip)

    if style == GOOGLE:
        write_google_docstring_args(args, snip)
    elif style == NUMPY:
        write_numpy_docstring_args(args, snip)
    else:
        for arg in args:
            snip += format_arg(arg, style)

def write_google_docstring_args(args, snip):
    kwargs = [arg for arg in args if arg.is_kwarg()]
    args = [arg for arg in args if not arg.is_kwarg()]

    if args:
        snip += "Args:"
        snip.shift()
        for arg in args:
            snip += format_arg(arg, GOOGLE)
        snip.unshift()
        snip.rv += '\n' + snip.mkline('', indent='')

    if kwargs:
        snip += "Kwargs:"
        snip.shift()
        for kwarg in kwargs:
            snip += format_arg(kwarg, GOOGLE)
        snip.unshift()
        snip.rv += '\n' + snip.mkline('', indent='')

def write_numpy_docstring_args(args, snip):
    if args:
        snip += "Parameters"
        snip += "----------"

    kwargs = [arg for arg in args if arg.is_kwarg()]
    args = [arg for arg in args if not arg.is_kwarg()]

    if args:
        for arg in args:
            snip += format_arg(arg, NUMPY)
    if kwargs:
        for kwarg in kwargs:
            snip += format_arg(kwarg, NUMPY) + ', optional'
    snip.rv += '\n' + snip.mkline('', indent='')

def write_init_body(args, parents, snip):
    parents = [p.strip() for p in parents.split(",")]
    parents = [p for p in parents if p != 'object']

    for p in parents:
        snip += p + ".__init__(self)"

    if parents:
        snip.rv += '\n' + snip.mkline('', indent='')

    for arg in filter(lambda arg: not arg.is_vararg(), args):
        snip += "self._%s = %s" % (arg, arg)

def write_slots_args(args, snip):
    quote = get_quoting_style(snip)
    arg_format = quote + '_%s' + quote
    args = [arg_format % arg for arg in args]
    snip += '__slots__ = (%s,)' % ', '.join(args)

def write_function_docstring(t, snip):
    """
    Writes a function docstring with the current style.

    :param t: The values of the placeholders
    :param snip: UltiSnips.TextObjects.SnippetUtil object instance
    """
    snip.rv = ""
    snip >> 1

    args = get_args(t[2])
    if args:
        write_docstring_args(args, snip)

    style = get_style(snip)

    if style == NUMPY:
        snip += 'Returns'
        snip += '-------'
        snip += 'TODO'
    else:
        snip += format_return(style)
    snip.rv += '\n' + snip.mkline('', indent='')
    snip += triple_quotes(snip)

def get_dir_and_file_name(snip):
    return os.getcwd().split(os.sep)[-1] + '.' + snip.basename
