get = {}

--Returns 10 of the lastest vods posted by the specficied channel.
function get.ChannelVODs(channel)
	-- APIv5 only supports 'numerical' channel names, this is a _very_ rough check for that
	-- https://blog.twitch.tv/action-required-twitch-api-version-update-f3a21e6c3410#.uzgyab6x1
	if tonumber(channel) == nil then
		local input = json.decode(util.wget("https://api.twitch.tv/kraken/users?login="..channel))
		channel = tonumber(input["users"][1]["_id"])
	end

	return json.decode(util.wget("https://api.twitch.tv/kraken/channels/"..channel.."/videos?broadcast_type=archive"))
end

--Gets the m3u8 files for a specific vod.
function get.VOD(vod,quality,filename)
	if quality == nil then
		--Todo: Nice error printing and stuff.
		print("Error, quality not specified.")
		return nil
	end

	-- Filename is an optional value, we'll fill in the blanks.
	if filename == nil then

	end

	--Grab title/description from here: https://dev.twitch.tv/docs/v5/reference/videos/#get-video

	-- Kinda odd how they do all this work to take output from one site and place it into another
	-- I mean, I guess vods & usher aren't documented, so maybe there is stuff behind the scenes.
	local auth = json.decode(util.wget("https://api.twitch.tv/api/vods/"..vod.."/access_token"))
	local input = util.wget("https://usher.twitch.tv/vod/"..vod.."?nauthsig="..auth["sig"].."&nauth="..auth["token"].."&allow_source=true&player=twitchweb&allow_spectre=true&allow_audio_only=true")

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
	local array = {"chunked","high","medium","low","mobile","audio_only"}

	--Index as it contains all the other media files
	local index = util.wget(formats[quality])
	local _,offset = string.find(formats[quality],array["quality"])
	local baseurl = string.sub(formats[quality],1,offset+1)

	for line in string.gmatch(index,"[^\n]+") do
		if string.sub(line,1,1) ~= "#" and line ~= "" then
			count = (count+1)
			output.ffmpeg = (output.ffmpeg.."file 'chunk_"..count..".ts'\n")
			output.aria = (output.aria..baseurl..line.."\n  out=chunk_"..count..".ts\n")
		end
	end
	util.file_put_contents("toaria.txt",output.aria)
	util.file_put_contents("toffmpeg.txt",output.ffmpeg)
	output = nil -- We don't need to keep our data in memory once we've flushed it to disk.

	-- I know I committed previously to take input via stdin, however it complicates things a lot for no reason.
	-- I also couldn't get it to work and didn't bother with debugging.
	os.execute("aria2c --download-result=hide -i toaria.txt")

	--http://superuser.com/a/1162353/607043
	os.execute("ffmpeg -loglevel panic -hide_banner -stats -f concat -i toffmpeg.txt -c copy \""..filename.."\"")
--	Replace the following string to actually encode & fix, rather than just copy.
--	os.execute("ffmpeg -loglevel panic -hide_banner -stats -i all.ts -acodec copy -vcodec copy all.mp4")
	os.execute("rm *.ts toaria.txt toffmpeg.txt")
end