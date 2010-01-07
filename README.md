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
    

this fork(achiu/dhun) can be installed via rake

    $ sudo rake install
    

### Starting Dhun

    $ dhun start_server
    Starting Dhun

this runs the Dhun server as a daemon by default. to not run it as a daemon:

    $ dhun start_server --daemonize false
    or
    $ dhun start_server -d false

See `dhun help start_server for more information`

### Querying for files

Dhun uses Spotlight to query for music files. Just specify a keyword, and Dhun
will look for files matching that keyword and start playing them.

You can also query the Spotlight database before playing the files, with the 
`query` command.

    $ dhun query deadmau5

    Querying: deadmau5 | 6 Results
    0 : /Volumes/Storage/Music/Grand.Theft.Auto.IV-Radio.Station.Rips-AiTB/Electro-Choc/03 One + One - No Pressure (Deadmau5 Remix).mp3
    1 : /Volumes/Storage/Music/Grand.Theft.Auto.IV-Radio.Station.Rips-AiTB/Electro-Choc/09 Chris Lake vs. Deadmau5 - I Thought Inside Out (Original Mix).mp3
    2 : /Volumes/Storage/Music/Deadmau5 - It Sounds Like (MP3, 320bps) [2009]/01 Alone With You.mp3
    3 : /Volumes/Storage/Music/Deadmau5 - It Sounds Like (MP3, 320bps) [2009]/02 Arguru (EDX's 5un5hine Remix).mp3
    4 : /Volumes/Storage/Music/Deadmau5 - It Sounds Like (MP3, 320bps) [2009]/03 Bye Friend.mp3
    5 : /Volumes/Storage/Music/Deadmau5 - It Sounds Like (MP3, 320bps) [2009]/04 Clockwork.mp3



you can query based on certain filters such as artist,albums, title, genre and file.

    $ dhun query --artist="Paul van Dyk" --genre=trance --file 'Paul' --title in

     Querying: [nil] | artist:Paul van Dyk title:in genre:trance file:Paul
     3 Results
     0 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/08 - Paul van Dyk - Talk In Grey.mp3
     1 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/09 - Paul van Dyk - In Circles.mp3
     2 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/10 - Paul van Dyk - In Between.mp3


YOu can mix filters with regular queries as well.

    $ dhun query paul --title=haunted

    Querying: paul | title:haunted
    1 Results
    0 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/01 - Paul van Dyk - Haunted.mp3

You can also pass in multiple regular expressions too. they just need to be seperated by commas (,)

    $ dhun query paul,trance

    Querying: paul,trance | 7 Results
    0 : /Volumes/Storage/Music/Paul_Van_Dyk-Volume-3CD-2009-TSP/101-paul_van_dyk-volume__the_productions.mp3
    1 : /Volumes/Storage/Music/Paul_Van_Dyk-Volume-3CD-2009-TSP/201-paul_van_dyk-volume__the_remixes_part_1.mp3
    2 : /Volumes/Storage/Music/Paul_Van_Dyk-Volume-3CD-2009-TSP/301-paul_van_dyk-volume__the_remixes_part_2.mp3
    3 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/04 - Paul van Dyk - Complicated (Feat. Ashley Tomberlin).mp3
    4 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/01 - Paul van Dyk - Haunted.mp3
    5 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/02 - Paul van Dyk - White Lies (Feat. Jessica Sutta).mp3
    6 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/03 - Paul van Dyk - Sabotage.mp3


Now lets put it all together and go crazy.

    $ dhun query 'paul van',dyk --genre=trance --title=haunted

    Querying: paul van,dyk | title:haunted genre:trance
    1 Results
    0 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/01 - Paul van Dyk - Haunted.mp3


### Playing Files

To play the files, first enqueue the songs.

    $ dhun play paul,trance

this can also be done by

    $ dhun enqueue paul,trance

    Querying: paul,trance | 7 Results
    0 : /Volumes/Storage/Music/Paul_Van_Dyk-Volume-3CD-2009-TSP/101-paul_van_dyk-volume__the_productions.mp3
    1 : /Volumes/Storage/Music/Paul_Van_Dyk-Volume-3CD-2009-TSP/201-paul_van_dyk-volume__the_remixes_part_1.mp3
    2 : /Volumes/Storage/Music/Paul_Van_Dyk-Volume-3CD-2009-TSP/301-paul_van_dyk-volume__the_remixes_part_2.mp3
    3 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/04 - Paul van Dyk - Complicated (Feat. Ashley Tomberlin).mp3
    4 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/01 - Paul van Dyk - Haunted.mp3
    5 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/02 - Paul van Dyk - White Lies (Feat. Jessica Sutta).mp3
    6 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/03 - Paul van Dyk - Sabotage.mp3
    Enter index to queue: 

It will prompt you to enter the index of the songs you want queued.(numbers on the left side)
You can enter them separated by commas(1,2,3,4) or spaces(1 2 3 4) or a single song if you like.
If you leave the prompt blank and enter, it will queue ALL the resulting songs.

    Enter index to queue 4 5
    selected:
    0 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/01 - Paul van Dyk - Haunted.mp3
    1 : /Volumes/Storage/Music/Paul van Dyk - In Between (2007)/02 - Paul van Dyk - White Lies (Feat. Jessica     Sutta).mp3
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
    /Users/deepak/Dropbox/shared/music/3 idiots/35634_Give Me Some Sunshine.mp3
    /Users/deepak/Dropbox/shared/music/Aao Wish Karen/35612_Kuch Aisa.mp3
    /Users/deepak/Dropbox/shared/music/Coke Studio/Jo-Meray.mp3

### Other commands

Status

    $ dhun status
    Dhun is running
    Currently Playing:
    /Volumes/Storage/Music/Hydeout Productions (Second Collection)/02 Sky is Falling (feat. C.L. Smooth).mp3
    Queue:
    0 : /Volumes/Storage/Music/Hydeout Productions (Second Collection)/04 Imaginary Folklore.mp3
    1 : /Volumes/Storage/Music/Hydeout Productions (Second Collection)/05 Hikari(feat. Substantial).mp3
    
History

    $ dhun history
    1 files in history
    History:
    0 : /Volumes/Storage/Music/Hydeout Productions (Second Collection)/04 Imaginary Folklore.mp3
    

### Stopping Dhun

This will exit the dhun server.

    $ dhun stop_server

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