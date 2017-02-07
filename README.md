##twitch-dl

In my ever increasing ~~need~~ want to cache videos on my local network rather than streaming them as per needed, I've made this.

This was developed after trying out other command line programs such as [youtube-dl](https://github.com/rg3/youtube-dl/) and experiencing insanely slow speeds due to the concurrent downloads of twitch streams. Twitch streams and VODs are made up of many 1 MB ts files, and downloading recorded content (like a VOD) in parallel with programs like Aria2 allows for a much faster completion. This program will "borrow" some ideas from youtube-dl such as the [output template](https://github.com/rg3/youtube-dl#output-template).

###Requirements

| Software | Tested Version |
|----------|----------------|
| [Lua](http://www.lua.org/) | 5.3 |
| [Luasocket](http://w3.impa.br/~diego/software/luasocket/) | 3.0rc1-2 |
| [Luasec](https://github.com/brunoos/luasec) | 0.6-1 |
| [Luajson](https://github.com/harningt/luajson) | 1.3.3-1 |
| ffmpeg | 3.2.2-1~bpo8+1 |
| [aria2c](https://github.com/aria2/aria2) | 1.31.0† |

†Note: The 1.18.8 version has been tested, however is not compatible as it is missing a recent [addition](https://github.com/aria2/aria2/issues/639).

[Luarocks](https://luarocks.org/) is recommended but not required.