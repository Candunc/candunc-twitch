#!/usr/bin/which lua

get    = require("get")
util   = require("util")
json   = require("json")
socket = require("socket")
http   = require("socket.http")
https  = require("ssl.https")
ltn12  = require("ltn12")

CLIENT_ID = "y7c66dozeuhufau5a1p3xs8n0axiok"

--TODO: 
--	Actually catch errors rather than assuming everything will be alright

options = {download=true,dumpjson=false}

--[[
for _,argument in ipairs(arg) do
	if argument == "-s" then options.download = false end
	if argument == "-j" then options.dumpjson = true  end


	--_REALLY_ lazy check to see if string contains a twitch URL.
	if util.stringExists(argument,"twitch.tv") then
		--Returns the last 'path' of the string, for example https://www.twitch.tv/videos/[somenumbers] will return only [somenumbers]
		path = string.sub(input, (string.match(input,'^.*()/')+1) )
		if util.stringExists(argument,"videos") then
			--Assume twitch VOD was passed
			get.VOD(path)
		else
			--Assume twitch user was passed
			get.ChannelVODs(path)
			-- Prompt user to download certain number of the latest streams?
		end
	end
end]]