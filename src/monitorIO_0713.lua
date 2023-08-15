local lfs = require "lfs"
local cjson = require "cjson.safe"
local lsocket = require "socket"


local function read_numdata_from_SDB(name)
	local databody = GetVarFromSDB(name,"NUMDATA")
	return databody.num
end

local function write_numdata_to_SDB(name, num)
	local databody = {}
	databody.num = num
	databody.name = name
		return SetVarToSDB(name,"NUMDATA",databody)
end

local function isAutoMode()
	local progState, taskState, cabState, masterMode, progFinished, progName = ECI.get_pgmexestate2()
	if (3==masterMode) or (4==masterMode) then
		return true
	else
		return false
	end
end


--warning:true
local function check_io_warnng(name,msg,flag)
	local tmp
	local val = GetDI(name)
	if (1 == val) and (flag == false) then
		if(flag == false) then
			BgWarning(msg)
		end
		tmp = true
	else
		tmp = false
	end
	return tmp
end

--warning:true
--stop and need reset
local function check_io_stop(name,flag)
	local tmp
	local val = GetDI(name)
	if (1 == val) and (flag == false) then
		if(flag == false) then
			ECI.stop_program()
			--BgWarning(msg)
			
			if (isAutoMode()==true) then
				ECI.set_cab_poweroff()
			end
			Sleep(50)
		end
		tmp = true
	else
		tmp = false
	end
	return tmp,val
end

--warning:true
--stop and need reset
local function check_io_low_stop(name,flag)
	local tmp
	local val = GetDI(name)
	if (0 == val) and (flag == false) then
		if(flag == false) then
			ECI.stop_program()
			--BgWarning(msg)
			ECI.set_cab_poweroff()
			Sleep(50)
		end
		tmp = true
	else
		tmp = false
	end
	return tmp,val
end

local x_p_flag = false
local x_n_flag = false
local y_p_flag = false
local x_n_flag = false
local z_p_flag = false
local z_n_flag = false

local x_p_warning = 0x0400
local x_n_warning = 0x0800
local y_p_warning = 0x1000
local y_n_warning = 0x2000
local z_p_warning = 0x4000
local z_n_warning = 0x8000


local OldOutput = 0


while true do
		local sum = 0
		local tmp
		warning_val = 0x00000000
	
		--check x positive and negative lim sensoe
		local msg="x positive lim sensor is triggered!"		
		x_p_flag = check_io_stop("DI_X_MAX",x_p_flag)
		if (x_p_flag == true) then
			warning_val = warning_val + x_p_warning
			sum = sum + 1
		end
		
		local msg="x negative lim sensor is triggered!"		
		x_n_flag = check_io_stop("DI_X_MIN",x_n_flag)
		if (x_n_flag == true) then
			warning_val = warning_val + x_n_warning
			sum = sum + 1
		end
		
		--check y positive and negative lim sensoe
		local msg="y positive lim sensor is triggered!"		
		y_p_flag = check_io_stop("DI_Y_MAX",y_p_flag)
		if (y_p_flag == true) then
			warning_val = warning_val + y_p_warning
			sum = sum + 1
		end
		
		local msg="y negative lim sensor is triggered!"		
		y_n_flag = check_io_stop("DI_Y_MIN",y_n_flag)
		if (y_n_flag == true) then
			warning_val = warning_val + y_n_warning
			sum = sum + 1
		end
		
		--check z positive and negative lim sensoe
		local msg="z positive lim sensor is triggered!"		
		z_p_flag = check_io_stop("DI_Z_MAX",z_p_flag)
		if (z_p_flag == true) then
			warning_val = warning_val + z_p_warning
			sum = sum + 1
		end
		
		local msg="z negative lim sensor is triggered!"		
		z_n_flag = check_io_stop("DI_Z_MIN",z_n_flag)
		if (z_n_flag == true) then
			warning_val = warning_val + z_n_warning
			sum = sum + 1
		end
		
		--write_numdata_to_SDB("Warning_msg", warning_val)

	Sleep(50)
end

