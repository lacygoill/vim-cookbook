if exists('g:autoloaded_cookbook#math')
    finish
endif
let g:autoloaded_cookbook#math = 1

fu cookbook#math#is_prime() abort "{{{1
    " Purpose: test whether a number is prime
    let n = 1223
    if s:is_prime(n)
        let msg = n..' is prime'
    else
        let msg = n..' is not prime'
    endif
    call cookbook#notify(msg)
endfu

fu s:is_prime(n) abort
    let n = a:n
    if type(n) != type(0) || n < 0
        return -1
    endif

    " 1, 2 and 3 are special cases; 2 and 3 are prime, 1 is not prime.
    if n == 2 || n == 3
        return 1
    " Why do you test whether `n` is divisible by 2 or 3?{{{
    "
    " All prime numbers follow the form `6k - 1` or `6k + 1`, *except* 2 and 3.
    " Indeed, any number can be written in one of the following form:
    "
    "    - 6k        divisible by 6    not prime
    "    - 6k + 1                      could be prime
    "    - 6k + 2    "            2    not prime (except for k = 0)
    "    - 6k + 3    "            3    not prime (except for k = 0)
    "    - 6k + 4    "            2    not prime
    "    - 6k + 5                      could be prime
    "
    " So, for a number to be prime, it has to follow the form `6k ± 1`.
    " Any other form would mean it's divisible by 2 or 3.
    "
    " So, if  `n` is  *not* a  prime, then its  prime factor  decomposition must
    " include a `6k ± 1` number or 2 or 3.
    "
    " Therefore, we have to test 2 and 3 manually.
    " Later we'll test all the `6k ± 1` numbers.
    "}}}
    elseif n == 1 || n % 2 == 0 || n % 3 == 0
        return 0
    endif

    " We'll begin testing if `n` is divisible by 5 (first `6k ± 1` number).
    let divisor = 5
    " `inc` is the increment we'll add to `divisor` at the end of each iteration of the while loop.{{{
    "
    " The next divisor to test is 7, so, initially, the increment needs to be 2:
    "     7 = 5 + 2
    "}}}
    let inc = 2
    let sqrt = sqrt(n)
    " We could also write: `while i * i <= n`{{{
    "
    " But then, each iteration of the loop would calculate `i*i`.
    " It's faster to just  calculate the square root of `n`  once and only once,
    " before the loop.
    "}}}
    " Why do you stop testing after `sqrt`?{{{
    "
    " Suppose that `n` is  not prime, and that you didn't  find any prime factor
    " lower than `√n`; it means that all of its prime factors are bigger than `√n`:
    "
    "     n = p₁ x p₂ x ...
    "         │    │
    "         │    └ bigger than `√n`
    "         └ bigger than `√n`
    "
    "     ⇒
    "
    "     n = m x ...
    "         │
    "         └ bigger than `√n x √n`; i.e. bigger than `n`
    "
    " This is impossible; the prime factor  decomposition of `n` can't contain a
    " number bigger than `n`.
    "}}}
    while divisor <= sqrt
        if n % divisor == 0 | return 0 | endif
        let divisor += inc
        " The `6k ± 1` numbers are:{{{
        "
        "     5, 7, 11, 13, 17, 19 ...
        "
        " To generate them, we begin with 5, then add 2, then add 4, then add 2,
        " then add 4 ...
        " In other words, we  have to increment `divisor` by 2 or  4, at the end
        " of each iteration of the loop.
        "
        " How to code that?
        " Here's one way; the sum of 2 consecutive increments will always be
        " 6 (2+4 or 4+2):
        "
        "     inc_current + inc_next = 6
        "
        " Therefore:
        "
        "     inc_next = 6 - inc_current
        "}}}
        let inc = 6 - inc
    endwhile

    return 1
endfu

fu cookbook#math#read_number() abort "{{{1
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
    call cookbook#notify(msg, {'time': 5000})
endfu

fu s:read_number(n) abort
    let n = a:n
    let [thousand, million, billion] = map(range(3), {_,v -> float2nr(pow(10, (v+1)*3))})
    if n >= billion
        return s:read_number(n/billion)..' billion '..s:read_number(n%billion)
    elseif n >= million
        return s:read_number(n/million)..' million '..s:read_number(n%million)
    elseif n >= thousand
        return s:read_number(n/thousand)..' thousand '..s:read_number(n%thousand)
    elseif n >= 100
        return s:read_number(n/100)..' hundred '..s:read_number(n%100)
    " Why `20` and not `10`?{{{
    "
    " Because numbers between 11 and 19 get special names.
    " You don't say  "ten one", "ten two", "ten three",  but "eleven", "twelve",
    " "thirteen", ...
    "
    " See: https://english.stackexchange.com/q/7281/313834
        "}}}
    elseif n >= 20
        let num = s:read_number(n%10)
        " Why `s:TENS[n/10]` instead of `s:read_number(n/10)`?{{{
        "
        " Because you don't say "two ten three" for 23, but "twenty three".
        " Also, notice how there is no word between the two expressions:
        "
        "     s:TENS[n/10]..' '..s:read_number(n%10)
        "                 ^^^^^^^
        "                 no word
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
        return s:TENS[n/10]..(num is# '' ? '' : ' '..num)
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

fu cookbook#math#transpose_table() abort "{{{1
    " Purpose: convert lists of identical size, forming a table, into the list of columns of the latter.{{{
    "
    " You can imagine the lists piled up, forming a table.
    " The function should return a single list of lists, whose items are the
    " columns of this table.
    " This is similar to what is called, in math, a transposition:
    " https://en.wikipedia.org/wiki/Transpose
    "
    " That is, reading  the lines in a  transposed table is the  same as reading
    " the columns in the original one.
    "}}}
    let lists = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    let msg = printf("the transposition of:\n    %s\nis:\n    %s", lists, call('s:transpose_table', lists))
    call cookbook#notify(msg, {'time': 5000})
endfu

fu s:transpose_table(...) abort
    " handle special case where only 1 list was received (instead of 2)
    if a:0 == 1
        return map(range(len(a:1)), {i -> [a:1[i]]})
    endif

    " Check that all the arguments are lists and have the same size.
    let size = len(a:1)
    for list in a:000
        if type(list) != type([]) || len(list) != size
            return -1
        endif
    endfor

    " Initialize a list of empty lists (whose number is `size`).{{{
    "
    " We can't use `repeat()`:
    "
    "     repeat([[]], size)
    "
    " ... doesn't work as expected.
    " So we create a list of numbers with the same size (`range(size)`),
    " and then converts each number into `[]`.
    "}}}
    let transposed = map(range(size), '[]')

    " First, iterate over lines (there're `a:0` lines), then over columns (there're `size` columns).{{{
    "
    " With these nested for loops, we can reach any cell in the table.
    " `a:000[i][j]` is the cell of coords `[i,j]`.
    "
    " Imagine the upper-left corner is the origin of a coordinate system,
    "
    "     x axis goes down  = lines
    "     y axis goes right = columns
    "
    " The cell of coords `[i, j]` must be added to a list of `transposed`. Which one?
    " Well, it's in the `j`-th column, so it must be added to the `j`-th list.
    "}}}
    for i in range(a:0)
        for j in range(size)
            call add(transposed[j], a:000[i][j])
        endfor
    endfor

    return transposed
endfu

