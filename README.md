# line-em-up
It's a zepplin piracy game, built on Gosu: https://rubygems.org/gems/gosu

Download repository.
Install gems.
Run `menu_launcher.rb` to start launcher, update resolution, game difficulty, start game.
Run `game_launcher.rb` to start game directly, better for code debugging.

This is a work-in-progress. A lot of debug code, a lot of inefficient code, a lot of refactoring remaining.
Demo here (no sound) (until such time that my Google Drive folder fills up): https://drive.google.com/open?id=15sTSS4MYxmB2AyMZRir3LyE1c_8ciWU0

Currently on hold, pending some Gosu related issues. Doesn't run well on windows, 20 FPS max.
Was pushing the boundaries of FPS on OS X as well, started to dip below 60 FPS on my local machine. Tried to look into concurrency solutions, but the added CPU-usage overhead of managing other processes created the same problem that it tried to solve.
