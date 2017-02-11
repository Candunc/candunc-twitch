util = {}

function util.wget(input)
	local protocol = string.sub(input,1,5)
	local output = {}
	if protocol = "https" then
		local one, code, headers, status = https.request {
			url = input,
			sink = ltn12.sink.table(output),
			protocol = "tlsv1_2",
			options = "all",
			headers = {
				["Client-ID"] = CLIENT_ID,
				["Accept"] 	= "application/vnd.twitchtv.v5+json"
			},

			verify = "peer",
			cafile = "twitchtv.crt"
		}
		return table.concat(output)
	elseif protocol = "http:" then
		--Assume if we're grabbing an http page that we don't have to pass our headers.
		return (http.request(input))
	else
		print("Unknown protocol '"..protocol.."'")
	end
end

function util.file_put_contents(file,data) --Yep, using PHP's horrific naming scheme.
	local file = io.open(file,"w")
	file:write(data)
	file:close()
end

function util.stringExists(input,verify)
	local _,count = string.gsub(input,verify,"")
	if count > 0 then
		return true
	else
		return false
	end
end