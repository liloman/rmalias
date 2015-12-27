#!/usr/bin/env bats
#Based on original rmalias coreutil tests see:
# http://git.savannah.gnu.org/gitweb/?p=coreutils.git;a=tree;f=tests/rm

#WARNING!
#Be careful don't use ((, cause (( $status == pp )) && echo Really WRONG!
#the issue is that (( 0 == letters )) is always true ... :(


load test_helper

r=$BATS_TEST_DIRNAME/../rmalias

mkdir -p /tmp/batsdir-$USER
cd /tmp/batsdir-$USER

###########
#  BASIC  #
###########


@test "rmalias without arguments" {
run $r
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: missing operand" ]]
[[ ${lines[1]} = "Try 'rmalias --help' for more information." ]] 
}

@test "rmalias -b hints for invalid option" {
run $r -b
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: invalid option -- 'b'" ]]
[[ ${lines[1]} = "Try 'rmalias --help' for more information." ]] 
}

@test "rmalias -h  hints for --help" {
run $r -h
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: invalid option -- 'h'" ]]
[[ ${lines[1]} = "Try 'rmalias --help' for more information." ]]
}

@test "rmalias --version dir doesnt try delete dir " {
run $r --version dirnotfound
(( $status == 0 ))
}

@test "rmalias dirnotfound shows dir not found" {
run $r dirnotfound
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: failed to remove 'dirnotfound': No such file or directory" ]]
}

@test "rmalias -f dirnotfound shows nothing" {
run $r -f dirnotfound
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
}

@test "rmalias --force dirnotfound shows nothing" {
run $r --force dirnotfound
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
}


@test "rmalias with multiple notfounddirs shows dirs not found" {
run $r dirnotfound1 dirnotfound2
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: failed to remove 'dirnotfound1': No such file or directory" ]]
[[ ${lines[1]} = "rmalias: failed to remove 'dirnotfound2': No such file or directory" ]]
}

@test "rmalias on a not empty dir shows not a file" {
mkdir a
touch a/file
run $r a 
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove 'a': Is a directory" ]]
[[ -e a/ ]]
rm -rf a
}

@test "rmalias -r on a not empty dir shows nothing" {
mkdir a
touch a/file
run $r -r a 
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
[[ ! -e a/ ]]
}

@test "rmalias empty dir shows not a directory" {
mkdir empty
run $r empty 
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove 'empty': Is a directory" ]]
[[ -e empty/ ]]
rm -rf empty
}

@test "rmalias --force empty dir shows not a directory" {
mkdir empty
run $r --force empty 
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove 'empty': Is a directory" ]]
[[ -e empty/ ]]
rm -rf empty
}


@test "rmalias with relative path" {
touch filefound
run $r ../batsdir-$USER/filefound 
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
}

@test "rmalias with relatives path" {
touch dirfound{1,2}
run $r ../batsdir-$USER/dirfound*
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
}


# #############
# #  OPTIONS  #
# #############
#
#
@test "rmalias -d empty dir shows nothing" {
mkdir dirempty
run $r -d dirempty
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
[[ ! -e dirempty ]]
}

@test "rmalias -d not empty dir shows nothing" {
mkdir -p 1/2
run $r -d 1
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove '1': Directory not empty" ]]
[[ -e 1/2 ]]
rm -rf 1/
}

#
#
# #t-slash.sh of coreutils
# # make sure rmalias -p works on a directory specified with a trailing slash
# @test "rmalias -p dir/ works" {
# mkdir a
# $r -p a/
# }
# #
# @test "rmalias -p with not empty dirs fails" {
# mkdir -p a/b/c
# touch a/b/c/file
# run $r -p a/b/c
# rm -rf a/
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: failed to remove 'a/b/c': Directory not empty" ]]
# }
#
# @test "rmalias -p with not empty dirs fails until not empty found" {
# mkdir -p a/{b1,b2}/c
# touch a/{b1,b2}/file
# run $r -p a/{b1,b2}/c
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: failed to remove directory 'a/b1': Directory not empty" ]]
# [[ ${lines[1]} = "rmalias: failed to remove directory 'a/b2': Directory not empty" ]]
# [[ ! -d a/b1/c ]]
# [[ -e a/b1/file ]]
# [[ -e a/b2/file ]]
# rm -rf a/
# }
#
# @test "rmalias -p with 3 non empty dirs fails but remove them" {
# mkdir -p a/{b1,b2,b3}/c
# run $r -p a/*/c
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: failed to remove directory 'a': Directory not empty" ]]
# [[ ${lines[1]} = "rmalias: failed to remove directory 'a': Directory not empty" ]]
# [[ ${lines[2]} = "" ]]
# [[ ! -d a ]]
# }
#
# @test "rmalias -p with 5 non empty dirs fails but remove them finally" {
# mkdir -p a/{b1,b2,b3,b4,b5}/c
# run $r -p a/*/c
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: failed to remove directory 'a': Directory not empty" ]]
# [[ ${lines[1]} = "rmalias: failed to remove directory 'a': Directory not empty" ]]
# [[ ${lines[2]} = "rmalias: failed to remove directory 'a': Directory not empty" ]]
# [[ ${lines[3]} = "rmalias: failed to remove directory 'a': Directory not empty" ]]
# [[ ${lines[4]} = "" ]]
# [[ ! -d a ]]
# }
#
# #For unwritable directory 'd', 'rmalias -p would emit diagnostics but would not fail
# @test "rmalias with multiple empty dirs with no w permission on last remove them" {
# mkdir -p d/e/f
# chmod a-w d/e/f
# run $r d/e/f
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# [[ ! -d d/e/f ]]
# rm -rf d
# }
#
# #
# #fail-perm.sh of coreutils
# #For unwritable directory 'd', 'rmalias -p would emit diagnostics but would not fail
# @test "rmalias -p with multiple empty dirs with no permission fails but remove them" {
# mkdir -p d/e/f
# chmod a-w d
# run $r -p d/e/f
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: failed to remove directory 'd/e': Permission denied" ]]
# [[ ! -d d/e/f ]]
# [[ -d d/e ]]
# chmod a+w d
# rm -rf d
# }
#
# #fail-perm.sh of coreutils
# #For unwritable directory 'd', 'rmalias -p would emit diagnostics but would not fail
# @test "rmalias -p with multiple empty dirs with no permission fails but remove them v2" {
# mkdir -p d/e/f
# chmod a-w d
# run $r -p d d/e/f
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: failed to remove 'd': Directory not empty" ]]
# [[ ${lines[1]} = "rmalias: failed to remove directory 'd/e': Permission denied" ]]
# [[ ! -d d/e/f ]]
# [[ -d d/e ]]
# chmod a+w d
# rm -rf d
# }
#
# #ignore.sh of coreutils
# # make sure rmalias's --ignore-fail-on-non-empty option works
# @test "rmalias -p --ignore-fail-on-non-empty with multiple empty dirs remove them" {
# mkdir -p a/{b1,b2,b3}/c
# run $r -p --ignore-fail-on-non-empty a/{b1,b2}/c
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# [[ ! -d a/b2 ]]
# [[ -d a/b3/c ]]
# rm -rf a/
# }
#
# @test "rmalias -p --ignore-fail-on-non-empty with a dir not empty doesnt remove the dir" {
# mkdir -p a/b1
# run $r -p --ignore-fail-on-non-empty a/
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# [[ -d a/b1 ]]
# rm -rf a/
# }
#
#
# @test "rmalias -p --ignore-fail-on-non-empty with some dirs not empty doesnt remove the dir" {
# mkdir -p a/{b1,b2,b3}/c
# touch a/b2/c/file
# run $r -p --ignore-fail-on-non-empty a/*/c
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# [[ -e a/b2/c/file ]]
# rm -rf a/
# }
#
# #
# # #############
# # #  SPACES   #
# # #############
# #
#
# #ignore.sh of coreutils with spaces
# # make sure rmalias's --ignore-fail-on-non-empty option works
# @test "rmalias -p --ignore-fail-on-non-empty with spaced empty dirs remove them" {
# mkdir -p a/{b\ 1,b\ 2,b\ 3}/c
# run $r -p --ignore-fail-on-non-empty a/{b\ 1,b\ 2}/c
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# [[ ! -d a/b\ 2 ]]
# [[ -d a/b\ 3/c ]]
# rm -rf a/
# }
#
# #ignore.sh of coreutils with spaces and glob
# # make sure rmalias's --ignore-fail-on-non-empty option works
# @test "rmalias -p --ignore-fail-on-non-empty with spaced globbed empty dirs remove them" {
# mkdir -p a/{b\ 1,b\ 2,b\ 3}/c
# run $r -p --ignore-fail-on-non-empty a/*/c
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# [[ ! -d a/b\ 3/c ]]
# }
#
#
@test "Clean everything" {
run chmod -f a+w *
rm -rf *
}
#
