"""Helper methods used in UltiSnips snippets."""

import string, vim

def complete(tab, opts):
    """
    Get options that start with tab.

    :param tab: query string
    :param opts: list that needs to be completed

    :return: a string that start with tab
    """
    msg = "({0})"
    if tab:
        opts = [m[len(tab):] for m in opts if m.startswith(tab)]
    if len(opts) == 1:
        return opts[0]

    if not len(opts):
        msg = "{0}"
    return msg.format("|".join(opts))

def _parse_comments(s):
    """
    Parses vim's comments option to extract comment format.
    """
    i = iter(s.split(","))

    rv = []
    try:
        while True:
            # get the flags and text of a comment part
            flags, text = next(i).split(':', 1)

            if len(flags) == 0:
                rv.append(('OTHER', text, text, text, ""))
            # parse 3-part comment, but ignore those with O flag
            elif 's' in flags and 'O' not in flags:
                ctriple = ["TRIPLE"]
                indent = ""

                if flags[-1] in string.digits:
                    indent = " " * int(flags[-1])
                ctriple.append(text)

                flags, text = next(i).split(':', 1)
                assert flags[0] == 'm'
                ctriple.append(text)

                flags, text = next(i).split(':', 1)
                assert flags[0] == 'e'
                ctriple.append(text)
                ctriple.append(indent)

                rv.append(ctriple)
            elif 'b' in flags:
                if len(text) == 1:
                    rv.insert(0, ("SINGLE_CHAR", text, text, text, ""))
    except StopIteration:
        return rv

def get_comment_format():
    """
    Returns a 4-element tuple (first_line, middle_lines, end_line, indent)
    representing the comment format for the current file.

    It first looks at the 'commentstring', if that ends with %s, it uses that.
    Otherwise it parses '&comments' and prefers single character comment
    markers if there are any.
    """
    commentstring = vim.eval("&commentstring")
    if commentstring.endswith("%s"):
        c = commentstring[:-2]
        return (c, c, c, "")
    comments = _parse_comments(vim.eval("&comments"))
    for c in comments:
        if c[0] == "SINGLE_CHAR":
            return c[1:]
    return comments[0][1:]


def make_box(twidth, bwidth=None):
    b, m, e, i = (s.strip() for s in get_comment_format())
    bwidth_inner = bwidth - 3 - max(len(b), len(i + e)) if bwidth else twidth + 2
    sline = b + m + bwidth_inner * m[0] + 2 * m[0]
    eline = i + m + bwidth_inner * m[0] + 2 * m[0] + e
    # centered box text with single comment wall thickness
    #nspaces = (bwidth_inner - twidth) // 2
    #mlines = i + m + " " + " " * nspaces
    #mlinee = " " + " "*(bwidth_inner - twidth - nspaces) + m
    #bline = i + m + bwidth_inner * " " + "  " + m
    # left aligned box text with double comment wall thickness
    if bwidth:
        mlines = i + m[0] * 2 + "  "
        mlinee = " " + " "*(bwidth_inner - twidth - 3) + m[0] * 2
    else:
        mlines = i + m + "  "
        mlinee = " " + " "*(bwidth_inner - twidth - 1) + m
    bline = i + m[0] * 2 + (bwidth_inner - 2) * " " + "  " + m[0] * 2
    # start line, middle line start, middle line end, end line, blank line
    return sline, mlines, mlinee, eline, bline

def foldmarker():
    """
    Return a tuple of (open fold marker, close fold marker)
    """
    return vim.eval("&foldmarker").split(",")

def create_table(snip):
    # retrieving single line from current string and treat it like tabstops count
    placeholders_string = snip.buffer[snip.line].strip()[2:].split("x",1)
    rows_amount = int(placeholders_string[0])
    columns_amount = int(placeholders_string[1])

    # erase current line
    snip.buffer[snip.line] = ''

    # create anonymous snippet with expected content and number of tabstops
    anon_snippet_title = ' | '.join(['$' + str(col) for col in range(1,columns_amount+1)]) + "\n"
    anon_snippet_delimiter = ':-|' * (columns_amount-1) + ":-\n"
    anon_snippet_body = ""
    for row in range(1,rows_amount+1):
        anon_snippet_body += ' | '.join(['$' + str(row*columns_amount+col) for col in range(1,columns_amount+1)]) + "\n"
    anon_snippet_table = anon_snippet_title + anon_snippet_delimiter + anon_snippet_body

    # expand anonymous snippet
    snip.expand_anon(anon_snippet_table)

def enter_replace_mode(snip, tstop):
    """
    Enter replace mode (<S-r>) at defined tabstop.

    Call before a snippet with post_jump hook:

        post_jump "enter_replace_mode(snip, 0)"

    :param snip: snippet object
    :param tstop: tab stop to enter replace mode at

    :return: null
    """
    if snip.tabstop == tstop: vim.command('call timer_start(0, {-> feedkeys(\"\eR\", \"in\")})')
