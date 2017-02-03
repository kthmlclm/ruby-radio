# Ruby BBC Radio

A ruby script to play high quality BBC streams from the command line, via VLC's cvlc command.
It also displays now/next information much quicker than navigating to the bbc website.
Basically a rewrite of my Bash BBC Radio script, with improvements.
Work in progress..

Thanks to simoncn and clanger9 at the [Linn forums](http://forums.linn.co.uk/bb/showthread.php?tid=29518&pid=348776#pid348776 "MinimStreamer") for the stream links and [Steve Seear](http://steveseear.org/high-quality-bbc-radio-streams/ "Steve Seear") for pointing the way. Also to Tom Scott at the Beeb's [radiolabs](http://www.bbc.co.uk/blogs/radiolabs/2008/05/helping_machines_play_with_pro.shtml "radiolabs") for the schedule data streams.

    $ rubio 6
    Playing BBC Radio 6 Music
    16:00 - 18:00 - Jarvis Cocker's Sunday Service
                    - John Cooper Clarke
    John Cooper Clarke sits in on the Sunday Service with two hours of classic nuggets.
    
    Next
    * 18:00 - 20:00  Now Playing @6Music
    * 20:00 - 22:00  Stuart Maconie's Freak Zone
    * 22:00 - 00:00  Don Letts' Culture Clash Radio
    * 00:00 - 02:00  Guy Garvey's Finest Hour
    

## Depends on
+ ruby
+ vlc for playing radio (has to be in single instance mode)

## Install
Download rubio, make it executable, run.

## Usage
### list all available stations
*not working yet*

    $ rubio list

### list stations matching [pattern]
*not working yet*

    $ rubio list [pattern]    eg $ rubio list scot

or

    $ rubio [pattern] list    eg $ rubio w list

### play station matching pattern
    $ rubio [pattern]    eg $ rubio 4

### stop playing
    $ rubio stop
*Will not work if VLC is not configured for single-instance mode*

### display now / next info
    rubio [pattern] now    eg $ rubio 1x now

### display the remainder of today's schedule
    rubio [pattern] later    eg $ rubio R5X later
