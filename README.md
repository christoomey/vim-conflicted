Conflicted
==========

Conflicted is a Vim plugin that aids in resolving git merge and rebase
conflicts. It relies on [tpope's fugitive plugin][] to do the heavy lifting and
provides a few wrapper commands and a streamlined workflow to make resolving
conflicts much more straightforward.

[tpope's fugitive plugin]: https://github.com/tpope/vim-fugitive

Usage
-----

Conflicted provides three primary commands for working with conflicts:

### Conflicted

`Conflicted` will add all the conflicted files to Vim's `arglist` and open
the first in `Merger` mode.

### GitNextConflict

After editing the merged file to resolve the conflict and remove all conflict
markers, running `GitNextConflict` will mark the file as resolved and open
the next file in `Merger` mode for resolution.

If you are on the last file, `GitNextConflict` will quit Vim.

### Merger

`Merger` will open the various views of the conflicted file. This command is
exposed for completeness, but likely you will not need to call this command
directly as both `Conflicted` and `GitNextConflict` will call it for you.

### Satusline Integration

Add the following to your vimrc to display the revision name of each split in
the vim statusbar:

``` vim
set stl+=%{ConflictedRevision()}
```

Installation
------------

If you don't have a preferred installation method, I recommend using [Vundle][].
Assuming you have Vundle installed and configured, the following steps will
install the plugin:

Add the following line to your `~/.vimrc` and then run `BundleInstall` from
within Vim:

``` vim
Bundle 'christoomey/vim-conflicted'
```

[Vundle]: https://github.com/gmarik/vundle
