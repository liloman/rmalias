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
chmod -Rf 0777 *
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

#
# # #############
# # #  OPTIONS  #
# # #############
# #
# #
@test "rmalias -d empty dir shows nothing" {
mkdir dirempty
run $r -d dirempty
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
[[ ! -e dirempty ]]
}

@test "rmalias -d not empty dir shows directory not empty" {
mkdir -p 1/2
run $r -d 1
(( $status == 1 ))
[[ ${lines[0]} = "rmalias: cannot remove '1': Directory not empty" ]]
[[ -e 1/2 ]]
rm -rf 1/
}


# #############
# #  SPACES   #
# #############


#ignore.sh of rmdir coreutils with spaces
@test "rmdiralias --recursive with spaced empty dirs remove them" {
mkdir -p a/{b\ 1,b\ 2}/c
run $r --recursive a/
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
[[ ! -d a ]]
rm -rf a/
}



#ignore.sh of rmdir coreutils with spaces and glob
@test "rmalias -R with spaced globbed empty dirs remove them until top" {
mkdir -p a/{b\ 1,b\ 2,b\ 3}/c
run $r -R a/*
(( $status == 0 ))
[[ ${lines[0]} = "" ]]
[[ ! -d a/b\ 3/c ]]
[[ -d a ]]
rm -rf a/
}



# ###########################################################################
# #                        Coreutils rm tests                               #
# #  http://git.savannah.gnu.org/gitweb/?p=coreutils.git;a=tree;f=tests/rm  #
# ###########################################################################


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
mkdir d 
run $r -idv d <<< $'y'
(( $status == 0 ))
[[ ${lines[0]} = "rmalias: remove directory 'd'? " ]]
[[ ${lines[1]} = "removed directory: 'd'" ]]
}

 #dangling-symlink.sh of rm coreutils
 # rm should not prompt before removing a dangling symlink.
 # Likewise for a non-dangling symlink.
 # But for fileutils-4.1.9, it would do the former and
 # for fileutils-4.1.10 the latter.
 @test "rmalias dangling-symlink.sh" {
 ln -s no-file dangle
 ln -s / symlink

 run $r dangle symlink 
 # The buggy rm (fileutils-4.1.9) would hang here, waiting for input.

 (( $status == 0 ))
 [[ ${lines[0]} = "" ]]

 }


 #deep.sh of rm coreutils
 # Test rm with a deep hierarchy
 @test "rmalias deep.sh" {
 skip "profiling:Works but needs some strace  ..."
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
 # http://git.savannah.gnu.org/gitweb/?p=coreutils.git;a=blob;f=src/remove.c for
 # solution with vfork
 skip "rework:getconf PATH_MAX dir = 4096 needs some rework to change dirs (cd)"

 
# ecryptfs for example uses some of the file name space
# for encrypting filenames, so we must check dynamically.
name_max=$(stat -f -c %l .)
[[ $name_max > '200' ]]

mkdir x
cd x 

# Construct a hierarchy containing a relative file with a long name
perl \
    -e 'my $d = "x" x 200; foreach my $i (1..52)' \
    -e '  { mkdir ($d, 0700) && chdir $d or die "$!" }' 
cd .. 
echo n > no 

run $r -r x < no 
(( $status == 0 ))
[[ ${lines[0]} = "" ]]

# the directory must have been removed
[[ ! -d x ]]

}


 #dir-no-w.sh of rm coreutils
 @test "rmalias dir-no-w.sh" {
 # rm (without -r) must give a diagnostic for any directory.
 #It must not prompt, even if that directory is unwritable.
 mkdir --mode=0500 unwritable-dir

 run $r unwritable-dir
 (( $status == 1 ))
 # When run by a non-privileged user we get this:
 # rm: cannot remove 'unwritable-dir': Is a directory
 # When run by root we get this:
 # rm: cannot remove directory 'unwritable-dir': Is a directory
 [[ ${lines[0]} = "rmalias: cannot remove 'unwritable-dir': Is a directory" ]]
 chmod u+w unwritable-dir
 rm -rf unwritable-dir
 }

 #dir-nonrecur.sh of rm coreutils
 # Ensure that 'rm dir' (i.e., without --recursive) gives a reasonable
 # diagnostic when failing.
 @test "rmalias dir-nonrecur.sh" {
 mkdir -p d
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
 mkdir -m0 inacc
 #Also exercise the different code path that's taken for a directory
 # that is empty (hence removable) and unreadable.
 mkdir -m a-r -p a/unreadable

 # This would fail for e.g., coreutils-5.93.
 run $r -rf inacc 
 [[ ! -d inacc ]]

 # This would fail for e.g., coreutils-5.97.
 run $r -rf a 
 [[ ! -d a ]]
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
 skip "profiling:needs strace or maybe impossible? ..."
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
 skip "wip on travis branch"
 # The containing directory must be owned by the user who eventually runs rm.
 sudo -u prueba mkdir -m1777 notmine
 sudo -u prueba touch notmine/b
 chown $USER .
 run $r -rf notmine
 (( $status == 1 ))
 [[ ${lines[0]} = "rmalias: cannot remove 'notmine/b': Operation not permitted" ]]
 sudo -u prueba rm -rf notmine
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

 run $r -rf d/f 
 (( $status == 1 ))
 [[ ${lines[0]} = "rmalias: cannot remove 'd/f': Permission denied" ]]

 mkdir e 
 ln -s f e/slink
 chmod a-w e   

 # This used to fail with ELOOP.
 run $r -rf e 
 (( $status == 1 ))
 [[ ${lines[0]} = "rmalias: cannot remove 'e/slink': Permission denied" ]]
 chmod a+w e d  
 rm -rf e d
 }


 #fail-eperm.sh of rm coreutils
 # Ensure that rm gives the expected diagnostic when failing to remove a file
 # owned by some other user in a directory with the sticky bit set.
 @test "rmalias fail-eperm.sh" {
 chmod 777 .
 #other user
 sudo -u prueba mkdir -m1777 stickydir
 sudo -u prueba touch stickydir/file 
 #main user
 run $r -f stickydir/file
 (( $status == 1 ))
 [[ ${lines[0]} = "rmalias: cannot remove 'stickydir/file': Operation not permitted" ]]
 [[ -e stickydir/file ]]
 #other user
 sudo -u prueba rm -rf stickydir
 }


 #hash.sh of rm coreutils
 # Exercise a bug that was fixed in 4.0s.
 # Before then, rm would fail occasionally, sometimes via
 # a failed assertion, others with a seg fault.
 @test "rmalias hash.sh" {
 skip "profiling:Takes too long... needs profiling"
 # Create a hierarchy with 3*26 leaf directories, each at depth 153.
 # echo "$0: creating 78 trees, each of depth 153; this will take a while..." >&2
 y=$(seq 1 150|tr -sc '\n' y|tr '\n' /)
 for i in 1 2 3; do
   for j in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
     mkdir -p t/$i/$j/$y 
   done
 done

 run $r -r t 
 (( $status == 0 ))
 [[ ${lines[0]} = "" ]]
 }

 #i-1.sh of rm coreutils
 # Test "rm -i"
 @test "rmalias i-1.sh" {
 t=t
 mkdir -p $t
 echo > $t/a 
 [[ -f $t/a ]]
 
 echo y > $t/in-y
 echo n > $t/in-n
 
 $r -i $t/a < $t/in-n 
 # The file should not have been removed.
 [[ -f $t/a ]]
 
 $r -i $t/a < $t/in-y 
 # The file should have been removed this time.
 [[ ! -f $t/a ]]
 
 rm -rf $t
 }

 #i-never.sh of rm coreutils
 # Ensure that rm --interactive=never works does not prompt, even for
 # an unwritable file.
 @test "rmalias i-never.sh" {
 touch f 
 chmod 0 f
 $r --interactive=never f 
 }

 #i-no-r.sh of rm coreutils
 # Since the rewrite for fileutils-4.1.9, 'rm -i DIR' would mistakenly
 # recurse into directory DIR.  rm -i (without -r) must fail in that case.
 # Fixed in coreutils-4.5.2.
 @test "rmalias i-no-r.sh" {
 mkdir dir 

 # This must fail.
 run $r -i dir   
 (( $status == 1 ))
 [[ ${lines[0]} = "rmalias: cannot remove 'dir': Is a directory" ]]

 # The directory must remain.
 [[ -d dir ]]
 rmdir dir
 }


 #ignorable.sh of rm coreutils
 # Ensure that rm -f exits successfully
 @test "rmalias ignorable.sh" {
 touch existing-non-dir
 # With coreutils-6.3, this would exit nonzero.  It should not.
 # Example from Andreas Schwab.
 run $r -f existing-non-dir/f 
 (( $status == 0 ))
 [[ ${lines[0]} = "" ]]
 }

 #inaccessible of rm coreutils
 # Ensure that rm works even when run from a directory
 # for which the user has no access at all.
 @test "rmalias inaccessible.sh" {
 p=$(pwd)
 mkdir abs1 abs2 no-access 
 cd no-access
 chmod 0 . 
 run $r -r "$p/abs1" rel "$p/abs2"
 (( $status == 1 ))
 [[ ${lines[0]} = "rmalias: cannot remove 'rel': Permission denied" ]]
 [[ ! -d "$p/abs1" ]]
 [[ ! -d "$p/abs2" ]]
 chmod 777 "$p/no-access"
 rmdir "$p/no-access"
 }


 #interactive-always.sh of rm coreutils
 # Test the --interactive[=WHEN] changes added to coreutils 6.0
 @test "rmalias interactive-always.sh" {
 touch file1-1 file1-2 file2-1 file2-2 file3-1 file3-2 file4-1 file4-2 
   
# If asked, answer no to first question, then yes to second.
echo 'n
y' > in 

# The prompt has a trailing space, and no newline, so an extra
# 'echo .' is inserted after each rm to make it obvious what was asked.
 run $r -R --interactive file1-* < in 
 (( $status == 0 ))
 [[ ${lines[0]} = "rmalias: remove regular empty file 'file1-1'? " ]]
 [[ ${lines[1]} = "rmalias: remove regular empty file 'file1-2'? " ]]
 [[ -f file1-1 ]] 
 [[ ! -f file1-2 ]] 
 
 run $r -R --interactive=never file2-* < in 
 (( $status == 0 ))
 [[ ! -f file2-1 ]]
 [[ ! -f file2-2 ]]
  
 run $r -R --interactive=once file3-* < in 
 (( $status == 0 ))
 [[ ${lines[0]} = "rmalias: remove 2 arguments recursively? " ]]
 [[ -f file3-1 ]]
 [[ -f file3-2 ]]

 run $r -R --interactive=always file4-* < in
 (( $status == 0 ))
 [[ ${lines[0]} = "rmalias: remove regular empty file 'file4-1'? " ]]
 [[ ${lines[1]} = "rmalias: remove regular empty file 'file4-2'? " ]]
 [[ -f file4-1 ]] 
 [[ ! -f file4-2 ]] 

 run $r -R --interactive=once -f file1-* < in 
 (( $status == 0 ))
 [[ ${lines[0]} = "" ]]
 [[ ! -f file1-1 ]] 
 [[ ! -f file1-2 ]] 

 #the order of force is important :S
 run $r -R -f --interactive=once file4-* < in 
 (( $status == 0 ))
 [[ ${lines[0]} = "rmalias: remove 1 arguments recursively? " ]]
 [[ -f file4-1 ]]
 }


 #ir-1 of rm coreutils
 # Test rm ir
 @test "rmalias ir-1.sh" {

t=t
mkdir -p $t $t/a $t/b $t/c 
> $t/a/a
> $t/b/bb
> $t/c/cc

echo 'yyyyyyyynnn' > in

# Remove all but one of a, b, c -- I doubt that this test can portably
# determine which one was removed based on order of dir entries.
# This is a good argument for switching to a dejagnu-style test suite.
run $r --verbose -i -r $t < in
 (( $status == 0 ))
 [[ ${lines[0]} = "rmalias: descend into directory 't'? " ]]
 [[ ${lines[1]} = "rmalias: descend into directory 't/c'? " ]]
 [[ ${lines[2]} = "rmalias: remove regular empty file 't/c/cc'? " ]]
 [[ ${lines[3]} = "removed 't/c/cc'" ]]
 [[ ${lines[4]} = "rmalias: remove directory 't/c'? " ]]
 [[ ${lines[5]} = "removed directory: 't/c'" ]]
 [[ ${lines[6]} = "rmalias: descend into directory 't/b'? " ]]
 [[ ${lines[7]} = "rmalias: remove regular empty file 't/b/bb'? " ]]
 [[ ${lines[8]} = "removed 't/b/bb'" ]]
 [[ ${lines[9]} = "rmalias: remove directory 't/b'? " ]]
 [[ ${lines[10]} = "removed directory: 't/b'" ]]
 [[ ${lines[11]} = "rmalias: descend into directory 't/a'? " ]]
 [[ ${lines[12]} = "rmalias: remove regular empty file 't/a/a'? " ]]
 [[ ${lines[13]} = "rmalias: remove directory 't/a'? " ]]
 [[ ${lines[14]} = "rmalias: remove directory 't'? " ]]

 [[ -f $t/a/a ]]

# There should be only one directory left.
case $(echo $t/*) in
  $t/[abc]) true ;;
  *) false ;;
esac


}

 #isatty of rm coreutils
 # Make sure 'chown 0 f; rm f' prompts before removing f.
 @test "rmalias isatty.sh" {
 # Terminate any background processes
#  cleanup_() { kill $pid 2>/dev/null && wait $pid; }
 touch f
 chmod 0 f
 run $r f <<< 'n'

#  # Wait a second, to give a buggy rm (as in fileutils-4.0.40)
#  # enough time to remove the file.
#  sleep 1

 # The file must still exist.
 [[ -f f ]]

#  cleanup_

 (( $status == 0 ))
 [[ ${lines[0]} = "rmalias: remove write-protected regular empty file 'f'? " ]]
 }


 #many-dir-entries-vs-OOM of rm coreutils
 # In coreutils-8.12, rm,du,chmod, etc. would use too much memory
 # when processing a directory with many entries (as in > 100,000).
 @test "rmalias many-dir-entries-vs-OOM.sh" {
 skip "profiling:Needs profiling this MADNESS !!!!??? :O "
 }


 #no-give-up of rm coreutils
 # With rm from coreutils-5.2.1 and earlier, 'rm -r' would mistakenly
 # give up too early under some conditions.
 @test "rmalias no-give-up.sh" {
 # Ensure that non-root can access files in root-owned ".".
 sudo -u prueba mkdir -m0711 no-give-up/
 sudo -u prueba mkdir no-give-up/other
 sudo -u prueba touch no-give-up/other/f

 cd no-give-up

 # This must fail, since '.' is not writable by $NON_ROOT_USERNAME.
 run $r -rf other

 (( $status == 1 ))
 [[ ${lines[0]} = "rmalias: cannot remove 'other/f': Permission denied" ]]

 cd ..
 # f must have been removed ???
 # [[ ! -f no-give-up/other/f ]] 
 [[ -d no-give-up/other ]] 

 sudo -u prueba rm -rf no-give-up
 }


 #one-file-system of rm coreutils
 # Demonstrate rm's new --one-file-system option.
 @test "rmalias one-file-system.sh" {
 skip "option:Needs --one-file-system option"
 }

 #one-file-system2 of rm coreutils
 # Verify --one-file-system does delete within a file system
 @test "rmalias one-file-system2.sh" {
 skip "option:Needs --one-file-system option"
 mkdir -p a/b
 run $r --one-file-system -rf a

 (( $status == 0 ))
 [[ ${lines[0]} = "" ]]

 [[ ! -d a ]]

 }


 #rm1 of rm coreutils
 # Test "rm -r --verbose".
 @test "rmalias rm1.sh" {
 mkdir a a/a 
 > b

 run $r --verbose -r a b 

 (( $status == 0 ))
 [[ ${lines[0]} = "removed directory: 'a/a'" ]]
 [[ ${lines[1]} = "removed directory: 'a'" ]]
 [[ ${lines[2]} = "removed 'b'" ]]

 [[ ! -d a ]]
 [[ ! -d a/a ]]

 }


 #rm2 of rm coreutils
 # exercise another small part of remove.c
 @test "rmalias rm2.sh" {
 skip "findutils 4.4.2(precise) unable to read unreadable a/1/ and b/ like newer ones without sudo"
 mkdir -p a/0 
 mkdir -p a/1/2 b/3 
 mkdir a/2 a/3 
 chmod u-x a/1 b

 # Exercise two separate code paths -- though both result
 # in the same sort of diagnostic.
 # Both of these should fail.
 run $r -rf a b 
 (( $status == 1 ))
 # linux == solaris in tests??
 [[ ${lines[0]} = "rmalias: cannot remove 'a/1/2': Permission denied" ]]
 [[ ${lines[1]} = "rmalias: cannot remove 'b/3': Permission denied" ]]

 [[ ! -d a/0 ]]
 [[ -d a/1 ]]
 [[ ! -d a/2 ]]
 [[ ! -d a/3 ]]

 chmod u+x b a/1
 [[ -d b/3 ]]
 rm -rf b a
 }


 #rm3 of rm coreutils
 # exercise another small part of remove.c
 @test "rmalias rm3.sh" {
 mkdir -p z
 cd z 
 touch empty empty-u
 echo not-empty > fu
 ln -s empty-f slink
 ln -s . slinkdot
 mkdir d du 
 chmod u-w fu du empty-u 
 cd ..

 echo 'yyyyyyyyy' > in

 # Both of these should fail.
 run bash -c "$r -ir z < in | sort"
 (( $status == 0 ))

# Sorted for preciste tests :S
[[ ${lines[0]} = "rmalias: descend into directory 'z'? " ]]
[[ ${lines[1]} = "rmalias: remove directory 'z'? " ]]
[[ ${lines[2]} = "rmalias: remove directory 'z/d'? " ]]
[[ ${lines[3]} = "rmalias: remove regular empty file 'z/empty'? " ]]
[[ ${lines[4]} = "rmalias: remove symbolic link 'z/slink'? " ]]
[[ ${lines[5]} = "rmalias: remove symbolic link 'z/slinkdot'? " ]]
[[ ${lines[6]} = "rmalias: remove write-protected directory 'z/du'? " ]]
[[ ${lines[7]} = "rmalias: remove write-protected regular empty file 'z/empty-u'? " ]]
[[ ${lines[8]} = "rmalias: remove write-protected regular file 'z/fu'? " ]]

# Unsorted
#  [[ ${lines[0]} = "rmalias: descend into directory 'z'? " ]]
#  [[ ${lines[1]} = "rmalias: remove write-protected directory 'z/du'? " ]]
#  [[ ${lines[2]} = "rmalias: remove directory 'z/d'? " ]]
#  [[ ${lines[3]} = "rmalias: remove symbolic link 'z/slinkdot'? " ]]
#  [[ ${lines[4]} = "rmalias: remove symbolic link 'z/slink'? " ]]
#  [[ ${lines[5]} = "rmalias: remove write-protected regular file 'z/fu'? " ]]
#  [[ ${lines[6]} = "rmalias: remove write-protected regular empty file 'z/empty-u'? " ]]
#  [[ ${lines[7]} = "rmalias: remove regular empty file 'z/empty'? " ]]
#  [[ ${lines[8]} = "rmalias: remove directory 'z'? " ]]
 [[ ! -d z ]]
}


#rm4 of rm coreutils
# ensure that 'rm dir' fails without --recursive
@test "rmalias rm4.sh" {
mkdir dir 
# This should fail.
run $r dir 
(( $status == 1 ))
[[ -d dir ]]
rm -rf dir
 }

 #rm5 of rm coreutils
 # a basic test of rm -ri
 @test "rmalias rm5.sh" {
 mkdir -p d/e 
 echo 'yyy' > in 

 run $r -ir d < in 

 (( $status == 0 ))
 [[ ${lines[0]} = "rmalias: descend into directory 'd'? " ]]
 [[ ${lines[1]} = "rmalias: remove directory 'd/e'? " ]]
 [[ ${lines[2]} = "rmalias: remove directory 'd'? " ]]

 # Make sure it's been removed.
 [[ ! -d d ]]
 } 



 #unread2 of rm coreutils
 # exercise one small part of remove.c
 @test "rmalias unread2.sh" {
 mkdir -p a/b 
 chmod u-r a
 # This should fail.
 run $r -rf a
 (( $status == 1 ))
 [[ ${lines[0]} = "rmalias: cannot remove 'a': Permission denied" ]]
 [[ -d a ]]
 chmod u+r a
 rm -rf a
 } 


 #unread3 of rm coreutils
 # Ensure that rm works even from an unreadable working directory.
 @test "rmalias unread3.sh" {
 mkdir -p a/1 b c d/2 e/3 
 t=$(pwd)
 cd c
 chmod u=x,go= .

 # With coreutils-5.2.1, this would get a failed assertion.
 run $r -r "$t/a" "$t/b"

 (( $status == 0 ))
 [[ ${lines[0]} = "" ]]

 # With coreutils-5.2.1, this would get the following:
 #   rm: cannot get current directory: Permission denied
 #   rm: failed to return to initial working directory: Bad file descriptor
 run $r -r "$t/d" "$t/e" 
 (( $status == 0 ))
 [[ ${lines[0]} = "" ]]

 [[ ! -d "$t/a" ]]
 [[ ! -d "$t/b" ]]
 [[ ! -d "$t/d" ]]
 [[ ! -d "$t/e" ]]

}


#unreadable.pl of rm coreutils
# Test "rm" and unreadable directories.
@test "rmalias unreadable.pl" {
mkdir -m0100 unreadable-1
run $r -rf unreadable-1
 (( $status == 0 ))
 [[ ${lines[0]} = "" ]]

 mkdir -m0700 unreadable-2
 mkdir -m0700 unreadable-2/x
 chmod 0100 unreadable-2 
 run $r -rf unreadable-2
 (( $status == 1 ))
 [[ ${lines[0]} = "rmalias: cannot remove 'unreadable-2': Permission denied" ]]
 chmod 0777 unreadable-2/
 rm -rf unreadable-2/
 }


 #v-slash of rm coreutils
 # avoid extra slashes in --verbose output
 @test "rmalias v-slash.sh" {
 mkdir a 
 touch a/x
 run $r --verbose -r a/// 
 (( $status == 0 ))
 [[ ${lines[0]} = "removed 'a/x'" ]]
 # Removed trailing / :)
 [[ ${lines[1]} = "removed directory: 'a'" ]]
 }


 @test "Clean everything" {
 touch file-to-not-fail-test-on-empty-dir
 chmod -Rf 0700 *
 rm -rf *
 }

