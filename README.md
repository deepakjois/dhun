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

Pass the `-d` option to run the server as a daemon in the background. See
`dhun -h` for more options.


### Querying for files

Dhun uses Spotlight to query for music files. Just specify a keyword, and Dhun
will look for files matching that keyword and start playing them.

You can also query the Spotlight database before playing the files, with the 
`query` command.

    $ dhun query here
    3 Results
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/01 40 Day Dream.mp3
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/02 Janglin.mp3
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/03 Carries On.mp3

You can use query filters like `album:sid` or `artist:rahman`. Currently
`album`, `artist`, `title`, `genre` and `file` filters are supported. 

    $ dhun query genre:world album:gypsy
    5 results
    /Users/deepak/Dropbox/shared/music/gypsy/Putumayo - Gypsy Groove - 11 - Eastenders - Vino Iubirea Mea (!DelaDap Remix) (Germany).mp3
    /Users/deepak/Dropbox/shared/music/gypsy/Putumayo - Gypsy Groove - 10 - Luminescent Orchestrii - Amari Szi, Amari (Amon Remix)  (USA).mp3
    /Users/deepak/Dropbox/shared/music/gypsy/Putumayo - Gypsy Groove - 09 - Kistehén Tánczenekar - Virágok a Réten (Romano Drom Remix) (Hungary).mp3
    /Users/deepak/Dropbox/shared/music/gypsy/Putumayo - Gypsy Groove - 08 - Anselmo Crew - Süt Ictim Dilim Yandi (Hungary).mp3
    /Users/deepak/Dropbox/shared/music/gypsy/Putumayo - Gypsy Groove - 07 - Magnifico & Turbolentza - Zh Ne Sui Pa Pur Tua (Slovenia).mp3

You can even mix the filters with a regular query like.

    $ dhun query genre:world album:gypsy Czech
    2 Results
    /Users/deepak/Dropbox/shared/music/gypsy/Putumayo - Gypsy Groove - 01 - !DelaDap - Zsa Manca (Czech Republic-Hungary).mp3
    /Users/deepak/Dropbox/shared/music/gypsy/Putumayo - Gypsy Groove - 03 - Gipsy.cz - Jednou (Czech Republic).mp3

Note that if you want to pass filters longer than a word, you will need to
enclose the argument in double quotes, like `dhun query "artist:akli d"`

### Playing Files

When you are ready to play the files, pass the query to the `play` command.
Note that the `play` command will remove anything that may be already there on
your queue. To append files to queue, use `enqueue`.

    $ dhun play here
    3 files queued for playing
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/01 40 Day Dream.mp3
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/02 Janglin.mp3
    /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/03 Carries On.mp3
    
Enqueuing more files.

    $ dhun enqueue chup
    1 files queued for playing.
    /Users/deepak/Dropbox/shared/music/Coke Studio/Chup.mp3
    

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

You can use a numeric argument to specify the number of tracks to skip ahead,
like `dhun next 2`.

Skipping to previous file in history.

    $ dhun prev 
    Dhun is playing /Users/deepak/Music/iTunes/iTunes Media/Music/Edward Sharpe & The Magnetic Zeros/Here Comes/02 Janglin.mp3

You can use a numeric argument to specify the number of tracks to skip ahead,
like `dhun prev 2`.

Shuffling the queue

    $ dhun shuffle
    Queue is shuffled
    /Users/deepak/Dropbox/shared/music/3 idiots/35634_Give Me Some Sunshine.mp3
    /Users/deepak/Dropbox/shared/music/Aao Wish Karen/35612_Kuch Aisa.mp3
    /Users/deepak/Dropbox/shared/music/Coke Studio/Jo-Meray.mp3

### Other commands

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

History

    $ dhun history
    3 files in history
    /Users/deepak/Dropbox/shared/music/Coke Studio/Bari-Barsi.mp3
    /Users/deepak/Dropbox/shared/music/Coke Studio/Aankhon-Kay-Sagar.mp3
    /Users/deepak/Dropbox/shared/music/Coke Studio/Paimona.mp3

### Stopping Dhun

This will exit the process.

    $ dhun stop

## Coming Soon

There are some features planned in the short run. Please file an issue with a
feature request, if you have one.

* Saving/Loading playlists
* Growl Notifications using `growlnotify`

And someday..

* iTunes integration
* Displaying IDv3 information instead of just file names

## Feedback

email me at deepak DOT jois AT gmail DOT com