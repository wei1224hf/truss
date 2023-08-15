local cjson = require "cjson"
local pam_json = cjson.new()
local point1_pos = {}
local point2_pos = {}
local point_pam = {}
local all_pam = {}
local x1 = 1
local x2 = 2
local y1 = 3
local y2 = 4
local n1 = 0.1
local n2 = 0.2
table.insert(point1_pos,x1)
table.insert(point1_pos,y1)
table.insert(point2_pos,x2)
table.insert(point2_pos,y2)

table.insert(point_pam,n1)
table.insert(point_pam,point1_pos)
table.insert(all_pam,point_pam)

point_pam = {}
table.insert(point_pam,n2)
table.insert(point_pam,point2_pos)
table.insert(all_pam,point_pam)

local str = pam_json.encode(all_pam)
--print(str)
local posfile = io.open("pos.cfg","w")
io.output(posfile)
io.write(str)
posfile:close()

local readfile = io.open("pos.cfg","r")
local readf = readfile:read("*a")
readfile:close()
local readf = pam_json.decode(readf)
print(readf[1][2][1])