rmalias 
=======

Travis: [![Build Status](https://travis-ci.org/liloman/rmalias.svg?branch=master)](https://travis-ci.org/liloman/rmalias)

Coverage: [![Coverage
Status](https://coveralls.io/repos/liloman/rmalias/badge.svg?branch=master&service=github)](https://coveralls.io/github/liloman/rmalias?branch=master)

#Why?

Did you ever do `rmdir -p /etc/udev/emptydir`?

Did you ever do `rm -rf some-important-dir`?

Did you ever do `rm important-file`?

I even deleted **all** my *local changes* while testing this software without solution. :cry:


So I think it's a **must** for regular desktop use nowadays.

#How?

It's a fork of [rmtrash](https://github.com/PhrozenByte/rmtrash) but:

1. Based on unitary tests ( [bats](https://github.com/sstephenson/bats) )
2. Oficial coreutils tests translated to bats
3. Integrated with travis
4. Complete rework of code 


#Install 
Clone the repo in your $PATH dir and alias it, for example:

```bash
cd ~/Clones
git clone https://github.com/liloman/rmalias
ln -s $PWD/rmalias/rmdiralias ~/.local/bin/rmdiralias
echo 'alias rmdir="rmdiralias -v"' >> ~/.bashrc
```

In order to work you need to install trash-cli. For fedora:

```bash
dnf install trash-cli
```


#Oh wait! I got f*****! (frowning upon)

It's a wrapper for [trash-cli](https://github.com/andreafrancia/trash-cli) so you **can rollback any deleted file**.


##List trashed files
```bash
$ trash-list
2008-06-01 10:30:48 /home/andrea/bar
2008-06-02 21:50:41 /home/andrea/bar
2008-06-23 21:50:49 /home/andrea/foo
```

##Restore a trashed file

```bash
$ trash-restore
0 2007-08-30 12:36:00 /home/andrea/foo
1 2007-08-30 12:39:41 /home/andrea/bar
2 2007-08-30 12:39:41 /home/andrea/bar2
3 2007-08-30 12:39:41 /home/andrea/foo2
4 2007-08-30 12:39:41 /home/andrea/foo
What file to restore [0..4]: 4
$ ls foo
foo
```

##Empty all the trashcan

```bash
$ trash-empty
```

##Empty only the files that have been deleted before <days> ago

```bash
$ trash-list
2008-02-19 20:11:34 /home/einar/today
2008-02-18 20:11:34 /home/einar/yesterday
2008-02-10 20:11:34 /home/einar/last_week
$ trash-empty 7
$ trash-list
2008-02-19 20:11:34 /home/einar/today
2008-02-18 20:11:34 /home/einar/yesterday
```

##Remove only files matching a pattern

$ trash-rm \*.o

#TODO

##General
- [ ] You can't trash the trashcan
- [ ] Handle ERRORs from trash-put like not trashcan ...
- [ ] Patch PRoot to get it working with multiusers for travis and test it on several distros (Fedora and Ubuntu until now)
- [ ] Profile rmalias and trash-put, get better performance and uncomment long-standing tests
- [ ] Make it a FSM

##rmalias
- [ ] Finish -I 


