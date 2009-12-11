## Introduction

> A dhun (Hindi: धुन; literally "tune") is a light instrumental piece in the
> Hindustani classical music of North India.
>
> Source : [Wikipedia](http://en.wikipedia.org/wiki/Dhun)

Dhun is a minimalist commandline music player for OS X.

It uses Spotlight to search for audio files on your computer and play them.

## Quickstart

### Installing Dhun

Run the following commands to install Dhun. This will download the latest gem
from [http://gemcutter.org](http://gemcutter.org), compile the extensions and
put the binaries in the right place. You will need to have XCode installed for
the `gem` command to compile the native extensions.

    $ gem sources -a http://gemcutter.org
    $ gem install dhun

### Starting Dhun

    $ dhun start
    Starting Dhun

Pass the `-d` option to run the server as a daemon in the background.

### Playing Files

Dhun uses Spotlight to query for music files. Just specify a keyword, and Dhun
will look for files matching that keyword and start playing them.

You can also query the Spotlight database before playing the files.

    $ dhun query here
    9 Results
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/01 40 Day Dream.mp3
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/02 Janglin.mp3
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/03 Carries On.mp3
    /Users/deepak/Music/Amazon MP3/Edward Sharpe & The Magnetic Zeros/Here Comes/01 - 40 Day Dream.mp3
    /Users/deepak/Music/Amazon MP3/Edward Sharpe & The Magnetic Zeros/Here Comes/02 - Janglin.mp3
    /Users/deepak/Music/Amazon MP3/Edward Sharpe & The Magnetic Zeros/Here Comes/03 - Carries On.mp3
    /Users/deepak/Dropbox/shared/music/Here Comes/02 - Janglin.mp3
    /Users/deepak/Dropbox/shared/music/Here Comes/01 - 40 Day Dream.mp3
    /Users/deepak/Dropbox/shared/music/Here Comes/03 - Carries On.mp3

And then, when you are ready to play the files. Note that the `play` command
will remove anything that may be already there on your queue. To add files,
use `enqueue`.

    $ dhun play here
    9 files queued for playing
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/01 40 Day Dream.mp3
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/02 Janglin.mp3
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/03 Carries On.mp3
    /Users/deepak/Music/Amazon MP3/Edward Sharpe & The Magnetic Zeros/Here Comes/01 - 40 Day Dream.mp3
    /Users/deepak/Music/Amazon MP3/Edward Sharpe & The Magnetic Zeros/Here Comes/02 - Janglin.mp3
    /Users/deepak/Music/Amazon MP3/Edward Sharpe & The Magnetic Zeros/Here Comes/03 - Carries On.mp3
    /Users/deepak/Dropbox/shared/music/Here Comes/02 - Janglin.mp3
    /Users/deepak/Dropbox/shared/music/Here Comes/01 - 40 Day Dream.mp3
    /Users/deepak/Dropbox/shared/music/Here Comes/03 - Carries On.mp3

More advanced querying support is coming soon.

### Controlling Playback

Pausing playback.

    $ dhun pause
    Dhun is paused at /Users/deepak/Dropbox/shared/music/Coke Studio/Jo-Meray.mp3

Resuming playback.

    $ dhun resume
    Dhun is playing /Users/deepak/Dropbox/shared/music/Coke Studio/Jo-Meray.mp3

Skipping to next file

    $ dhun next
    Dhun is playing /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/03 Carries On.mp3

Status

    $ dhun status
    Dhun is running
    Now playing /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/03 Carries On.mp3
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/02 Janglin.mp3
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/03 Carries On.mp3
    /Users/deepak/Music/Amazon MP3/Edward Sharpe & The Magnetic Zeros/Here Comes/01 - 40 Day Dream.mp3
    /Users/deepak/Music/Amazon MP3/Edward Sharpe & The Magnetic Zeros/Here Comes/02 - Janglin.mp3
    /Users/deepak/Music/Amazon MP3/Edward Sharpe & The Magnetic Zeros/Here Comes/03 - Carries On.mp3
    /Users/deepak/Dropbox/shared/music/Here Comes/02 - Janglin.mp3
    /Users/deepak/Dropbox/shared/music/Here Comes/01 - 40 Day Dream.mp3
    /Users/deepak/Dropbox/shared/music/Here Comes/03 - Carries On.mp3

Enqueuing more files. Note that `dhun play` will empty the current queue
before adding new files.

    $ dhun enqueue chup
    1 files queued for playing.
    /Users/deepak/Dropbox/shared/music/Coke Studio/Chup.mp3

### Stopping Dhun

This will exit the process.

    $ dhun stop

## Coming Soon

These features are planned in the next few releases

* Playing previous song, using something like `dhun prev`
* Skipping ahead by more than one file, like `dhun next 2` or `dhun prev 2`
* Advanced querying support with filters, like `dhun play "artist:Rahman"`

And someday..

* iTunes integration
* Displaying IDv3 information instead of just file names

## Feedback

email me at deepak DOT jois AT gmail DOT com