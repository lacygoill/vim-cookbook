vim9 noclear

if exists('loaded') | finish | endif
var loaded = true

const OPTS: dict<any> = {
    width: 0.9,
    height: 0.6,
    xoffset: 0.5,
    yoffset: 0.5,
    highlight: 'WarningMsg',
    borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
    }

def cookbook#popup#terminal#main() #{{{1
    # set options
    var opts: dict<any> = {}
    [opts.line, opts.col, opts.minwidth, opts.minheight] = GetGeometry()
    extend(opts, {
        maxwidth: opts.minwidth,
        maxheight: opts.minheight,
        # Make sure empty cells are highlighted just like non-empty cells in Terminal-Normal mode.{{{
        # .
        # When  you're in  Terminal-Job  mode, everything  is highlighted  according
        # to  Vim's  internal   terminal  palette  (which  can   be  configured  via
        # `g:terminal_ansi_colors`).
        # .
        # When you're in Terminal-Normal mode:
        # .
        #    - the non-empty cells are still highlighted according to Vim's internal terminal palette
        #    - the empty cells are highlighted according the 'highlight' key, or `Pmenu` as a fallback
        # .
        # We want all cells to be highlighted in the exact same way; so we make sure
        # that empty cells are highlighted just like the non-empty ones.
        # .
        # ---
        # .
        # The same issue applies to empty  cells in the padding areas, regardless of
        # the mode you're in.
        # }}}
        highlight: 'Normal',
        border: [],
        borderchars: OPTS.borderchars,
        borderhighlight: [OPTS.highlight],
        padding: [0, 1, 0, 1],
        # get the lowest `zindex` possible to be able to see the popup;
        # if it's too low, it may be hidden by an existing popup,
        # and if it's too high, it may hide future popups
        zindex: GetZindex(),
        })

    # create terminal buffer
    # `term_finish: 'close'` is useful if you close the terminal by pressing `C-d` or running `$ exit`.{{{
    #
    # This is  not necessary when you  toggle off your custom  popup terminal by
    # pressing `C-g C-g`, but that's a special case.
    #}}}
    # `term_kill: 'hup'` may suppress `E947` when you try to quit Vim with `:q` or `:qa`.{{{
    #
    #     E947: Job still running in buffer "!/usr/local/bin/zsh"
    #
    # This is  only necessary for  a persistent terminal buffer  (e.g. togglable
    # popup terminal) whose job may run until we quit Vim; like this one:
    # https://gist.github.com/lacygoill/0bfef0a2e70ac7015aaee56a670c124b
    #}}}
    term_start(&shell, {hidden: v:true, term_finish: 'close', term_kill: 'hup'})
        # display it in popup window
        ->popup_create(opts)

    # Like for  all local options,  the local  value of `'termwinkey'`  has been
    # reset to its default value (empty string), which makes Vim use `C-w`.
    # Set the option  again, so that we  get the same experience  as in terminal
    # buffers in non-popup windows.
    set twk<

    FireTerminalEvents()
enddef

def GetGeometry(): list<number> #{{{1
    # `-4` and `-2` to take into account the border and the padding.{{{
    #
    # 2 lines are taken  by the top/bottom segments, and 4  columns are taken by
    # the right/left segments+paddings.
    #}}}
    var width: number = float2nr(&columns * OPTS.width) - 4
    var height: number = float2nr(&lines * OPTS.height) - 2

    var row: number = float2nr(OPTS.yoffset * (&lines - height))
    # `-1` so that the position is identical as the floating terminal created by our old Nvim recipe
    var col: number = float2nr(OPTS.xoffset * (&columns - width)) - 1

    return [row, col, width, height]
enddef

def GetZindex(): number #{{{1
    # get screen position of the cursor
    var screenpos: dict<number> = win_getid()->screenpos(line('.'), col('.'))
    # use it to get the id of the popup at the cursor, then the options of the latter
    var opts: dict<any> = popup_locate(screenpos.row, screenpos.col)->popup_getoptions()
    # return the `zindex` value of the popup at the cursor, plus one so that our
    # popup terminal barely wins
    return get(opts, 'zindex', 0) + 1
enddef

def FireTerminalEvents() #{{{1
    # Install our custom terminal settings.
    if exists('#TerminalWinOpen')
        do <nomodeline> TerminalWinOpen
    endif
    # Vim makes us enter Terminal-Job mode immediately.{{{
    #
    # And Vim doesn't support `TermEnter` (nor `TermLeave`).
    # Nevertheless, if  you emulate it  via `User`,  and you have  some settings
    # which are applied on `User TermEnter`, you want to fire it now.
    #}}}
    if exists('#User#TermEnter')
        do <nomodeline> User TermEnter
    endif
enddef

