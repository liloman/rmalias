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

@test "rmalias -d not empty dir shows not an empty dir" {
mkdir -p 1/2
run $r -d 1
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove '1': Directory not empty" ]]
[[ -e 1/2 ]]
rm -rf 1/
}

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
#fail-perm.sh of rmdir coreutils
#For unwritable directory 'd', 'rmalias -p would emit diagnostics but would not fail
# @test "rmalias -r with multiple empty dirs with no permission fails but remove them v2" {
# mkdir -p d/e/f
# chmod a-w d
# run $r -r d d/e/f
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: failed to remove 'd': Directory not empty" ]]
# [[ ${lines[1]} = "rmalias: failed to remove directory 'd/e': Permission denied" ]]
# [[ ! -d d/e/f ]]
# [[ -d d/e ]]
# chmod a+w d
# rm -rf d
# }


# #############
# #  SPACES   #
# #############


#ignore.sh of rmdir coreutils with spaces
@test "rmalias --recursive with spaced empty dirs remove them" {
mkdir -p a/{b\ 1,b\ 2}/c
run $r --recursive a/
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
[[ ! -d a ]]
rm -rf a/
}


#ignore.sh of rmdir coreutils with spaces and glob
@test "rmalias -R with spaced globbed empty dirs remove them until first" {
mkdir -p a/{b\ 1,b\ 2,b\ 3}/c
run $r -R a/*
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
[[ ! -d a/b\ 3/c ]]
[[ -d a ]]
rm -rf a/
}



###########################################################################
#                        Coreutils rm tests                               #
#  http://git.savannah.gnu.org/gitweb/?p=coreutils.git;a=tree;f=tests/rm  #
###########################################################################


#cycle.sh of rm coreutils
@test "rmalias cycle.sh" {
mkdir -p a/b
touch a/b/file
chmod u-w a/b
run $r -rf a a 
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove 'a/b/file': Permission denied" ]]
[[ ${lines[1]} = "rmalias: cannot remove 'a/b/file': Permission denied" ]]
[[ -d a ]]
chmod u+w a/b
rm -rf a/
}
















@test "Clean everything" {
touch file-to-not-fail-test-on-empty-dir
chmod -Rf a+w *
rm -rf *
}
#
