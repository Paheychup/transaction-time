function servInfo()
	local file
	--local FileNameWrite=(getScriptPath().."\\lua_output_txt\\servInfo_"..tostring(os.date("%Y%m%d"))..".txt")
	local FileNameWrite=(getScriptPath().."\\lua_output_txt\\servInfo.txt")

	    --[[params = {"VERSION", "TRADEDATE", "SERVERTIME",
                "LASTRECORDTIME", "NUMRECORDS", "LASTRECORD","LATERECORD",
                "CONNECTION", "IPADDRESS", "IPPORT", "IPCOMMENT",
                "SERVER", "SESSIONID", "USER", "USERID", "ORG", "MEMORY",
                "LOCALTIME", "CONNECTIONTIME", "MESSAGESSENT", "ALLSENT",
                "BYTESSENT", "BYTESPERSECSENT", "MESSAGESRECV", "BYTESRECV",
                "ALLRECV", "BYTESPERSECRECV", "AVGSENT", "AVGRECV",
                "LASTPINGTIME", "LASTPINGDURATION", "AVGPINGDURATION",
                "MAXPINGTIME", "MAXPINGDURATION"}]]--
				
		params = {"VERSION", "TRADEDATE","IPADDRESS", "IPPORT", "IPCOMMENT"}
				
    file = io.open(FileNameWrite, "a")
    for key,v in ipairs(params) do
        file:write(v .. " = " .. getInfoParam(v) .. "\n")
    end
    file:close()
end