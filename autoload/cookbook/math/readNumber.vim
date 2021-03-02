vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

import Popup_notification from 'lg/popup.vim'

def cookbook#math#readNumber#main() #{{{1
    # Purpose:{{{
    #
    # Takes a number as input; outputs the english word standing for that number.
    # E.g.:
    #
    #     :call cookbook#math#read_number(123)
    #     one hundred twenty three~
    #}}}
    var n: number = 1234
    var msg: string = printf("in english, %d can be read as\n%s", n, ReadNumber(n))
    Popup_notification(msg, {time: 5000})
enddef

def ReadNumber(n: number): string
    var thousand: number
    var million: number
    var billion: number
    [thousand, million, billion] = range(3)
        ->map((_, v: number): number =>
                pow(10, (v + 1) * 3)->float2nr()
        )
    if n >= billion
        return ReadNumber(n / billion) .. ' billion ' .. ReadNumber(n % billion)
    elseif n >= million
        return ReadNumber(n / million) .. ' million ' .. ReadNumber(n % million)
    elseif n >= thousand
        return ReadNumber(n / thousand) .. ' thousand ' .. ReadNumber(n % thousand)
    elseif n >= 100
        return ReadNumber(n / 100) .. ' hundred ' .. ReadNumber(n % 100)
    # Why `20` and not `10`?{{{
    #
    # Because numbers between 11 and 19 get special names.
    # You don't say  "ten one", "ten two", "ten three",  but "eleven", "twelve",
    # "thirteen", ...
    #
    # See: https://english.stackexchange.com/q/7281/313834
        #}}}
    elseif n >= 20
        var num: string = ReadNumber(n % 10)
        # Why `TENS[n / 10]` instead of `ReadNumber(n / 10)`?{{{
        #
        # Because you don't say "two ten three" for 23, but "twenty three".
        # Also, notice how there is no word between the two expressions:
        #
        #     TENS[n / 10] .. ' ' .. ReadNumber(n % 10)
        #                  ^-------^
        #                   no word
        #
        # Previously, there was always a word (e.g. "hundred", "thousand", ...).
        # The difference in the code reflects this difference of word syntax.
        #}}}
        # Why the conditional operator?{{{
        #
        # Without, in the output for 20000, there would be a superfluous space:
        #
        #     twenty  thousand
        #           ^^
        #}}}
        return TENS[n / 10] .. (num == '' ? '' : ' ' .. num)
    else
        # Why the conditional operator?{{{
        #
        # You never say "zero" at the end, for a number divisible by 10^2, 10^3, 10^6, 10^9...
        # E.g., you don't say "two hundred zero" for 200, but just "two hundred".
        #}}}
        return (n != 0 ? NUMS[n] : '')
    endif
enddef

const NUMS: list<string> =<< trim END
    zero
    one
    two
    three
    four
    five
    six
    seven
    eight
    nine
    ten
    eleven
    twelve
    thirteen
    fourteen
    fifteen
    sixteen
    seventeen
    eighteen
    nineteen
END

const TENS: list<string> =<< trim END
    zero
    ten
    twenty
    thirty
    fourty
    fifty
    sixty
    seventy
    eighty
    ninety
END

