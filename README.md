# Buildable source code for Elite on the NES

[BBC Micro (cassette)](https://github.com/markmoxon/cassette-elite-beebasm) | [BBC Micro (disc)](https://github.com/markmoxon/disc-elite-beebasm) | [6502 Second Processor](https://github.com/markmoxon/6502sp-elite-beebasm) | [BBC Master](https://github.com/markmoxon/master-elite-beebasm) | [Acorn Electron](https://github.com/markmoxon/electron-elite-beebasm) | [Elite-A](https://github.com/markmoxon/elite-a-beebasm) | **NES**

![Screenshot of Elite on the NES](https://www.bbcelite.com/images/github/nes-station.png)

This repository contains buildable source code for Elite on the NES.

The project's end goal is to have every single line documented and (for the most part) explained.

It is a work in progress; here's a link to the [current state of the documented source code](1-source-files/main-sources).

It is a companion to the [bbcelite.com website](https://www.bbcelite.com).

See the [introduction](#introduction) for more information.

## Contents

* [Introduction](#introduction)

* [Acknowledgements](#acknowledgements)

  * [A note on licences, copyright etc.](#user-content-a-note-on-licences-copyright-etc)

## Introduction

This repository contains work-in-progress source code for Elite on the NES.

You can build a working game using this command for Windows:

```
make.bat build verify
```

or this command for Mac and Linux:

```
make build verify
```

Requirements and configuration are the same as for my other Elite repositories, such as the [master-elite-beebasm](https://github.com/markmoxon/master-elite-beebasm) repository (on which the NES version is based).

Watch this space for developments...

## Acknowledgements

NES Elite was written by Ian Bell and David Braben and is copyright &copy; D. Braben and I. Bell 1991/1992.

The code on this site has been reconstructed from a disassembly of the version released on [Ian Bell's personal website](http://www.elitehomepage.org/).

The commentary is copyright &copy; Mark Moxon. Any misunderstandings or mistakes in the documentation are entirely my fault.

The following archive from Ian Bell's personal website forms the basis for this project:

* [NES Elite, NTSC version](http://www.elitehomepage.org/archive/a/b7120500.zip)

### A note on licences, copyright etc.

This repository is _not_ provided with a licence, and there is intentionally no `LICENSE` file provided.

According to [GitHub's licensing documentation](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/licensing-a-repository), this means that "the default copyright laws apply, meaning that you retain all rights to your source code and no one may reproduce, distribute, or create derivative works from your work".

The reason for this is that my commentary is intertwined with the original Elite source code, and the original source code is copyright. The whole site is therefore covered by default copyright law, to ensure that this copyright is respected.

Under GitHub's rules, you have the right to read and fork this repository... but that's it. No other use is permitted, I'm afraid.

My hope is that the educational and non-profit intentions of this repository will enable it to stay hosted and available, but the original copyright holders do have the right to ask for it to be taken down, in which case I will comply without hesitation. I do hope, though, that along with the various other disassemblies and commentaries of this source, it will remain viable.

---

Right on, Commanders!

_Mark Moxon_