#!/usr/bin/which lua

json   = require("json")
socket = require("socket")
https  = require("ssl.https")
ltn12  = require("ltn12")

CLIENT_ID = "y7c66dozeuhufau5a1p3xs8n0axiok"

--TODO: 
--	Break everything into nicely sorted functions
--	Actually catch errors rather than assuming everything will be alright

function wget(input)
	--Only HTTPS Support for now
	local output = {}
	local one, code, headers, status = https.request {
		url = input,
		sink = ltn12.sink.table(output),
		protocol = "tlsv1_2",
		options = "all",
		headers = {
			["Client-ID"] = CLIENT_ID,
			["Accept"] 	= "application/vnd.twitchtv.v5+json"
		},

		verify = "none", --In the future change this to peer and specify the pem file.

	}
	return table.concat(output)
end

--Returns 10 of the lastest vods posted by the specficied channel.
function getChannelVODs(channel)
	-- APIv5 only supports 'numerical' channel names, this is a _very_ rough check for that
	-- https://blog.twitch.tv/action-required-twitch-api-version-update-f3a21e6c3410#.uzgyab6x1
	if tonumber(channel) == nil then
		local input = json.decode(wget("https://api.twitch.tv/kraken/users?login="..channel))
		channel = tonumber(input["users"][1]["_id"])
	end

	return json.decode(wget("https://api.twitch.tv/kraken/channels/"..channel.."/videos?broadcast_type=archive"))
end

--Gets the m3u8 files for a specific vod.
function getVOD(vod) --Maybe pass filename here?
	local quality = 1 --Hardcoded for now; this picks source quality.
--	local array = {"chunked",""}

	-- Kinda odd how they do all this work to take output from one site and place it into another
	-- I mean, I guess vods & usher aren't documented, so maybe there is stuff behind the scenes.
	local auth = json.decode(wget("https://api.twitch.tv/api/vods/"..vod.."/access_token"))
	local input = wget("https://usher.twitch.tv/vod/"..vod.."?nauthsig="..auth["sig"].."&nauth="..auth["token"].."&allow_source=true&player=twitchweb&allow_spectre=true&allow_audio_only=true")

	-- Although this part looks ugly, it creates a numbered array from 1-6, where:
	-- 1 is highest (chunked) quality, 5 is lowest (mobile) quality, and 6 is audio only
	local formats = {}
	for line in string.gmatch(input,"[^\n]+") do
		--Ignore comments or empty lines
		if string.sub(line,1,1) ~= "#" and line ~= "" then
			table.insert(formats,line)
		end
	end

	local count = 0
	local output = {ffmpeg="",aria=""}
	--Index as it contains all the other media files
	local index = wget(formats[quality])
	local _,offset = string.find(formats[quality],"chunked") --Another hardcoded value to fix later.
	local baseurl = string.sub(formats[quality],1,offset+1)

	for line in string.gmatch(index,"[^\n]+") do
		if string.sub(line,1,1) ~= "#" and line ~= "" then
			count = (count+1)
			output.ffmpeg = (output.ffmpeg.."file 'chunk_"..count..".ts'\n")
			output.aria = (output.aria..baseurl..line.."\n  out=chunk_"..count..".ts\n")
		end
	end

	--Untested, but I believe this should avoid using files for input.
	os.execute("echo \""..string.gsub(output.aria,"\"","\\\"").."\" | aria2c --download-result=hide -i -")

	--http://superuser.com/a/1162353/607043
	--https://ffmpeg.org/ffmpeg-protocols.html#toc-pipe
	os.execute("echo \""..string.gsub(output.ffmpeg,"\"","\\\"").."\" | ffmpeg -hide_banner -f concat -i pipe:0 -c copy all.ts")
	os.execute("ffmpeg -hide_banner -i all.ts -acodec copy -vcodec copy all.mp4")
	os.execute("rm *.ts")
end

--Following functions are roughly tested, however none of the other bits of the program have been implemented.