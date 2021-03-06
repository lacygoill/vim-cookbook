vim9script noclear

import Popup_notification from 'lg/popup.vim'

# Interface {{{1
def cookbook#permutations#main() #{{{2
    var l: list<string> = ['a', 'b', 'c']
    var permutations: string = Permutations(l)
        ->mapnew((_, v: list<string>): string => join(v))
        ->join("\n")
    var msg: string = printf("the permutations of %s are:\n\n%s", l, permutations)
    Popup_notification(msg, {time: 5'000})
enddef
#}}}1
# Core {{{1
def Permutations(l: list<string>): list<list<string>> #{{{2
# https://stackoverflow.com/a/17391851/9780968
    if len(l) == 0
        return [[]]
    endif
    var ret: list<list<string>>
    # iterate over the permutations of the sublist which excludes the first item
    for sublistPermutation: list<string> in Permutations(l[1 :])
    # iterate over the permutations of the original list
        for permutation: list<string> in InsertItemAtAllPositions(l[0], sublistPermutation)
            ret += [permutation]
        endfor
    endfor
    return ret
enddef

def InsertItemAtAllPositions( #{{{2
    item: string,
    l: list<string>
): list<list<string>>

    var ret: list<list<string>>
    # iterate over all the positions at which we can insert the item in the list
    for i: number in range(len(l) + 1)
        ret += [ (i == 0 ? [] : l[0 : i - 1]) + [item] + l[i : ] ]
    endfor
    return ret
enddef

