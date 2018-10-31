local L = select(2, ...)[2]('enUS')

-- Default tab names
L['GUILD'] = GUILD
L['FRIENDS'] = FRIENDS

-- Column Headers
L['LEVEL'] = LEVEL
L['DUNGEON'] = DUNGEONS
L['CHARACTER'] = CHARACTER
L['10+'] = '10+'

-- Subsection Headers
L['CHARACTERS'] = 'CHARACTERS'
L['AFFIXES'] = 'AFFIXES'

-- Character Labels
L['CURRENT_KEY'] = 'CURRENT'
L['WEEKLY_BEST'] = 'WKLY BEST'

L['CHARACTER_DUNGEON_NOT_RAN'] = 'No mythic+ ran'
L['CHARACTER_KEY_NOT_FOUND'] = 'No key found'


-- Dropdown menu selections
L['Whisper'] = WHISPER
L['INVITE'] = INVITE
L['SUGGEST_INVITE'] = SUGGEST_INVITE
L['REQUEST_INVITE'] = REQUEST_INVITE
L['Cancel'] = CANCEL

local function empty(T)
	for k,v in pairs(T) do T[k] = nil; end
end


--- Append a string to the concatBuffer object
-- @param buf The ConcatBuffer object
-- @param str The string to append
local function cbappend(buf, str)
	tinsert(buf, str);
	for i=(#buf - 1), 1, -1 do
		if strlen(buf[i]) > strlen(buf[i+1]) then break; end
		buf[i] = buf[i] .. tremove(buf);
	end
end

--- Tostring the concatBuffer object
-- @param buf The ConcatBuffer object
-- @return The string text
local function cbtostr(buf)
	for i=(#buf - 1), 1, -1 do
		buf[i] = buf[i] .. tremove(buf);
	end
	return buf[1];
end


local gmatch, char, byte, strlen = string.gmatch, string.char, string.byte, string.len;
local bor, rshift, band, lshift = bit.bor, bit.rshift, bit.band, bit.lshift;
local tinsert, tempty = table.insert, empty;
--local cbappend, cbtostr = ConcatBuffer.append, ConcatBuffer.toString;

-- implementation of a 12-bit LZW compressor in Lua
-- Jim Zajkowski, 8 September 2006
--
-- Note that LZW needs at least 72 bytes before it will start to show space savings,
-- that's because every input byte, at first, is represented by 12 bits until the
-- dictionary becomes more complete.
--
-- Note that I tried, for performance, to use some form of strlen and string.sub
-- intead of the use of gfind - testing a thousand runs revealed only a marginal
-- speed improvement but a substantial loss in clarity.
--
-- I believe the best speed improvement will come by removing the intermediate symbol tables.

local temp, dict, cb = {}, {}, {};

function lzw_compress(input)
	if not input then return nil; end
	local i, j, c, q, pack, upper_12, lower_12
	local b1, b2, b3;

	--- Assume all tables are in pristine state; clean up at the end of each pass.
	
	-- initialize the dictionary
	for i=0,255 do dict[char(i)] = i;end

	--------------------------------- PHASE 1: LZW ALGORITHM
	local next_code, acc = 256, "";

	for c in gmatch(input, ".") do
		if dict[acc .. c] then
			acc = acc .. c;
		else
			tinsert(temp, dict[acc]);
			dict[acc .. c] = next_code; 
			next_code = next_code + 1;
			acc = c;
		end
 	end
	tinsert(temp, dict[acc]);

	print("next_code = ",next_code);

	-- We're done with the dictionary; discard it
	tempty(dict);

	------------------------------- PHASE 2: SWIZZLE
	-- convert the out table to a string, packing 12 bytes as we go
	for i=1,#temp,2 do
		upper_12 = temp[i];
		lower_12 = temp[i+1] or 0;
	
		-- the visual aids:
		-- ABCD12345678:ABCD12345678  -- upper 12, lower 12
		-- ABCD1234:5678ABCD:12345678 -- byte_a, byte_b, byte_c
	
		b1 = rshift(upper_12, 4);	-- upper 8 bits of upper_12 (abcd1234)
		b3 = band(lower_12, 255);	-- lower 8 bits of lower_12 (12345678)
		
		-- move upper_12 left so the bottom four bits are in the upper 4 of byte_b, 
		-- mask off just the upper four (5678), then add in the upper 4 bits from 
		-- lower_12 into the lower 4 of byte_b (abcd)
		b2 = bor( band( lshift(upper_12, 4), 240), rshift(lower_12, 8) );

		-- Determine if any of these characters need to be escaped
		-- 0 -> 254	-- 255 -> 255 255	-- 254 -> 255 254	-- 10 -> 255 253 -- 124 -> 255 252
		-- Fully unrolled for speed.
		if b1 == 0 then 
			cbappend(cb, char(254));
		elseif b1 == 255 then
			cbappend(cb, char(255, 255));
		elseif b1 == 254 then
			cbappend(cb, char(255, 254));
		elseif b1 == 10 then
			cbappend(cb, char(255, 253));
		elseif b1 == 124 then
			cbappend(cb, char(255, 252));
		else
			cbappend(cb, char(b1));
		end

		if b2 == 0 then 
			cbappend(cb, char(254));
		elseif b2 == 255 then
			cbappend(cb, char(255, 255));
		elseif b2 == 254 then
			cbappend(cb, char(255, 254));
		elseif b2 == 10 then
			cbappend(cb, char(255, 253));
		elseif b2 == 124 then
			cbappend(cb, char(255, 252));
		else
			cbappend(cb, char(b2));
		end

		if b3 == 0 then 
			cbappend(cb, char(254));
		elseif b3 == 255 then
			cbappend(cb, char(255, 255));
		elseif b3 == 254 then
			cbappend(cb, char(255, 254));
		elseif b3 == 10 then
			cbappend(cb, char(255, 253));
		elseif b3 == 124 then
			cbappend(cb, char(255, 252));
		else
			cbappend(cb, char(b3));
		end
	end

	-- Cleanup and exit.
	local ret = cbtostr(cb);
	tempty(temp); tempty(cb);
	return ret;
end

function lzw_decompress(input)
	-- Sanity-check inputs.
	if type(input) ~= "string" then return nil; end
	
	local err = nil;
	local i, c, upper_12, lower_12, byte_a, byte_b, byte_c;
	
	-- initialize the reverse dictionary
	for i = 0, 255 do	dict[i] = char(i); end

	---------------------------------- PHASE 1: DESWIZZLE
	-- Take the 12-bit compressed stream from above and recompose it in the temp array.
	i = 0; c = strlen(input);
	while i < c do
		-- Unescape bytes. Fully unrolled for speed.
		i=i+1; byte_a = byte(input, i);
		if byte_a == 254 then
			byte_a = 0;
		elseif byte_a == 255 then
			i=i+1;
			byte_a = byte(input, i);
			if byte_a == 253 then byte_a = 10; elseif byte_a == 252 then byte_a = 124; end
		end

		i=i+1; byte_b = byte(input, i);
		if byte_b == 254 then
			byte_b = 0;
		elseif byte_b == 255 then
			i=i+1;
			byte_b = byte(input, i);
			if byte_b == 253 then byte_b = 10; elseif byte_b == 252 then byte_b = 124; end
		end

		i=i+1; byte_c = byte(input, i);
		if byte_c == 254 then
			byte_c = 0;
		elseif byte_c == 255 then
			i=i+1;
			byte_c = byte(input, i);
			if byte_c == 253 then byte_c = 10; elseif byte_c == 252 then byte_c = 124; end
		end

		-- Stop if there's a problem.
		if (not byte_a) or (not byte_b) or (not byte_c) then err = true; break; end

		-- Bit-twiddle the bytes into 12-lets
		upper_12 = bor( lshift(byte_a, 4), rshift(byte_b, 4) );
		lower_12 = bor( lshift( band(byte_b, 15), 8 ), byte_c );
		-- Insert the 12-lets into the decoding stream
		tinsert(temp, upper_12);
		if lower_12 ~= 0 then tinsert(temp, lower_12); end
	end

	-- Exit out if the string was malformed.
	if err then return nil; end

	--------------------------------- PHASE 2: INVERSE LZW
	local next_code, tc = 256, nil;

	-- Decode the first character
	local acc = table.remove(temp, 1);
	cbappend(cb, dict[acc]);

	-- Decode the remainder of the characters
	for i, c in ipairs(temp) do
		local dictentry = dict[c];
		if dictentry then
			cbappend(cb, dictentry);
			dict[next_code] = dict[acc] .. string.sub(dictentry, 1, 1);         
			next_code = next_code + 1;
		else
			local x = dict[acc];
			tc = x .. string.sub(x, 1, 1);
			next_code = next_code + 1;
			cbappend(cb, tc);
			dict[c] = tc;
		end
		acc = c;
	end

	-- Compile the output
	local ret = cbtostr(cb);
	tempty(cb); tempty(temp); tempty(dict);
	
	return ret;
end

function wow_sanitize(s)
	local outstring = "";
	local i;
	
	for i = 1, string.len(s) do
		b = string.byte(s, i);
		if (b == 0) then
			outstring = outstring .. string.char(253);
		elseif (b == 254) then
			outstring = outstring .. string.char(254, 254);
		elseif (b == 253) then
			outstring = outstring .. string.char(254, 250);
		elseif (b == 10) then
			outstring = outstring .. string.char(254, 251);
		elseif (b == 124) then
			outstring = outstring .. string.char(254, 252);
		else
			outstring = outstring .. string.char(b);
		end
	end

	return outstring;
end

function wow_desanitize(s)
	local outstring = "";
	local i = 1;

	while (i <= string.len(s)) do
		b = string.byte(s, i);
		i = i + 1;
		
		if (b == 253) then
			outstring = outstring .. string.char(0);

		elseif (b == 254) then
			b2 = string.byte(s, i);
			i = i + 1;
			
			if (b2 == 254) then
				outstring = outstring .. string.char(254);
			elseif (b2 == 250) then
				outstring = outstring .. string.char(253);
			elseif (b2 == 251) then
				outstring = outstring .. string.char(10);
			elseif (b2 == 252) then
				outstring = outstring .. string.char(124);
			end
		else
			outstring = outstring .. string.char(b);
		end
	end
	return outstring;
end

function comp_test(x)
	local cmp = lzw_compress(x);
	local decmp = lzw_decompress(cmp);
	print("clen " .. strlen(cmp) .. ", olen " .. strlen(x) .. ", ratio " .. strlen(x)/strlen(cmp) .. ")");
	if(decmp ~= x) then print("WRONG"); end
end


local pairs = pairs;
local type = type;
local tostring = tostring;
local loadstring = loadstring;
local setfenv = setfenv;
local strformat, strsub, strlen = string.format, string.sub, string.len;
local tgetn = table.getn;
local dsFunc;


local ti; -- number

local function GetEntryCount(tbl)
	ti = 0;
	for _,_ in pairs(tbl) do ti = ti + 1; end
	return ti;
end

--- Serialize an object and return a string
function Serialize(obj)
	if(obj == nil) then
		return "";
	elseif (type(obj) == "string") then
		return strformat("%q", obj);
	elseif (type(obj) == "table") then
		local str = "{ ";
		if obj[1] and ( tgetn(obj) == GetEntryCount(obj) ) then
			-- Array case
			for i=1,tgetn(obj) do str = str .. Serialize(obj[i]) .. ","; end
		else
			-- Nonarray case
			for k,v in pairs(obj) do
				if (type(k) == "number") then
					str = str .. "[" .. k .. "]=";
				elseif (type(k) == "string") then
					str = str .. '["' .. k .. '"]=';
				else
					error("bad table key type");
				end
				str = str .. Serialize(v) .. ",";
			end
		end
		-- Strip trailing comma, tack on syntax
		return strsub(str, 0, strlen(str) - 1) .. "}";
	elseif (type(obj) == "number") then
		return tostring(obj);
	elseif (type(obj) == "boolean") then
		return obj and "true" or "false";
	else
		error("could not serialize object of type " .. type(obj));
	end
end

emptyTable = {}

--- Deserialize a string and return the object
function Deserialize(data)
	if not data then return nil; end
	dsFunc = loadstring("return " .. data);
	if dsFunc then 
		-- Prevent the deserialization function from making external calls
		setfenv(dsFunc, emptyTable);
		-- Call the deserialization function
		return dsFunc();
	else 
		return nil; 
	end
end