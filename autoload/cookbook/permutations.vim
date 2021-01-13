vim9 noclear

if exists('loaded') | finish | endif
var loaded = true

# Interface {{{1
def cookbook#permutations#main() #{{{2
    var l = ['a', 'b', 'c']
    var permutations = Permutations(l)
        ->mapnew((_, v) => join(v))->join("\n")
    var msg = printf("the permutations of %s are:\n\n%s", l, permutations)
    cookbook#notify(msg, {time: 5000})
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
    for sublistPermutation in Permutations(l[1 :])
    # iterate over the permutations of the original list
        for permutation in InsertItemAtAllPositions(l[0], sublistPermutation)
            ret += [permutation]
        endfor
    endfor
    return ret
enddef

def InsertItemAtAllPositions(item: string, l: list<string>): list<list<string>> #{{{2
    var ret: list<list<string>>
    # iterate over all the positions at which we can insert the item in the list
    for i in range(len(l) + 1)
        ret += [ (i == 0 ? [] : l[0 : i - 1]) + [item] + l[i : ] ]
    endfor
    return ret
enddef

