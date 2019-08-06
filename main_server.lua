-- FiveM YumV plugin by Akkariin
-- This plugin is an open-source project
-- Use GPL v3 License
-- https://github.com/kasuganosoras/yumv

local yum = {}

-- FiveM YumV config
yum.mirror = "https://yumv.net/"
yum.version = "1.0.1"
yum.versionnum = 1
-- End

local downloading = 0
local current_dir = string.gsub(GetResourcePath(GetCurrentResourceName()), "//", "/")

-- 解压文件
function unzip(s, d)
	os.execute("unzip -q -o '" .. s .. "' -d '" .. d .. "'")
end

-- 网络请求
function curl(url, method, data, headers, timeout)
	
	if url == nil then
		return 'url undefined'
	end
	
	if method == nil then
		method = 'GET'
	end
	
	if data == nil then
		data = ''
	end
	
	if headers == nil then
		headers = {}
	end
	
	if timeout == nil then
		timeout = 5000
	end
	
	local curl_result = {}
	
	if string.lower(method) == 'post' then
		local postString = ''
		for i, v in pairs(data) do
			postString = postString .. i .. "=" .. urlencode(v) .. "&"
		end
		postString = string.sub(postString, 1, string.len(postString) - 1)
		headers["Content-Type"] = 'application/x-www-form-urlencoded'
		PerformHttpRequest(url, function (errorCode, resultData, resultHeaders)
			curl_result.status = errorCode
			curl_result.body = resultData
			curl_result.header = resultHeaders
		end, method, postString, headers)
	else
		PerformHttpRequest(url, function (errorCode, resultData, resultHeaders)
			curl_result.status = errorCode
			curl_result.body = resultData
			curl_result.header = resultHeaders
		end, method, data, headers)
	end
	whilewait = 0
	while curl_result.status == nil do
		Wait(1)
		if whilewait > timeout then
			break
		else
			whilewait = whilewait + 1
		end
	end
	return curl_result
end

-- URL 编码器
function urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str    
end

-- URL 解码器
function urldecode(s)
	s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
	return s
end

-- 读取文件
function file_get_contents(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

-- 执行命令
function shell_exec(command)
	os.execute(command .. " > /tmp/fivem-yum-shell-output.log")
	result = file_get_contents('/tmp/fivem-yum-shell-output.log')
	os.remove('/tmp/fivem-yum-shell-output.log')
	return result
end

-- 实时输出的 shell-output
function realtimeShell(cmd)
	f = assert(io.popen(cmd))
	for line in f:lines() do
		print(line)
	end
	f:close()
end

-- 检测文件是否存在
function file_exists(name)
    if type(name)~="string" then return false end
    return os.rename(name,name) and true or false
end

-- 写入文件
function file_put_contents(name, data, append)
	if append == true then
		writemode = "a"
	else
		writemode = "w"
	end
	file = io.open(name, writemode)
	file:write(data)
	file:close()
end

-- 遍历 table
function forEach(tb)
	for key, value in pairs(tb) do      
		print(key .. " => " .. value)  
	end
end

-- 取字符串长度
function strlen(str)
	local _,n = str:gsub('[\128-\255]', '')
	return #str - n / 2
end

-- 列出所有插件
function listAllPlugin(tb)
	print("+----------------------------------+------------------+")
	print("| Name                             | Version          |")
	print("+----------------------------------+------------------+")
	local i = 0
	for key, value in pairs(tb) do
		i = i + 1
		local padding = " "
		local padding2 = " "
		local length = strlen(value.name)
		local length2 = strlen(tostring(value.version))
		if length <= 32 then
			padding = string.rep(" ", 32 - length)
		end
		if length2 <= 32 then
			padding2 = string.rep(" ", 32 - length2)
		end
		print("| " .. value.name .. padding .. " | " .. tostring(value.version) .. padding2 .. " |")
	end
	local length3 = strlen(tostring(i))
	padding3 = string.rep(" ", 51 - length3 - 19)
	print("+----------------------------------+------------------+")
	print("| Total: " .. tostring(i) .. " resource(s)" .. padding3 .. " |")
	print("+-----------------------------------------------------+")
end

-- 加载所有插件
function loadPluginList()
	if file_exists(current_dir .. "/list.json") then
		local data = file_get_contents(current_dir .. "/list.json")
		data = json.decode(data)
		if data.list == nil then
			print("[YumV] No plugin installed")
		else
			for key, value in pairs(data.list) do
				print("[YumV] Loading plugin: " .. value.name)
				StartResource(value.name)
			end
		end
	else
		print("[YumV] Cannot found resources list! Please use \"yum fix-list\" to fix it!")
	end
end

-- 检查插件是否已安装（包括非 yum 安装的插件）
function checkPluginExist(name)
	if file_exists(current_dir .. "/list.json") then
		local data = file_get_contents(current_dir .. "/list.json")
		data = json.decode(data)
		if data.list == nil then
			print("[YumV] No plugin installed")
		else
			for key, value in pairs(data.list) do
				if value.name == name then
					return true
				end
			end
		end
	else
		print("[YumV] Cannot found resources list! Please use \"yum fix-list\" to fix it!")
	end
	local resource_status = GetResourceState(name)
	if resource_status == "missing" or resource_status == "stopped" then
		return false
	else
		return true
	end
end

-- 检查插件是否已安装（仅限 yum 安装的插件）
function checkPluginInList(name)
	if file_exists(current_dir .. "/list.json") then
		local data = file_get_contents(current_dir .. "/list.json")
		data = json.decode(data)
		if data.list == nil then
			print("[YumV] No plugin installed")
		else
			for key, value in pairs(data.list) do
				if value.name == name then
					return true
				end
			end
		end
	else
		print("[YumV] Cannot found resources list! Please use \"yum fix-list\" to fix it!")
	end
	return false
end

-- 获取插件版本号
function getPluginVersion(name)
	if file_exists(current_dir .. "/list.json") then
		local data = file_get_contents(current_dir .. "/list.json")
		data = json.decode(data)
		if data.list == nil then
			return false
		else
			for key, value in pairs(data.list) do
				if value.name == name then
					return value.version
				end
			end
		end
	else
		print("[YumV] Cannot found resources list! Please use \"yum fix-list\" to fix it!")
	end
	return false
end

-- 从列表中删除一个插件
function removePluginFromList(name)
	if file_exists(current_dir .. "/list.json") then
		local data = file_get_contents(current_dir .. "/list.json")
		data = json.decode(data)
		if data.list == nil then
			print("[YumV] No plugin installed")
		else
			for key, value in pairs(data.list) do
				if value.name == name then
					table.remove(data.list, key)
					file_put_contents(current_dir .. "/list.json", json.encode(data))
					return true
				end
			end
		end
	else
		print("[YumV] Cannot found resources list! Please use \"yum fix-list\" to fix it!")
	end
	return false
end

-- 增加一个新插件到列表
function addNewPlugin(name, version)
	local data = file_get_contents(current_dir .. "/list.json")
	data = json.decode(data)
	if data.list == nil then
		data.list = {}
	end
	table.insert(data.list, {name = name, version = version})
	file_put_contents(current_dir .. "/list.json", json.encode(data))
end

-- 安装插件
function installPlugin(name, version)
	local url = ""
	if version == nil then
		url = yum.mirror .. "?s=download&name=" .. urlencode(name)
	else
		url = yum.mirror .. "?s=download&name=" .. urlencode(name) .. "&version=" .. urlencode(version)
	end
	local rs = curl(url, 'GET')
	if rs.status == 200 then
		local plugin_name = rs.header.plugin
		local plugin_version = rs.header.version
		local plugin_size = rs.header.size
		local plugin_rsize = rs.header.realsize
		downloading = plugin_rsize
		if (rs.header.depend == nil) == false then
			depend = json.decode(rs.header.depend)
			for key, value in pairs(depend) do
				if checkPluginExist(value.name) == false then
					print("[YumV] Plugin " .. name .. " has depend " .. value.name .. " need to install")
					local result = installPlugin(value.name, value.version)
					if result == false then
						print("[YumV] Depend " .. value.name .. " install failed!")
					end
				end
			end
		end
		if plugin_name == nil or plugin_version == nil then
			print("[YumV] An error occurred when fetch the command name")
			return false
		else
			if checkPluginExist(plugin_name) == false then
				print("[YumV] Found plugin: " .. plugin_name)
				if not file_exists(current_dir .. "/../[YumV-plugins]/" .. plugin_name .. "/") then
					os.execute("mkdir -p '" .. current_dir .. "/../[YumV-plugins]/" .. plugin_name .. "/'")
				end
				print("[YumV] Downloading: " .. rs.body .. " => /tmp/fivem-yum-temp.zip (" .. plugin_size .. ")")
				local cmd = "wget -q -4 \"" .. rs.body .. "\" -O \"/tmp/fivem-yum-temp.zip\" &"
				-- print(cmd)
				file_put_contents("/tmp/fivem-yum-temp.zip", "")
				-- 开始下载
				os.execute(cmd)
				local finished = false
				local last = 0
				local speed = 0
				local dspeed = ""
				while finished == false do
					local f = assert(io.open("/tmp/fivem-yum-temp.zip", "rb"))
					local size = f:seek("end")
					f:close()
					if size >= tonumber(plugin_rsize) then
						finished = true
					end
					speed = size - last
					last = size
					if speed < 1048576 then
						dspeed = string.format("%.2f", speed / 1024) .. "KB/s"
					else
						dspeed = string.format("%.2f", speed / 1048576) .. "MB/s"
					end
					finish = tostring((size / tonumber(plugin_rsize)) * 100)
					finish = string.format("%.2f", finish)
					io.write("\r[YumV] Download status: " .. tostring(finish) .. "% - " .. dspeed .. "           ")
					Wait(1000)
				end
				print("")
				Wait(1000)
				print("[YumV] Download finished, decompressing... ")
				unzip('/tmp/fivem-yum-temp.zip', current_dir .. "/../[YumV-plugins]/" .. rs.header.plugin .. "/")
				ExecuteCommand("refresh")
				io.write("[YumV] ")
				if StartResource(plugin_name) then
					addNewPlugin(plugin_name, tonumber(plugin_version))
					print("[YumV] Plugin " .. plugin_name .. " install successful!")
					return true
				else
					print("[YumV] Failed to start resource! please check your console output to see more info.")
					return false
				end
			else
				print("[YumV] Plugin already installed! please use \"yum update " .. plugin_name .. "\" to update it, or use \"yum remove " .. plugin_name .. "\" to remove it!")
				print("[YumV] Current resource status: " .. GetResourceState(plugin_name))
				return true
			end
		end
	else
		print("[YumV] Cannot install '" .. name .. "', server return error: " .. rs.status)
		return false
	end
end

-- 输出帮助信息
function printHelp()
	print("FiveM YumV plugin by Akkariin")
	print("Usage: yum <command> [args]")
	print("")
	print("Commands:")
	print("    install <plugin> [version]    Install a new plugin to server")
	print("    remove <plugin>               Delete the plugin from server")
	print("    update <plugin>               Update a plugin to new version")
	print("    check <plugin>                Check whether a plugin has a new version")
	print("    search <name>                 Search a plugin in mirror database")
	print("    list                          List all installed plugin")
	print("    version                       Show the yum plugin version")
end

-- 注册命令
RegisterCommand("yum", function(source, args, rawCommand)
	-- 默认的帮助
    if args[1] == nil or args[1] == "help" then
		printHelp()
	else
		if args[1] == "test" then
			local f = assert(io.open("/tmp/fivem-yum-temp.zip", "rb"))
			local size = f:seek("end")
			f:close()
			print(size)
			
		-- 删除一个插件
		elseif args[1] == "remove" then
			if args[2] == nil then
				print("[YumV] Please provide the plugin name you want to remove: yum remove <name>")
			else
				if checkPluginInList(args[2]) then
					StopResource(args[2])
					os.execute("rm -rf '" .. current_dir .. "/../[YumV-plugins]/" .. args[2] .. "/'")
					if removePluginFromList(args[2]) then
						print("[YumV] Plugin delete successful!")
					else
						print("[YumV] Failed to delete this plugin!")
					end
				else
					print("[YumV] Cannot found this plugin, maybe it is not install by YumV?")
				end
			end
			
		-- 修复列表错误
		elseif args[1] == "fix-list" then
			if file_exists(current_dir .. "/list.json") then
				print("[YumV] The resource list already exist, not need to fix!")
			else
				file_put_contents(current_dir .. "/list.json", json.encode(
					{
						version = "1.0", list = {}
					}
				))
				print("[YumV] Successful fix the plugin list")
			end
			
		-- 列出已安装的插件
		elseif args[1] == "list" then
			if file_exists(current_dir .. "/list.json") then
				local data = file_get_contents(current_dir .. "/list.json")
				data = json.decode(data)
				if data.list == nil then
					print("[YumV] No plugin installed")
				else
					listAllPlugin(data.list)
				end
			else
				print("[YumV] Cannot found resources list! Please use \"yum fix-list\" to fix it!")
			end
			
		-- 搜索一个插件
		elseif args[1] == "search" then
			if args[2] == nil then
				print("[YumV] Please provide the plugin name you want to search: yum search <name>")
			else
				print("Loading data from mirror server...")
				local url = yum.mirror .. "?s=search&name=" .. urlencode(args[2])
				local rs = curl(url, 'GET')
				print("")
				print(rs.body)
			end
			
		-- 安装一个插件
		elseif args[1] == "install" then
			if args[2] == nil then
				print("[YumV] Please provide the plugin name you want to install: yum install <name>")
			else
				CreateThread(function()
					print("")
					if args[3] == nil then
						local result = installPlugin(args[2])
					else
						local result = installPlugin(args[2], args[3])
					end
					if result == false then
						print("[YumV] One or more plugin(s) install failed, please check your console output for more info.")
					else
						print("[YumV] All plugin(s) install successful.")
					end
				end)
			end
			
		-- 更新一个插件
		elseif args[1] == "update" then
			if args[2] == nil then
				print("[YumV] Please provide the plugin name you want to install: yum install <name>")
			else
				if checkPluginInList(args[2]) then
					local updateurl = yum.mirror .. "?s=download&name=" .. urlencode(args[2])
					local rs = curl(updateurl, 'GET')
					print("")
					if rs.status == 200 then
						local plugin_name = rs.header.plugin
						local plugin_version = tonumber(rs.header.version)
						local local_version = tonumber(getPluginVersion(plugin_name))
						if local_version == false then
							print("[YumV] Cannot update '" .. args[2] .. "', failed to get local version, please check your list.json!")
						else
							if plugin_version > local_version then
								if not file_exists(current_dir .. "/../[YumV-plugins]/" .. plugin_name .. "/") then
									os.execute("mkdir -p '" .. current_dir .. "/../[YumV-plugins]/" .. plugin_name .. "/'")
								end
								print("[YumV] Downloading: " .. rs.body)
								local cmd = "wget -q -4 \"" .. rs.body .. "\" -O \"/tmp/fivem-yum-temp.zip\""
								-- print(cmd)
								os.execute(cmd)
								print("[YumV] Download finished, deleting old version... ")
								StopResource(args[2])
								os.execute("rm -rf '" .. current_dir .. "/../[YumV-plugins]/" .. args[2] .. "/'")
								removePluginFromList(plugin_name)
								print("[YumV] Decompressing file... ")
								unzip('/tmp/fivem-yum-temp.zip', current_dir .. "/../[YumV-plugins]/" .. rs.header.plugin .. "/")
								ExecuteCommand("refresh")
								if StartResource(plugin_name) then
									addNewPlugin(plugin_name, plugin_version)
									print("[YumV] Plugin update successful!")
								else
									print("[YumV] Failed to start resource! please check your console output to see more info.")
								end
							else
								print("[YumV] Your plugin is already up to date!")
							end
						end
					else
						print("[YumV] Cannot update '" .. args[2] .. "', server return error: " .. rs.status)
					end
				else
					print("[YumV] Cannot update '" .. args[2] .. "', plugin not installed.")
				end
			end
			
		-- 检查插件是否有更新
		elseif args[1] == "check" then
			if args[2] == nil then
				print("[YumV] Please provide the plugin name you want to check: yum check <name>")
			else
				if checkPluginInList(args[2]) then
					local updateurl = yum.mirror .. "?s=download&name=" .. urlencode(args[2])
					local rs = curl(updateurl, 'GET')
					print("")
					if rs.status == 200 then
						local plugin_name = rs.header.plugin
						local plugin_version = tonumber(rs.header.version)
						local local_version = tonumber(getPluginVersion(plugin_name))
						if local_version == false then
							print("[YumV] Cannot update '" .. args[2] .. "', failed to get local version, please check your list.json!")
						else
							if plugin_version > local_version then
								print("[YumV] This plugin has a new version: " .. tostring(plugin_version) .. ". The version you have installed is: " .. tostring(local_version))
							else
								print("[YumV] Your plugin is already up to date!")
							end
						end
					else
						print("[YumV] Cannot check update for '" .. args[2] .. "', server return error: " .. rs.status)
					end
				else
					print("[YumV] Cannot check update for '" .. args[2] .. "', plugin not installed.")
				end
			end
			
		-- 获取 yum 版本号
		elseif args[1] == "version" then
			print("FiveM YumV plugin by Akkariin")
			print("Version: " .. yum.version)
			
		-- 默认输出
		else
			print("Command not found: " .. args[1] .. ", use \"yum help\" to get help.")
		end
	end
end, true)

-- Load all installed plugins
loadPluginList()
