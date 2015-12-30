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

@test "Prepare everything" {
touch file-to-not-fail-test-on-empty-dir
chmod -Rf 0700 *
rm -rf *
}

@test "rmalias without arguments" {
run $r
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: missing operand" ]]
[[ ${lines[1]} = "Try 'rmalias --help' for more information." ]] 
}
#
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
#
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
#
#
# @test "rmalias with multiple notfounddirs shows dirs not found" {
# run $r dirnotfound1 dirnotfound2
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove 'dirnotfound1': No such file or directory" ]]
# [[ ${lines[1]} = "rmalias: cannot remove 'dirnotfound2': No such file or directory" ]]
# }
#
# @test "rmalias on a not empty dir shows not a file" {
# mkdir a
# touch a/file
# run $r a 
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove 'a': Is a directory" ]]
# [[ -e a/ ]]
# rm -rf a
# }
#
# @test "rmalias -r on a not empty dir shows nothing" {
# mkdir a
# touch a/file
# run $r -r a 
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# [[ ! -e a/ ]]
# }
#
# @test "rmalias empty dir shows not a directory" {
# mkdir empty
# run $r empty 
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove 'empty': Is a directory" ]]
# [[ -e empty/ ]]
# rm -rf empty
# }
#
# @test "rmalias --force empty dir shows not a directory" {
# mkdir empty
# run $r --force empty 
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove 'empty': Is a directory" ]]
# [[ -e empty/ ]]
# rm -rf empty
# }
#
#
# @test "rmalias with relative path" {
# touch filefound
# run $r ../batsdir-$USER/filefound 
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# }
#
# @test "rmalias with relatives path" {
# touch dirfound{1,2}
# run $r ../batsdir-$USER/dirfound*
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# }
#
#
# # #############
# # #  OPTIONS  #
# # #############
# #
# #
# @test "rmalias -d empty dir shows nothing" {
# mkdir dirempty
# run $r -d dirempty
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# [[ ! -e dirempty ]]
# }
#
# @test "rmalias -d not empty dir shows not an empty dir" {
# mkdir -p 1/2
# run $r -d 1
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove '1': Directory not empty" ]]
# [[ -e 1/2 ]]
# rm -rf 1/
# }
#
# # #
# # #fail-perm.sh of coreutils
# # #For unwritable directory 'd', 'rmalias -p would emit diagnostics but would not fail
# # @test "rmalias -p with multiple empty dirs with no permission fails but remove them" {
# # mkdir -p d/e/f
# # chmod a-w d
# # run $r -p d/e/f
# # (( $status == 1 ))
# # [[ ${lines[0]} = "rmalias: failed to remove directory 'd/e': Permission denied" ]]
# # [[ ! -d d/e/f ]]
# # [[ -d d/e ]]
# # chmod a+w d
# # rm -rf d
# # }
# #
# #fail-perm.sh of rmdir coreutils
# #For unwritable directory 'd', 'rmalias -p would emit diagnostics but would not fail
# # @test "rmalias -r with multiple empty dirs with no permission fails but remove them v2" {
# # mkdir -p d/e/f
# # chmod a-w d
# # run $r -r d d/e/f
# # (( $status == 1 ))
# # [[ ${lines[0]} = "rmalias: failed to remove 'd': Directory not empty" ]]
# # [[ ${lines[1]} = "rmalias: failed to remove directory 'd/e': Permission denied" ]]
# # [[ ! -d d/e/f ]]
# # [[ -d d/e ]]
# # chmod a+w d
# # rm -rf d
# # }
#
#
# # #############
# # #  SPACES   #
# # #############
#
#
# #ignore.sh of rmdir coreutils with spaces
# mtest "rmdiralias --recursive with spaced empty dirs remove them" {
# mkdir -p a/{b\ 1,b\ 2}/c
# run $r --recursive a/
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# [[ ! -d a ]]
# rm -rf a/
# }
#
#
# #ignore.sh of rmdir coreutils with spaces and glob
# @test "rmalias -R with spaced globbed empty dirs remove them until first" {
# mkdir -p a/{b\ 1,b\ 2,b\ 3}/c
# run $r -R a/*
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# [[ ! -d a/b\ 3/c ]]
# [[ -d a ]]
# rm -rf a/
# }
#
#
#
# ###########################################################################
# #                        Coreutils rm tests                               #
# #  http://git.savannah.gnu.org/gitweb/?p=coreutils.git;a=tree;f=tests/rm  #
# ###########################################################################
#
#
# #cycle.sh of rm coreutils
# @test "rmalias cycle.sh" {
# mkdir -p a/b
# touch a/b/file
# chmod u-w a/b
# run $r -rf a a 
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove 'a/b/file': Permission denied" ]]
# [[ ${lines[1]} = "rmalias: cannot remove 'a/b/file': Permission denied" ]]
# [[ -d a ]]
# chmod u+w a/b
# rm -rf a/
# }
#
# #d-1.sh of rm coreutils
# @test "rmalias d-1.sh" {
# mkdir a
# > b
# run $r --verbose --dir a b
# (( $status == 0 ))
# #Coreutils shows directory but fedora add shows directory:
# [[ ${lines[0]} = "removed directory: 'a'" ]]
# [[ ${lines[1]} = "removed 'b'" ]]
# [[ ! -e a ]]
# [[ ! -e b ]]
# }
#
# #d-2.sh of rm coreutils
# # Ensure that 'rm -d dir' (i.e., without --recursive) gives a reasonable
# # diagnostic when failing.
# @test "rmalias d-2.sh" {
# mkdir d
# touch d/a
# run $r -d d 2 
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove 'd': Directory not empty" ]]
# [[ ${lines[1]} = "rmalias: cannot remove '2': No such file or directory" ]]
# [[ -e d ]]
# [[ ! -e 2 ]]
# rm -rf d
# }
#
#
# #d-3.sh of rm coreutils
# # Ensure that 'rm -d -i dir' (i.e., without --recursive) gives a prompt and
#  # then deletes the directory if it is empty
# @test "rmalias d-3.sh" {
# skip "Needs -i option "
# }
#
# #dangling-symlink.sh of rm coreutils
# # rm should not prompt before removing a dangling symlink.
# # Likewise for a non-dangling symlink.
# # But for fileutils-4.1.9, it would do the former and
# # for fileutils-4.1.10 the latter.
# @test "rmalias dangling-symlink.sh" {
# skip " needs undocumented ---presume-input-tty option...!"
# ln -s no-file dangle
# ln -s / symlink
#
# # Terminate any background processes
# cleanup_() { kill $pid 2>/dev/null && wait $pid; }
#
# $r ---presume-input-tty dangle symlink & pid=$!
# # The buggy rm (fileutils-4.1.9) would hang here, waiting for input.
#
# # Wait up to 3.1s for rm to remove the files
# check_files_removed() {
#   local delay="$1"
#   local present=0
#   ls -l dangle > /dev/null 2>&1 && present=1
#   ls -l symlink > /dev/null 2>&1 && present=1
#   test $present = 1 && { sleep $delay; return 1; } || :
# }
# retry_delay_ check_files_removed .1 5 
# cleanup_
#
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove 'd': Directory not empty" ]]
# [[ ${lines[1]} = "rmalias: cannot remove '2': No such file or directory" ]]
#
# }
#
#
# #deep.sh of rm coreutils
# # Test rm with a deep hierarchy
# @test "rmalias deep.sh" {
# skip "Works but needs some strace  ..."
# umask 022
#
# k20=/k/k/k/k/k/k/k/k/k/k/k/k/k/k/k/k/k/k/k/k
# k200=$k20$k20$k20$k20$k20$k20$k20$k20$k20$k20
#
# # Be careful not to exceed max file name length (usu 512?).
# # Doing so wouldn't affect GNU mkdir or GNU rm, but any tool that
# # operates on the full pathname (like 'test') would choke.
# k_deep=$k200$k200
#
# t=t
# # Create a directory in $t with lots of 'k' components.
# deep=$t$k_deep
# mkdir -p $deep 
# # Make sure the deep dir was created.
# [[ -d $deep ]]
# run $r -r $t 
# # Make sure all of $t was deleted.
# [[ ! -d $t ]]
# (( $status == 0 ))
# }
#
#
# #deep2.sh of rm coreutils
# # Ensure rm -r DIR does not prompt for very long full relative names in DIR.
# @test "rmalias deep2.sh" {
# skip " needs undocumented ---presume-input-tty option...!"
# }
#
#
# #dir-no-w.sh of rm coreutils
# # Ensure rm -r DIR does not prompt for very long full relative names in DIR.
# @test "rmalias dir-no-w.sh" {
# skip " needs undocumented ---presume-input-tty option...!"
# # rm (without -r) must give a diagnostic for any directory.
# #deep2.se It must not prompt, even if that directory is unwritable.
# mkdir --mode=0500 unwritable-dir
# $r ---presume-input-tty unwritable-dir
# (( $status == 1 ))
# # When run by a non-privileged user we get this:
# # rm: cannot remove directory 'unwritable-dir': Is a directory
# # When run by root we get this:
# # rm: cannot remove 'unwritable-dir': Is a directory
# [[ ${lines[0]} = "rmalias: cannot remove 'unwritable-dir': Is a directory" ]]
# chmod u+w unwritable-dir
# rm -rf unwritable-dir
# }
#
# #dir-nonrecur.sh of rm coreutils
# # Ensure that 'rm dir' (i.e., without --recursive) gives a reasonable
# # diagnostic when failing.
# @test "rmalias dir-nonrecur.sh" {
# mkdir d
# run $r d 
# (( $status == 1 ))
# # When run by a non-privileged user we get this:
# # rm: cannot remove directory 'unwritable-dir': Is a directory
# # When run by root we get this:
# # rm: cannot remove 'unwritable-dir': Is a directory
# [[ ${lines[0]} = "rmalias: cannot remove 'd': Is a directory" ]]
# rm -rf d
# }
#
# #dot-rel.sh of rm coreutils
# # Use rm -r to remove two non-empty dot-relative directories.
# # This would have failed between 2004-10-18 and 2004-10-21.
# @test "rmalias dot-rel.sh" {
# mkdir a b
# touch a/f b/f
# run $r -r a b
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# }
#
#
# #empty-inacc.sh of rm coreutils
# # Ensure that rm -rf removes an empty-and-inaccessible directory.
# @test "rmalias empty-inacc.sh" {
# skip "needs revision"
# mkdir -m0 inacc
# #Also exercise the different code path that's taken for a directory
# # that is empty (hence removable) and unreadable.
# mkdir -m a-r -p a/unreadable
#
# # This would fail for e.g., coreutils-5.93.
# $r -rf inacc 
# [[ -d inacc ]]
#
# # This would fail for e.g., coreutils-5.97.
# run $r -rf a 
# [[ -d a ]]
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# }
#
#
# #empty-name.sh of rm coreutils
# # Make sure that rm -r '' fails
# @test "rmalias empty-name.sh" {
# run $r -r ''
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove '': No such file or directory" ]]
# }
#
#
# #ext3-perf.sh of rm coreutils
# # ensure that "rm -rf DIR-with-many-entries" is not O(N^2)
# @test "rmalias ext3-perf.sh" {
# skip "needs strace or maybe impossible ..."
# run $r -r ''
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove '': No such file or directory" ]]
# }
#
# #f-1.sh of rm coreutils
# # Test "rm -f" with a nonexistent file.
# @test "rmalias f-1.sh" {
# mkdir -p d
# run $r -f d/no-such-file
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# rm -rf d
# }
#
#
# #fail-2eperm.sh of rm coreutils
# # Like fail-eperm, but the failure must be for a file encountered
# # while trying to remove the containing directory with the sticky bit set.
# @test "rmalias fail-2eperm.sh" {
# skip "Needs root?"
# # The containing directory must be owned by the user who eventually runs rm.
# chown $USER .
# mkdir a
# chmod 1777 a
# touch a/b
# run $r -rf a
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# rm -rf a
# }
#
#
# #fail-eacces.sh of rm coreutils
# # Ensure that rm -rf unremovable-non-dir gives a diagnostic.
# # Test both a regular file and a symlink -- it makes a difference to rm.
# # With the symlink, rm from coreutils-6.9 would fail with a misleading
# # ELOOP diagnostic.
# @test "rmalias fail-eaccess.sh" {
# mkdir d
# touch d/f 
# ln -s f d/slink 
# chmod a-w d    
#
# run $r -rf d/f 
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove 'd/f': Permission denied" ]]
#
# mkdir e 
# ln -s f e/slink
# chmod a-w e   
#
# # This used to fail with ELOOP.
# run $r -rf e 
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove 'e/slink': Permission denied" ]]
# chmod -Rf a+w *
# rm -rf *
# }
#
#
# #fail-eperm.sh of rm coreutils
# # Ensure that rm gives the expected diagnostic when failing to remove a file
# # owned by some other user in a directory with the sticky bit set.
# @test "rmalias fail-eperm.sh" {
# skip "Needs perl.. "
# }
#
#
# #hash.sh of rm coreutils
# # Exercise a bug that was fixed in 4.0s.
# # Before then, rm would fail occasionally, sometimes via
# # a failed assertion, others with a seg fault.
# @test "rmalias hash.sh" {
# skip "Takes to long... needs profiling"
# # Create a hierarchy with 3*26 leaf directories, each at depth 153.
# # echo "$0: creating 78 trees, each of depth 153; this will take a while..." >&2
# y=$(seq 1 150|tr -sc '\n' y|tr '\n' /)
# for i in 1 2 3; do
#   for j in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
#     mkdir -p t/$i/$j/$y 
#   done
# done
#
# run $r -r t 
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# }
#
# #i-1.sh of rm coreutils
# # Test rm -i
# @test "rmalias i-1.sh" {
# skip "Needs -i option  "
# }
#
# #i-never.sh of rm coreutils
# # Ensure that rm --interactive=never works does not prompt, even for
# # an unwritable file.
# @test "rmalias i-never.sh" {
# skip "Needs -i option  "
# }
#
# #i-no-r.sh of rm coreutils
# # Since the rewrite for fileutils-4.1.9, 'rm -i DIR' would mistakenly
# # recurse into directory DIR.  rm -i (without -r) must fail in that case.
# # Fixed in coreutils-4.5.2.
# @test "rmalias i-no-r.sh" {
# skip "Needs -i option  "
# }
#
#
# #ignorable.sh of rm coreutils
# # Ensure that rm -f exits successfully
# @test "rmalias ignorable.sh" {
# touch existing-non-dir
# # With coreutils-6.3, this would exit nonzero.  It should not.
# # Example from Andreas Schwab.
# run $r -f existing-non-dir/f 
# (( $status == 0 ))
# [[ ${lines[0]} = "" ]]
# }
#
# #inaccessible of rm coreutils
# # Ensure that rm works even when run from a directory
# # for which the user has no access at all.
# @test "rmalias inaccessible.sh" {
# skip "not possible in bash?"
# p=$(pwd)
# mkdir abs1 abs2 no-access 
# cd no-access; 
# chmod 0 . && run $r -r "$p/abs1" rel "$p/abs2"
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove 'rel': Permission denied" ]]
# [[ ! -d "$p/abs1" ]]
# [[ ! -d "$p/abs2" ]]
# }
#
#
# #interactive-always.sh of rm coreutils
# # Test the --interactive[=WHEN] changes added to coreutils 6.0
# @test "rmalias interactive-always.sh" {
# skip "Needs -i option  "
# }
#
# #ir-1 of rm coreutils
# # Test rm ir
# @test "rmalias ir-1.sh" {
# skip "Needs -i option  "
# }
#
# #isatty of rm coreutils
# # Make sure 'chown 0 f; rm f' prompts before removing f.
# @test "rmalias isatty.sh" {
# skip "Needs ask to remove write-protected file "
# # Terminate any background processes
# cleanup_() { kill $pid 2>/dev/null && wait $pid; }
# touch f
# chmod 0 f
# rm f & pid=$!
#
# # Wait a second, to give a buggy rm (as in fileutils-4.0.40)
# # enough time to remove the file.
# sleep 1
#
# # The file must still exist.
# [[ -f f ]]
#
# cleanup_
#
# #rm: remove write-protected regular empty file 'f'? x
# # (( $status == 1 ))
# # [[ ${lines[0]} = "rmalias: cannot remove 'rel': Permission denied" ]]
# }
#
#
# #many-dir-entries-vs-OOM of rm coreutils
# # In coreutils-8.12, rm,du,chmod, etc. would use too much memory
# # when processing a directory with many entries (as in > 100,000).
# @test "rmalias many-dir-entries-vs-OOM.sh" {
# skip "Needs profiling this MADNESS !!!!??? :O "
# }
#
#
# #no-give-up of rm coreutils
# # With rm from coreutils-5.2.1 and earlier, 'rm -r' would mistakenly
# # give up too early under some conditions.
# @test "rmalias no-give-up.sh" {
# skip "Needs root"
# mkdir d
# touch d/f
# chown -R $USER d
#
# # Ensure that non-root can access files in root-owned ".".
# chmod go=x .
#
#
# # This must fail, since '.' is not writable by $NON_ROOT_USERNAME.
# chroot --skip-chdir --user=$USER / env PATH="$PATH" rm -rf 
#
# # d must remain.
# [[ -d d ]] 
#
# # f must have been removed.
# [[ ! -f d/f ]] 
#
# }
#
#
# #one-file-system of rm coreutils
# # Demonstrate rm's new --one-file-system option.
# @test "rmalias one-file-system.sh" {
# skip "Needs --one-file-system option"
# }
#
# #one-file-system2 of rm coreutils
# # Verify --one-file-system does delete within a file system
# @test "rmalias one-file-system2.sh" {
# skip "Needs --one-file-system option"
# }
#
#
# #rm1 of rm coreutils
# # Test "rm -r --verbose".
# @test "rmalias rm1.sh" {
# mkdir a a/a 
# > b
#
# run $r --verbose -r a b 
#
# (( $status == 0 ))
# [[ ${lines[0]} = "removed directory: 'a/a'" ]]
# [[ ${lines[1]} = "removed directory: 'a'" ]]
# [[ ${lines[2]} = "removed 'b'" ]]
#
# [[ ! -d a ]]
# [[ ! -d a/a ]]
#
# }
#
#
# #rm2 of rm coreutils
# # exercise another small part of remove.c
# @test "rmalias rm2.sh" {
# mkdir -p a/0 
# mkdir -p a/1/2 b/3 
# mkdir a/2 a/3 
# chmod u-x a/1 b
#
# # Exercise two separate code paths -- though both result
# # in the same sort of diagnostic.
# # Both of these should fail.
# run $r -rf a b 
# (( $status == 1 ))
# # Different output from tests... ¿?
# [[ ${lines[0]} = "rmalias: cannot remove 'a/1/2': Permission denied" ]]
# [[ ${lines[1]} = "rmalias: cannot remove 'b/3': Permission denied" ]]
#
# [[ ! -d a/0 ]]
# [[ -d a/1 ]]
# [[ ! -d a/2 ]]
# [[ ! -d a/3 ]]
#
# chmod u+x b a/1
# [[ -d b/3 ]]
# rm -rf *
# }
#
#
# #rm3 of rm coreutils
# # exercise another small part of remove.c
# @test "rmalias rm3.sh" {
# skip "Needs -i option  "
# }
#
#
# #rm4 of rm coreutils
# # ensure that 'rm dir' fails without --recursive
# @test "rmalias rm4.sh" {
# mkdir dir 
# # This should fail.
# run $r dir 
# (( $status == 1 ))
# [[ -d dir ]]
# rm -rf *
# }
#
# #rm5 of rm coreutils
# # a basic test of rm -ri
# @test "rmalias rm5.sh" {
# skip "Needs -i option  "
# } 
#
#
#
# #unread2 of rm coreutils
# # exercise one small part of remove.c
# @test "rmalias unread2.sh" {
# skip "wip"
# mkdir -p a/b 
# chmod u-r a
# # This should fail.
# run $r -rf a
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot remove 'a': Permission denied" ]]
# chmod u+r a
# rm -rf *
# } 
#
#
# #unread3 of rm coreutils
# # Ensure that rm works even from an unreadable working directory.
# @test "rmalias unread3.sh" {
# skip "wip"
# mkdir -p a/1 b c d/2 e/3 
# t=$(pwd)
# cd c
# chmod u=x,go= .
#
# # With coreutils-5.2.1, this would get a failed assertion.
# $r -r "$t/a" "$t/b" 
#
# # With coreutils-5.2.1, this would get the following:
# #   rm: cannot get current directory: Permission denied
# #   rm: failed to return to initial working directory: Bad file descriptor
# run $r -r "$t/d" "$t/e" 
# (( $status == 1 ))
# [[ ${lines[0]} = "rmalias: cannot get current directory: Permission denied" ]]
# [[ ${lines[1]} = "rmalias: failed to return to initial working directory: Bad file descriptor" ]]
#
# [[ ! -d "$t/a" ]]
# [[ ! -d "$t/b" ]]
# [[ ! -d "$t/d" ]]
# [[ ! -d "$t/e" ]]
# chmod -Rf 0700 *
# rm -rf *
# }
#
#
# #unreadable.pl of rm coreutils
# # Test "rm" and unreadable directories.
# @test "rmalias unreadable.pl" {
# skip "Needs perl.. "
# }
#
#
# #v-slash of rm coreutils
# # avoid extra slashes in --verbose output
# @test "rmalias v-slash.sh" {
# skip "wip"
# mkdir a 
# touch a/x
# run $r --verbose -r a/// 
# (( $status == 0 ))
# [[ ${lines[0]} = "removed 'a/x'" ]]
# [[ ${lines[1]} = "removed directory 'a/'" ]]
# }
#
#
#
# @test "Clean everything" {
# touch file-to-not-fail-test-on-empty-dir
# chmod -Rf 0700 *
# rm -rf *
# }

