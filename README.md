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
    
Or to install the bleeding edge, git pull from the repository and run:

    $ sudo rake gem install

### Starting Dhun

    $ dhun start_server
    Starting Dhun

this runs the Dhun server as a daemon by default. to not run it as a daemon:

    $ dhun start_server --foreground
    or
    $ dhun start_server -f

See `dhun help start_server for more information`

### Querying for files

Dhun uses Spotlight to query for music files. Just specify a keyword, and Dhun
will look for files matching that keyword and start playing them.

You can also query the Spotlight database before playing the files, with the 
`query` command.

    $ dhun query deadmau5

    Querying: deadmau5 | 6 Results
    1 : /Volumes/Storage/Music/Grand.Theft.Auto.IV-Radio.Station.Rips-AiTB/Electro-Choc/03 One + One - No Pressure (Deadmau5 Remix).mp3
    2 : /Volumes/Storage/Music/Grand.Theft.Auto.IV-Radio.Station.Rips-AiTB/Electro-Choc/09 Chris Lake vs. Deadmau5 - I Thought Inside Out (Original Mix).mp3
    3 : Deadmau5 - Alone With You
    4 : Deadmau5 - Arguru (EDX's 5un5hine Remix)
    5 : Deadmau5 - Bye Friend
    6 : Deadmau5 - Clockwork



you can query based on certain filters such as artist,albums, title, genre and file.

    $ dhun query --artist="Paul van Dyk" --genre=trance --file 'Paul' --title in

    Querying: [nil] | artist:Paul van Dyk title:in genre:trance file:Paul
    3 Results
    1 : Paul van Dyk - Talk In Grey
    2 : Paul van Dyk - In Circles
    3 : Paul van Dyk - In Between


YOu can mix filters with regular queries as well.

    $ dhun query paul --title=haunted

    Querying: paul | title:haunted
    1 Results
    1 : Paul van Dyk - Haunted

You can also pass in multiple regular expressions too. they just need to be seperated by commas (,)

    $ dhun query paul,trance

    Querying: paul,trance | 13 Results
    1 : Paul van Dyk - Volume (Productions)
    2 : Paul van Dyk - Volume (Remixes Part 1)
    3 : Paul van Dyk - Volume (Remixes Part 2)
    4 : Paul van Dyk - Complicated (Feat. Ashley Tomberlin)
    5 : Paul van Dyk - Haunted
    6 : Paul van Dyk - White Lies (Feat. Jessica Sutta)
    7 : Paul van Dyk - Sabotage
    8 : Paul van Dyk - Get Back (Feat. Ashley Tomberlin)
    9 : Paul van Dyk - Far Away
    10 : Paul van Dyk - Another Sunday
    11 : Paul van Dyk - Talk In Grey
    12 : Paul van Dyk - In Circles
    13 : Paul van Dyk - In Between


Now lets put it all together and go crazy.

    $ dhun query 'paul van',dyk --genre=trance --title=haunted

    Querying: paul van,dyk | title:haunted genre:trance
    1 Results
    1 : Paul van Dyk - Haunted


### Playing Files

To play the files, first enqueue the songs.

    $ dhun play paul,trance

this can also be done by

    $ dhun enqueue paul,trance

    Querying: paul,trance | 13 Results
    1 : Paul van Dyk - Volume (Productions)
    2 : Paul van Dyk - Volume (Remixes Part 1)
    3 : Paul van Dyk - Volume (Remixes Part 2)
    4 : Paul van Dyk - Complicated (Feat. Ashley Tomberlin)
    5 : Paul van Dyk - Haunted
    6 : Paul van Dyk - White Lies (Feat. Jessica Sutta)
    7 : Paul van Dyk - Sabotage
    8 : Paul van Dyk - Get Back (Feat. Ashley Tomberlin)
    9 : Paul van Dyk - Far Away
    10 : Paul van Dyk - Another Sunday
    11 : Paul van Dyk - Talk In Grey
    12 : Paul van Dyk - In Circles
    13 : Paul van Dyk - In Between
    Enter index to queue: 

It will prompt you to enter the index of the songs you want queued.(numbers on the left side)
You can enter them separated by commas(1,2,3,4) or spaces(1 2 3 4) or a single song if you like.
If you leave the prompt blank and enter, it will queue ALL the resulting songs.

    Enter index to queue 4 5
    selected:
    1 : Paul van Dyk - Complicated (Feat. Ashley Tomberlin)
    2 : Paul van Dyk - Haunted
    2 files queued


Once queued, the songs will begin playing. you can continue to enqueue more songs via enqueue and play.
    
### Controlling Playback


Starting Playback(needs to have songs in queue)

    $ dhun play
    resuming playback
    
Stopping playback.

    $ dhun stop
    Dhun has stopped

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
    Queue:
    1 : Deadmau5 - I Remember (Vocal Mix)
    2 : Paul van Dyk - Haunted
    3 : Above & Beyond - I Am What I Am
    4 : Above & Beyond - Sirens Of The Sea
    5 : Paul van Dyk - Haunted

### Other commands

Status

    $ dhun status
    Dhun is running
    Currently Playing:
    Deadmau5 - I Remember (Vocal Mix)
    Queue:
    1 : Paul van Dyk - Haunted
    2 : Above & Beyond - I Am What I Am
    3 : Above & Beyond - Sirens Of The Sea
    
History

    $ dhun history
    1 files in history
    History:
    1 : Deadmau5 - I Remember Feat Kaskade (Instrumental Mix)
    
Saving Playlist

    $ dhun save_playlist /tmp/playlist.pls
    created /tmp/playlist.plsg
    
Loading Playlist

    $ dhun load_playlist /tmp/playlist.pls
    14 files queued
    loaded playlist


### Stopping Dhun

This will exit the dhun server.

    $ dhun stop_server

## Coming Soon

There are some features planned in the short run. Please file an issue with a
feature request, if you have one.

* iTunes integration

## Feedback

email me at deepak DOT jois AT gmail DOT com