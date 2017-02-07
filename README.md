##candunc-twitch

In my ever increasing ~~need~~ want to cache videos on my local network rather than streaming them as per needed, I've made this.

Programs like [youtube-dl](https://github.com/rg3/youtube-dl/) have unsatisfactory download speeds and fun names like [twitch-dl](https://github.com/timothyb89/twitch-dl) and are taken, so I went with a unique but unmemorable name. The hope of this program is to provide a faster download with parallel downloads through programs like [aria2](https://aria2.github.io/), while implementing features available in more mature, but slower programs.

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