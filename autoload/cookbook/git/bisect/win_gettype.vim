try
    eval win_gettype()
    " if Vim supports  `win_gettype()` we want it to exit  with a non-zero error
    " code, so that  `git(1)` knows that this version exhibits  the new behavior
    " we're trying to bisect
    cq!
catch
    qa!
endtry
