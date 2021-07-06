vim9script noclear

import Popup_notification from 'lg/popup.vim'

def cookbook#math#isPrime#main() #{{{1
    # Purpose: test whether a number is prime
    var n: number = 1'223
    var msg: string
    if IsPrime(n)
        msg = n .. ' is prime'
    else
        msg = n .. ' is not prime'
    endif
    Popup_notification(msg, {})
enddef

def IsPrime(n: number): bool
    if typename(n) != 'number' || n < 0
        return false
    endif

    # 1, 2 and 3 are special cases; 2 and 3 are prime, 1 is not prime.
    if n == 2 || n == 3
        return true
    # Why do you test whether `n` is divisible by 2 or 3?{{{
    #
    # All prime numbers follow the form `6k - 1` or `6k + 1`, *except* 2 and 3.
    # Indeed, any number can be written in one of the following form:
    #
    #    - 6k        divisible by 6    not prime
    #    - 6k + 1                      could be prime
    #    - 6k + 2    "            2    not prime (except for k = 0)
    #    - 6k + 3    "            3    not prime (except for k = 0)
    #    - 6k + 4    "            2    not prime
    #    - 6k + 5                      could be prime
    #
    # So, for a number to be prime, it has to follow the form `6k ± 1`.
    # Any other form would mean it's divisible by 2 or 3.
    #
    # So, if  `n` is  *not* a  prime, then its  prime factor  decomposition must
    # include a `6k ± 1` number or 2 or 3.
    #
    # Therefore, we have to test 2 and 3 manually.
    # Later we'll test all the `6k ± 1` numbers.
    #}}}
    elseif n == 1 || n % 2 == 0 || n % 3 == 0
        return false
    endif

    # We'll begin testing if `n` is divisible by 5 (first `6k ± 1` number).
    var divisor: number = 5
    # `inc` is the increment we'll add to `divisor` at the end of each iteration of the while loop.{{{
    #
    # The next divisor to test is 7, so, initially, the increment needs to be 2:
    #     7 = 5 + 2
    #}}}
    var inc: number = 2
    var sqrt: float = sqrt(n)
    # We could also write: `while i * i <= n`{{{
    #
    # But then, each iteration of the loop would calculate `i*i`.
    # It's faster to just  calculate the square root of `n`  once and only once,
    # before the loop.
    #}}}
    # Why do you stop testing after `sqrt`?{{{
    #
    # Suppose that `n` is  not prime, and that you didn't  find any prime factor
    # lower than `√n`; it means that all of its prime factors are bigger than `√n`:
    #
    #     n = p₁ x p₂ x ...
    #         │    │
    #         │    └ bigger than `√n`
    #         └ bigger than `√n`
    #
    #     ⇒
    #
    #     n = m x ...
    #         │
    #         └ bigger than `√n x √n`; i.e. bigger than `n`
    #
    # This is impossible; the prime factor  decomposition of `n` can't contain a
    # number bigger than `n`.
    #}}}
    while divisor <= sqrt
        if n % divisor == 0
            return false
        endif
        divisor += inc
        # The `6k ± 1` numbers are:{{{
        #
        #     5, 7, 11, 13, 17, 19 ...
        #
        # To generate them, we begin with 5, then add 2, then add 4, then add 2,
        # then add 4 ...
        # In other words, we  have to increment `divisor` by 2 or  4, at the end
        # of each iteration of the loop.
        #
        # How to code that?
        # Here's one way; the sum of 2 consecutive increments will always be
        # 6 (2 + 4 or 4 + 2):
        #
        #     inc_current + inc_next = 6
        #
        # Therefore:
        #
        #     inc_next = 6 - inc_current
        #}}}
        inc = 6 - inc
    endwhile

    return true
enddef

