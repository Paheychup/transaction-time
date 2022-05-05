--функция записи результатов в файл
function CreateTextFile(filename, mes)
	--message("*CreateTextFile(filename, mes) mes: "..tostring(mes))
	f = io.open(getScriptPath().."\\lua_output_txt\\"..filename,"r+") --открываем файл в режиме чтение\запись
	if f == nil then -- если файла с таким названием нет, то создаем
		f = io.open(getScriptPath().."\\lua_output_txt\\"..filename,"w")
		f:close(); -- Закрывает файл
		message("file has created: "..getScriptPath().."\\lua_output_txt\\"..filename)
		f = io.open(getScriptPath().."\\lua_output_txt\\"..filename,"r+") --открываем файл в режиме чтение\запись
		f:write("type;trans_id;local_time;order_num;order_start_time;order_stop_time;delta_time;Stock;date\n")
	end -- Создает файл в режиме "записи"
	f:seek("end",0)
	f:write(mes)
	f:flush()
	f:close()
end
-----------------------------------------------------------------------------------------------------------------------------------------
