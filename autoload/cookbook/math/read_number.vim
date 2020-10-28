fu cookbook#math#read_number#main() abort "{{{1
    " Purpose:{{{
    "
    " Takes a number as input; outputs the english word standing for that number.
    " E.g.:
    "
    "     :call cookbook#math#read_number(123)
    "     one hundred twenty three~
    "}}}
    let n = 1234
    let msg = printf("in english, %d can be read as\n%s", n, s:read_number(n))
    call cookbook#notify(msg, #{time: 5000})
endfu

fu s:read_number(n) abort
    let n = a:n
    let [thousand, million, billion] = range(3)->map({_, v -> pow(10, (v + 1) * 3)->float2nr()})
    if n >= billion
        return s:read_number(n/billion) .. ' billion ' .. s:read_number(n % billion)
    elseif n >= million
        return s:read_number(n/million) .. ' million ' .. s:read_number(n % million)
    elseif n >= thousand
        return s:read_number(n/thousand) .. ' thousand ' .. s:read_number(n % thousand)
    elseif n >= 100
        return s:read_number(n/100) .. ' hundred ' .. s:read_number(n % 100)
    " Why `20` and not `10`?{{{
    "
    " Because numbers between 11 and 19 get special names.
    " You don't say  "ten one", "ten two", "ten three",  but "eleven", "twelve",
    " "thirteen", ...
    "
    " See: https://english.stackexchange.com/q/7281/313834
        "}}}
    elseif n >= 20
        let num = s:read_number(n % 10)
        " Why `s:TENS[n/10]` instead of `s:read_number(n/10)`?{{{
        "
        " Because you don't say "two ten three" for 23, but "twenty three".
        " Also, notice how there is no word between the two expressions:
        "
        "     s:TENS[n/10] .. ' ' .. s:read_number(n % 10)
        "                  ^-------^
        "                   no word
        "
        " Previously, there was always a word (e.g. "hundred", "thousand", ...).
        " The difference in the code reflects this difference of word syntax.
        "}}}
        " Why the conditional operator?{{{
        "
        " Without, in the output for 20000, there would be a superfluous space:
        "
        "     twenty  thousand
        "           ^^
        "}}}
        return s:TENS[n/10] .. (num == '' ? '' : ' ' .. num)
    else
        " Why the conditional operator?{{{
        "
        " You never say "zero" at the end, for a number divisible by 10^2, 10^3, 10^6, 10^9...
        " E.g., you don't say "two hundred zero" for 200, but just "two hundred".
        "}}}
        return (n ? s:NUMS[n] : '')
    endif
endfu
const s:NUMS =<< trim END
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

const s:TENS =<< trim END
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

