dofile(getScriptPath().."\\servinfo.lua")
dofile(getScriptPath().."\\createtextfile.lua")
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function OnInit()
	servInfo()
	is_run=true 
	iterations=200
	caseVariable=3
	if  caseVariable==1 then
		Stock="CETS"
		Class_Code="CETS"
		Sec_Code="GLDRUB_TOM"
		Account="MB0139600673"
		CLIENT_CODE="101214FX"
	elseif caseVariable==2 then
		Stock="FORTS"
		Class_Code="SPBFUT"
		Sec_Code="MNM2"
		Account="4110PCS"
	elseif caseVariable==3 then
		Stock="FR"
		Sec_Code="SBER"
		Account="L01-00000F00"
		CLIENT_CODE="101214"
		Class_Code="TQBR"
	end
	
	g_lot=1
	send_order_start_time=0
	send_order_stop_time=0
	kill_order_start_time=0
	kill_order_stop_time=0
	order_num=''
	trans_id_ord='' --идентификатор транзакции trans_id
	status=nil -- статус транзакции
	--filename=server_name.."_stat_"..tostring(os.date("%Y%m%d")).."_"..tostring(timeformat(getInfoParam("LOCALTIME")))..".txt"
	filename="ITERATIONS_IPCOMMENT_"..tostring(getInfoParam("IPCOMMENT")).."_IPADDRESS_"..tostring(getInfoParam("IPADDRESS")).."_UID_"..tostring(getInfoParam("USERID")).."_"..tostring(os.date("%Y%m%d")).."_"..tostring(timeformat(getInfoParam("LOCALTIME"))).."_"..Stock..".txt"
	trans_send_order=0
	trans_kill_order=0
	stop_flag=0 --изменение значения на 1 при остановки скрипта LUA из терминала QUIK
	today_date=tostring(os.date("%Y%m%d")) --переменная текущей даты
	-- вызов функии получения информации по серверу и записи результатов в файл

end
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
--функция при остановке
function OnStop()
	stop_flag=1
	message("*OnStop trans_send_order="..tostring(trans_send_order).."\ntrans_kill_order="..tostring(trans_kill_order).." stop_flag="..tostring(stop_flag).." os.clock()="..tostring(os.clock()))
	IsRun=false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function main()
	while is_run do
		local_time=tonumber(timeformat(getInfoParam("LOCALTIME")))
		for i=1,iterations do
			if stop_flag~=1  then --and Run_flag==1
				common()
				sleep(300)
			end
		end
		is_run=false
	end
end --END MAIN
-----------------------------------------------------------------------------------------------------------------------------------------
function last()
	local last=tonumber(getParamEx(Class_Code,Sec_Code,"LAST").param_value)
end
-----------------------------------------------------------------------------------------------------------------------------------------
--ФУНКЦИИ
--========================================================================================================================================
function common()

	message("*main stop_flag="..tostring(stop_flag))
	message("*main trans_send_order="..tostring(trans_send_order))
	message("*main trans_kill_order="..tostring(trans_kill_order))
	
	serv_time = tonumber(timeformat(getInfoParam("SERVERTIME")))
	local_time=tonumber(timeformat(getInfoParam("LOCALTIME")))
	
	--если время между 4 и 5 часами
	if local_time>040000 and local_time<050000 then
		--если в переменной today_date дата не соответствует сегодняшней, то перезаписываем переменную названия файла на новый, т.е. с новой датой
		if today_date~=tostring(os.date("%Y%m%d")) then
			filename="ITERATIONS_IPCOMMENT_"..tostring(getInfoParam("IPCOMMENT")).."_IPADDRESS_"..tostring(getInfoParam("IPADDRESS")).."_UID_"..tostring(getInfoParam("USERID")).."_"..tostring(os.date("%Y%m%d")).."_"..tostring(timeformat(getInfoParam("LOCALTIME"))).."_"..Stock..".txt"
			today_date=tostring(os.date("%Y%m%d"))
		end
	end
	
	--TRADINGSTATUS ттп Статус 1- торгуется, 0 - не торгуется
	local TRADINGSTATUS=tonumber(getParamEx(Class_Code,Sec_Code,"TRADINGSTATUS").param_value)
	message("*main TRADINGSTATUS "..tostring(Sec_Code).." = "..tostring(TRADINGSTATUS))
	--LAST ттп Статус (1- торгуется, 0 - не торгуется
	local LAST=tonumber(getParamEx(Class_Code,Sec_Code,"LAST").param_value)
	message("*main LAST "..tostring(Sec_Code).." = "..tostring(LAST))
	--SEC_PRICE_STEP ттп Статус (1- торгуется, 0 - не торгуется
	local SEC_PRICE_STEP=tonumber(getParamEx(Class_Code,Sec_Code,"SEC_PRICE_STEP").param_value)
	message("*main SEC_PRICE_STEP "..tostring(Sec_Code).." = "..tostring(SEC_PRICE_STEP))
	--PRICEMIN ттп минимально возомжная цена 
	local PRICEMIN=tonumber(getParamEx(Class_Code,Sec_Code,"PRICEMIN").param_value)+SEC_PRICE_STEP
	message("*main PRICEMIN "..tostring(Sec_Code).." = "..tostring(PRICEMIN))
	
	local CHECK_PRICE=PRICEMIN+SEC_PRICE_STEP*30
	message("*main PRICE "..tostring(Sec_Code).." = "..tostring(PRICE))
	
	--************************************************************************************************
		--отправка заявки по минимально возможной цене
	if isConnected()==1 then
		if TRADINGSTATUS==1 then -- проверка, что Статус сессии - торгуется
			if LAST > CHECK_PRICE then --проверка, что текущая цена выше минимально возможной
				if (local_time>=070000 and local_time<=094900) or (local_time>=100000 and local_time<=183900) or (local_time>=190500 and local_time<=234900) then
					if trans_send_order == 0 then 
						send_order("B",g_lot,PRICEMIN,SEC_PRICE_STEP)
					end
				end
			end
		end
	end
	--************************************************************************************************	
end --END common()
--========================================================================================================================================
--========================================================================================================================================
-- отправка транзакции NEW_ORDER
function send_order(operation, quantity, price,step)
	--------------------------------------------------------------------------------------------------
	-- получение минимального шага цены для округления цены отправляемого ордера
	--local step=tonumber(getParamEx(Class_Code, Sec_Code, "SEC_PRICE_STEP").param_value)
	--message("send_order step (SEC_PRICE_STEP)="..tostring(step))
	-- end получение минимального шага цены для округления цены отправляемого ордера
	--------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------
	--получение времени сервера используя свою функцию timeformat
	serv_time = tostring(timeformat(getInfoParam("SERVERTIME"))) --исполльзуем для trans_id
	trans_id_ord=serv_time
	local_time=tonumber(timeformat(getInfoParam("LOCALTIME")))
	message("*send_order serv_time: "..tostring(serv_time).." (trans_id): "..tostring(trans_id_ord).." local_time: "..tostring(local_time))
	--end получение времени сервера используя свою функцию timeformat
	--************************************************************************************************
	
	--получение времени в секундах и млсекундах от запуска терминала QUIK
	send_order_start_time=os.clock()
	message("*send_order os.clock() send_order_start_time: "..tostring(send_order_start_time))
	--end получение времени в секундах и млсекундах от запуска терминала QUIK
	
	local trans_params = 
		{
			CLIENT_CODE = CLIENT_CODE,
			CLASSCODE = Class_Code,
			SECCODE = Sec_Code,
			ACCOUNT = Account,
			TYPE = "L",
			TRANS_ID = trans_id_ord,
			OPERATION = operation,
			QUANTITY = tostringEX(math.abs(quantity)),
			PRICE = tostringEX(math.floor(tonumber(price)/step)*step),	-- округление цены при отправлении транзакции
			ACTION = "NEW_ORDER"
			
		}
		local res = sendTransaction(trans_params)
		
		if string.len(res) ~= 0 then --если случилась ошибка, т.е. res не пустое
			message('*send_order if string.len(res)~=0 Error: '..res, 3)
			return 0
		else --если транзакция была передана
			trans_send_order = 1 --флаг, что транзакция отправлена на сервер
			message("*send_order trans_send_order: "..tostring(trans_send_order))
			return trans_id
		end
end
-- END отправка транзакции NEW_ORDER
--========================================================================================================================================
--========================================================================================================================================
-- отправка транзакции KILL_ORDER
function kill_order(order_num,trans_id)
	------------------------------------------------------------------------------------------------
	--получение времени сервера используя свою функцию timeformat
	serv_time = tostring(timeformat(getInfoParam("SERVERTIME"))) --исполльзуем для trans_id
	local_time=tonumber(timeformat(getInfoParam("LOCALTIME")))
	message("*kill_order serv_time: "..tostring(serv_time).." (trans_id): "..tostring(trans_id_ord).." local_time: "..tostring(local_time))
	--end получение времени сервера используя свою функцию timeformat
	--************************************************************************************************
	
	--получение времени в секундах и млсекундах от запуска терминала QUIK
	kill_order_start_time=os.clock()
	message("*kill_order os.clock() kill_order_start_time:"..tostring(kill_order_start_time))
	--end получение времени в секундах и млсекундах от запуска терминала QUIK
	
	local trans_params = 
		{
			CLASSCODE = Class_Code,
			SECCODE = Sec_Code,
			TRANS_ID = trans_id_ord,
			ACTION = "KILL_ORDER",
			ORDER_KEY=order_num
		}
		local res = sendTransaction(trans_params)
		
		if string.len(res) ~= 0 then
			message('*kill_order if string.len(res)~=0 Error: '..res, 3)
			return 0
		else
			trans_kill_order = 1 --флаг, что транзакция о снятии одрера отправлена на сервер
			return trans_id
			
		end	
end
-- END отправка транзакции KILL_ORDER
--========================================================================================================================================
--========================================================================================================================================
function tostringEX(x)
	return tostring(math.tointeger(x) or x)
end
--========================================================================================================================================
--========================================================================================================================================
--time format function
function timeformat(time_unf)
	local in1, in2=0,0
	local time_form=0	
	in1=string.find(time_unf, ":" , 0)
	if in1~=nil and in1~=0 then
		in2=string.find(time_unf,":" , in1+1)	
		time_form=string.sub(time_unf, 0 ,in1-1)..string.sub(time_unf, in1+1 ,in2-1)..string.sub(time_unf, in2+1 ,string.len(time_unf))
	end
	return time_form
end
--END time format function END
--========================================================================================================================================
--========================================================================================================================================
--ФУНКЦИИ ОБРАТНОГО ВЫЗОВА
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function OnTransReply(trans_reply)
	--при выставлении заявки
	message_send_order=""
	message_kill_order=""
	--if order_sent==1 then
	if trans_send_order==1 and trans_kill_order==0 then
		status=trans_reply.status
		if status~=3 then
			message("*OnTransReply sendTransaction trans_send_order="..tostring(trans_send_order).." status~=3: status: "..tostring(status).." message: "..tostring(trans_reply.result_msg), 2);
		elseif status==3 then
			send_order_stop_time=os.clock()
			order_num=tostring(trans_reply.order_num)
			trans_id_ord=tostring(trans_reply.trans_id)
			--// type --// trans_id --// local_time --// order_num --// send_order_start_time --// send_order_stop_time --// delta_time --//
			message("*OnTransReply status==3 send_order;"..trans_id_ord..";"..tostring(local_time)..";"..order_num..";"..tostring(send_order_stop_time)..";"..tostring(send_order_start_time)..";"..tostring(send_order_stop_time-send_order_start_time))
			message_send_order=("send_order;"..trans_id_ord..";"..tostring(local_time)..";"..order_num..";"..tostring(send_order_stop_time)..";"..tostring(send_order_start_time)..";"..tostring(send_order_stop_time-send_order_start_time)..";"..Stock..";"..tostring(os.date("%Y%m%d")).."\n")

			CreateTextFile(filename, message_send_order)

			if trans_kill_order==0 then kill_order(order_num,trans_id_ord) end
		end	
	--end при выставлении заявки
	--при снятии заявки
	elseif trans_kill_order==1 and trans_send_order==1  then
		status=trans_reply.status
		if status~=3 then
			message("*OnTransReply kill_order trans_kill_order="..tostring(trans_kill_order).." status: "..tostring(status).." trans_id: "..tostring(trans_reply.trans_id).." order_num:"..tostring(trans_reply.order_num).." message: "..tostring(trans_reply.result_msg), 2)
		elseif status==3 then
			kill_order_stop_time=os.clock();
			--// type --// trans_id --//order_num --// send_order_start_time --// send_order_stop_time --// delta_time --//
			message_kill_order=message("OnTransReply status==3 kill_order;"..trans_id_ord..";"..tostring(local_time)..";"..order_num..";"..tostring(kill_order_stop_time)..";"..tostring(kill_order_start_time)..";"..tostring(kill_order_stop_time-kill_order_start_time))
			message_kill_order=("kill_order;"..trans_id_ord..";"..tostring(local_time)..";"..order_num..";"..tostring(kill_order_stop_time)..";"..tostring(kill_order_start_time)..";"..tostring(kill_order_stop_time-kill_order_start_time)..";"..Stock..";"..tostring(os.date("%Y%m%d")).."\n")
			trans_send_order=0 
			trans_kill_order=0
			message("*OnTransReply trans_send_order="..tostring(trans_send_order))
			message("*OnTransReply trans_kill_order="..tostring(trans_kill_order))

			CreateTextFile(filename, message_kill_order)

		end
	--end при снятии заявки
	end
end