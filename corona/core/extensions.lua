--adds some functionality that i want to exist in lua core language
function bind(obj, funcName)
    return function(...) return obj[funcName](obj, ...) end
end

table.deepCopy = function(orig)
	local orig_type = type(orig)
	local copy
	
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[table.deepCopy(orig_key)] = table.deepCopy(orig_value)
		end
	setmetatable(copy, table.deepCopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	
	return copy
end

function math.sign(x)
    if x<0 then
        return -1
    elseif x>0 then
        return 1
    else
        return 0
    end
end

function math.clamp( _in, low, high )
    if (_in < low ) then return low end
	if (_in > high ) then return high end
	return _in
end

runTime = 0
 
function deltaTime()
    local temp = system.getTimer()  -- Get current game time in ms
    local dt = (temp-runTime) / (1000/30)  -- 60 fps or 30 fps as base
    runTime = temp  -- Store game time
    return dt
end

print_r = function(message, obj, tabDepth)
	--todo: maybe get the func signature? metatable?
	tabDepth = tabDepth or 0
	
	local tabs = ''
	for i=1, tabDepth do
		tabs = tabs..'\t'
	end
	
	if type(obj) == 'table' then
		
		if message then
			print(tabs..'OBJ: '..message)
		end
		
		for key, val in pairs(obj) do
			if type(val) == 'table' then
				print_r(key, val, tabDepth+1)
			elseif type(val) == 'function' then
				print_r(key, 'func()', tabDepth)
			else
				print(tabs..key..': '..val)
			end
		end
		
	else
		print(tabs..message..': '..(obj or ''))
	end
end