homebrew-zfs
============

[MacZFS](http://maczfs.org/) formulae for the [Homebrew package manager](http://brew.sh).


Warning!
--------

This tap was created for personal use.  While it works for me it is
not endorsed by the MacZFS community in any way as installing with
`homebrew` cannot ensure that kernel extensions and userland binaries
are in sync.  This is because `homebrew` discourages the use of `sudo`
and prohibits installation of anything outside its prefix (usually
`/usr/local`).

Using non-matching binaries and kernel extensions may lead to data loss,
kernel panics and other undesired behavior.  Back up your data.  You
have been warned!


Installation
------------

```sh
$ brew tap witsch/zfs
$ brew install maczfs
```
