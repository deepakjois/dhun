# Introduction

> A dhun (Hindi: धुन; literally "tune") is a light instrumental piece in the
> Hindustani classical music of North India.
>
> Source : [Wikipedia](http://en.wikipedia.org/wiki/Dhun)

Dhun is a minimalist commandline music player for OS X.

It uses Spotlight to search for audio files on your computer and play them.

# Features

### Sneak Peek

    deepak@vyombook ~/code/personal/dhun (master) $ ./dhun Spirit
    Querying for kMDItemContentTypeTree == 'public.audio' && kMDItemAlbum == '*Spirit*'wc
    /Users/deepak/Dropbox/shared/music/Coke Studio/Mai-Ne.mp3
    /Users/deepak/Dropbox/shared/music/Coke Studio/Saari-Raat.mp3
    /Users/deepak/Dropbox/shared/music/Coke Studio/Bulleya.mp3
    /Users/deepak/Dropbox/shared/music/Coke Studio/Mahi-Ve.mp3
    /Users/deepak/Dropbox/shared/music/Coke Studio/Chup.mp3
    5 results total
    Now Playing /Users/deepak/Dropbox/shared/music/Coke Studio/Mai-Ne.mp3

Here is what is planned.

* Client server model, where you can issue commands to the server like
  `dhun play Spirit`, `dhun pause`, `dhun next`, `dhun prev` and `dhun stop`

* Flexible query syntax (like `artist:Rahman` or `album spirit`)

