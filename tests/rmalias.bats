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
[[ ${lines[0]} = "rmalias: cannot remove 'dirnotfound': No such file or directory" ]]
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
[[ ${lines[0]} = "rmalias: cannot remove 'dirnotfound1': No such file or directory" ]]
[[ ${lines[1]} = "rmalias: cannot remove 'dirnotfound2': No such file or directory" ]]
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

#d-1.sh of rm coreutils
@test "rmalias d-1.sh" {
mkdir a
> b
run $r --verbose --dir a b
(( $status == 0 ))
#Coreutils shows directory but fedora add shows directory:
[[ ${lines[0]} = "removed directory: 'a'" ]]
[[ ${lines[1]} = "removed 'b'" ]]
[[ ! -e a ]]
[[ ! -e b ]]
}

#d-2.sh of rm coreutils
# Ensure that 'rm -d dir' (i.e., without --recursive) gives a reasonable
# diagnostic when failing.
@test "rmalias d-2.sh" {
mkdir d
touch d/a
run $r -d d 2 
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove 'd': Directory not empty" ]]
[[ ${lines[1]} = "rmalias: cannot remove '2': No such file or directory" ]]
[[ -e d ]]
[[ ! -e 2 ]]
rm -rf d
}


#d-3.sh of rm coreutils
# Ensure that 'rm -d -i dir' (i.e., without --recursive) gives a prompt and
 # then deletes the directory if it is empty
@test "rmalias d-3.sh" {
skip "Needs -i option "
}

#dangling-symlink.sh of rm coreutils
# rm should not prompt before removing a dangling symlink.
# Likewise for a non-dangling symlink.
# But for fileutils-4.1.9, it would do the former and
# for fileutils-4.1.10 the latter.
@test "rmalias dangling-symlink.sh" {
skip " needs undocumented ---presume-input-tty option...!"
ln -s no-file dangle
ln -s / symlink

# Terminate any background processes
cleanup_() { kill $pid 2>/dev/null && wait $pid; }

$r ---presume-input-tty dangle symlink & pid=$!
# The buggy rm (fileutils-4.1.9) would hang here, waiting for input.

# Wait up to 3.1s for rm to remove the files
check_files_removed() {
  local delay="$1"
  local present=0
  ls -l dangle > /dev/null 2>&1 && present=1
  ls -l symlink > /dev/null 2>&1 && present=1
  test $present = 1 && { sleep $delay; return 1; } || :
}
retry_delay_ check_files_removed .1 5 
cleanup_

(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove 'd': Directory not empty" ]]
[[ ${lines[1]} = "rmalias: cannot remove '2': No such file or directory" ]]

}


#deep.sh of rm coreutils
# Test rm with a deep hierarchy
@test "rmalias deep.sh" {
skip "Works but needs some strace  ..."
umask 022

k20=/k/k/k/k/k/k/k/k/k/k/k/k/k/k/k/k/k/k/k/k
k200=$k20$k20$k20$k20$k20$k20$k20$k20$k20$k20

# Be careful not to exceed max file name length (usu 512?).
# Doing so wouldn't affect GNU mkdir or GNU rm, but any tool that
# operates on the full pathname (like 'test') would choke.
k_deep=$k200$k200

t=t
# Create a directory in $t with lots of 'k' components.
deep=$t$k_deep
mkdir -p $deep 
# Make sure the deep dir was created.
[[ -d $deep ]]
run $r -r $t 
# Make sure all of $t was deleted.
[[ ! -d $t ]]
(( $status == 0 ))
}


#deep2.sh of rm coreutils
# Ensure rm -r DIR does not prompt for very long full relative names in DIR.
@test "rmalias deep2.sh" {
skip " needs undocumented ---presume-input-tty option...!"
}


#dir-no-w.sh of rm coreutils
# Ensure rm -r DIR does not prompt for very long full relative names in DIR.
@test "rmalias dir-no-w.sh" {
skip " needs undocumented ---presume-input-tty option...!"
# rm (without -r) must give a diagnostic for any directory.
#deep2.se It must not prompt, even if that directory is unwritable.
mkdir --mode=0500 unwritable-dir
$r ---presume-input-tty unwritable-dir
(( $status == 1 ))
# When run by a non-privileged user we get this:
# rm: cannot remove directory 'unwritable-dir': Is a directory
# When run by root we get this:
# rm: cannot remove 'unwritable-dir': Is a directory
[[ ${lines[0]} = "rmalias: cannot remove 'unwritable-dir': Is a directory" ]]
chmod u+w unwritable-dir
rm -rf unwritable-dir
}

#dir-nonrecur.sh of rm coreutils
# Ensure that 'rm dir' (i.e., without --recursive) gives a reasonable
# diagnostic when failing.
@test "rmalias dir-nonrecur.sh" {
mkdir d
run $r d 
(( $status == 1 ))
# When run by a non-privileged user we get this:
# rm: cannot remove directory 'unwritable-dir': Is a directory
# When run by root we get this:
# rm: cannot remove 'unwritable-dir': Is a directory
[[ ${lines[0]} = "rmalias: cannot remove 'd': Is a directory" ]]
rm -rf d
}

#dot-rel.sh of rm coreutils
# Use rm -r to remove two non-empty dot-relative directories.
# This would have failed between 2004-10-18 and 2004-10-21.
@test "rmalias dot-rel.sh" {
mkdir a b
touch a/f b/f
run $r -r a b
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
}


#empty-inacc.sh of rm coreutils
# Ensure that rm -rf removes an empty-and-inaccessible directory.
@test "rmalias empty-inacc.sh" {
skip "needs revision"
mkdir -m0 inacc
#Also exercise the different code path that's taken for a directory
# that is empty (hence removable) and unreadable.
mkdir -m a-r -p a/unreadable

# This would fail for e.g., coreutils-5.93.
$r -rf inacc 
[[ -d inacc ]]

# This would fail for e.g., coreutils-5.97.
run $r -rf a 
[[ -d a ]]
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
}


#empty-name.sh of rm coreutils
# Make sure that rm -r '' fails
@test "rmalias empty-name.sh" {
run $r -r ''
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove '': No such file or directory" ]]
}


#ext3-perf.sh of rm coreutils
# ensure that "rm -rf DIR-with-many-entries" is not O(N^2)
@test "rmalias ext3-perf.sh" {
skip "needs strace or maybe impossible ..."
run $r -r ''
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove '': No such file or directory" ]]
}

#f-1.sh of rm coreutils
# Test "rm -f" with a nonexistent file.
@test "rmalias f-1.sh" {
mkdir -p d
run $r -f d/no-such-file
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
rm -rf d
}


#fail-2eperm.sh of rm coreutils
# Like fail-eperm, but the failure must be for a file encountered
# while trying to remove the containing directory with the sticky bit set.
@test "rmalias fail-2eperm.sh" {
# The containing directory must be owned by the user who eventually runs rm.
chown $USER .
mkdir a
chmod 1777 a
touch a/b
run $r -rf a
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
rm -rf a
}


#fail-eacces.sh of rm coreutils
# Ensure that rm -rf unremovable-non-dir gives a diagnostic.
# Test both a regular file and a symlink -- it makes a difference to rm.
# With the symlink, rm from coreutils-6.9 would fail with a misleading
# ELOOP diagnostic.
@test "rmalias fail-eaccess.sh" {
mkdir d
touch d/f 
ln -s f d/slink 
chmod a-w d    

mkdir e 
ln -s f e/slink
chmod a-w e   

run $r -rf d/f 
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove 'd/f': Permission denied" ]]

# This used to fail with ELOOP.
run $r -rf e 
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove 'e/slink': Permission denied" ]]
chmod -Rf a+w *
rm -rf *
}

@test "Clean everything" {
touch file-to-not-fail-test-on-empty-dir
chmod -Rf a+w *
rm -rf *
}
#
