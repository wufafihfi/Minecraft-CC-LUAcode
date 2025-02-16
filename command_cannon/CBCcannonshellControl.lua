local GUI = require("gui")
term.setTextColour(0x20)
print("----------WaiShe----------")
local NamesTable = peripheral.getNames()
local peripherals = {}
term.setTextColour(0x1)
local i = 1
for k,v in ipairs(NamesTable) do
    print(k,"|",v,"-->",peripheral.getType(v))
    local peripheralName = peripheral.getType(v)
    if(peripheralName == "modem")then
        rednet.open(v)
    end
    if(peripheralName == "Created_RotationSpeedController" or peripheralName == "cbcmodernwarfare:compact_mount")then
        peripherals[string.format("%s_%d", peripheralName,i)] = peripheral.find(peripheralName)
        i = i + 1
    else
        peripherals[peripheralName] = peripheral.find(peripheralName)
    end
end
local CBC_CM = peripherals["cbcmodernwarfare:compact_mount_1"]
term.setTextColour(0x1)

--类--
local Rect = {left=0,top=0,right=0,bottom=0}
Rect.__index = Rect
function Rect:new(_left,_top,_right,_bottom)
    local rect = {}
    setmetatable(rect, Rect)

    rect.left = _left
    rect.top = _top
    rect.right = _right
    rect.bottom = _bottom

    return rect
end
--V3
local Vector3 = {x = 0, y = 0, z = 0}
Vector3.__index = Vector3
function Vector3:new(x, y, z)
    local vector3 = {}
    setmetatable(vector3, Vector3)

    vector3.x = x
    vector3.y = y
    vector3.z = z

    return vector3
end
--V2
local Vector2 = {x = 0, y = 0}
Vector2.__index = Vector2
function Vector2:new(x, y)
    local vector2 = {}
    setmetatable(vector2, Vector2)

    vector2.x = x
    vector2.y = y

    return vector2
end
--欧拉
local Euler = {yaw = 0, pitch = 0, roll = 0}
Euler.__index = Euler
function Euler:new(yaw, pitch, roll)
    local euler = {}
    setmetatable(euler, Euler)

    euler.yaw = yaw
    euler.pitch = pitch
    euler.roll = roll

    return euler
end

--全局变量
--姿态
local Ag = Euler:new(0,0,0)
local Ps = Vector3:new(0,0,0)
local q = ship.getQuaternion()
local velocity = ship.getVelocity()

--红网
local protocol = "rednet:radar<<->>command_cbc_control"
local rednet_message = {msg = {},b_protocol = protocol}
local senderId = -1

--炮弹
local startPos = Vector3:new(0,1,1)
local barrel_pitch = 90
local barrel_yaw = 0
local barrel_length = 4.5

local shootPos = Vector3:new(0,0,0)
local shootPos_command = string.format("%f %f %f",shootPos.x,shootPos.y,shootPos.z)
local fuze = "Fuze:{id:\"createbigcannons:impact_fuze\",Count:1b}"
local shell_speed = 20
local shell_v = Vector3:new(0,0,0)
local Motion = string.format("Motion:[%f,%f,%f]",shell_v.x,shell_v.y,shell_v.z)
local Damage_value = 90.0
local Damage = string.format("Damage:%0.1f",Damage_value)
local tag = string.format("{%s,%s,%s}",Motion,Damage,fuze)
local shell = "cbcmodernwarfare:apfsds_mediumshell"

local summon = "summon"

local soundPlayPos = Vector3:new(0,0,0)
local soundPlayPos_command = string.format("%f %f %f",soundPlayPos.x,soundPlayPos.y,soundPlayPos.z)
local sound = "cbcmodernwarfare:fire_mediumcannon"
local soundType = "voice" 
local targetPlayer = "@a"

local palysound = "playsound"

local reload_t_s = 0.3
local reload_t = 0

--数据文件读取
local IO_i = 1
local CBCcannonshellControlTable = {}
for line in io.lines("CBCcannonshellControl.data") do
    CBCcannonshellControlTable[IO_i] = tonumber(line)
    IO_i = IO_i + 1
end
barrel_length = CBCcannonshellControlTable[1]
startPos.x = CBCcannonshellControlTable[2]
startPos.y = CBCcannonshellControlTable[3]
startPos.z = CBCcannonshellControlTable[4]
barrel_yaw = CBCcannonshellControlTable[5]
shell_speed  = CBCcannonshellControlTable[6]
reload_t_s = CBCcannonshellControlTable[7]
Damage_value = CBCcannonshellControlTable[8]

IO_i = 1
local CBCcannonshellControl_ShellTable = {}
for line in io.lines("CBCcannonshellControl_Shell.data") do
    if(string.find(line,"shell:"))then
        CBCcannonshellControl_ShellTable[IO_i] = string.gsub(line,"shell:","")
    else
        CBCcannonshellControl_ShellTable[IO_i] = line
    end
    
    IO_i = IO_i + 1
end
shell = CBCcannonshellControl_ShellTable[1]
fuze = CBCcannonshellControl_ShellTable[2]
--数据文件写入
local CBCcannonshellControlTable_W = {}
local CBCcannonshellControl_ShellTable_W = {}

--GUI
--标题
local TITLE = GUI.Botton:new(GUI.screenSize.x/2 - 4,1,0,1,"no TEXT",0x80,0x1,0x1,0x1)
--功能按钮
local debugMod = GUI.Botton:new(2,3,0,3,"debugMod",0x2000,0x4000,0x1,0x1)
local debugMod_flag = 0
function debugMod_function()
    if(debugMod_flag == 1)then
        debugMod.Press = false
    else
        debugMod.Press = true
    end
end
local Set_barrel_length = GUI.Botton:new(2,5,0,5,"Set_barrel_length",0x80,0x1,0x1,0x1)
local Set_barrel_length_ADD = GUI.Botton:new(32,5,0,5,"+",0x800,0x1,0x1,0x1)
local Set_barrel_length_SUB = GUI.Botton:new(30,5,0,5,"-",0x800,0x1,0x1,0x1)
local Set_barrel_length_RESET = GUI.Botton:new(35,5,0,5,"RESET",0x800,0x1,0x1,0x1)
function Set_barrel_length_function()
    if(GUI.IfInRect(Set_barrel_length_ADD.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        barrel_length = barrel_length + 0.5
        Set_barrel_length_ADD.Press = true
    else
        Set_barrel_length_ADD.Press = false
    end
    if(GUI.IfInRect(Set_barrel_length_SUB.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        barrel_length = barrel_length - 0.5
        Set_barrel_length_SUB.Press = true
    else
        Set_barrel_length_SUB.Press = false
    end
    if(GUI.IfInRect(Set_barrel_length_RESET.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        barrel_length = 0
        Set_barrel_length_RESET.Press = true
    else
        Set_barrel_length_RESET.Press = false
    end
end
local Set_startPos = GUI.Botton:new(2,6,0,6,"Set_startPos",0x80,0x1,0x1,0x1)
local Set_startPos_ADD_X = GUI.Botton:new(32,7,0,7,"+",0x800,0x1,0x1,0x1)
local Set_startPos_SUB_X = GUI.Botton:new(30,7,0,7,"-",0x800,0x1,0x1,0x1)
local Set_startPos_RESET_X = GUI.Botton:new(35,7,0,7,"RESET",0x800,0x1,0x1,0x1)
local Set_startPos_ADD_Y = GUI.Botton:new(32,8,0,8,"+",0x800,0x1,0x1,0x1)
local Set_startPos_SUB_Y = GUI.Botton:new(30,8,0,8,"-",0x800,0x1,0x1,0x1)
local Set_startPos_RESET_Y = GUI.Botton:new(35,8,0,8,"RESET",0x800,0x1,0x1,0x1)
local Set_startPos_ADD_Z = GUI.Botton:new(32,9,0,9,"+",0x800,0x1,0x1,0x1)
local Set_startPos_SUB_Z = GUI.Botton:new(30,9,0,9,"-",0x800,0x1,0x1,0x1)
local Set_startPos_RESET_Z = GUI.Botton:new(35,9,0,9,"RESET",0x800,0x1,0x1,0x1)
function Set_startPos_function()
    --X
    if(GUI.IfInRect(Set_startPos_ADD_X.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        startPos.x = startPos.x + 0.1
        Set_startPos_ADD_X.Press = true
    else
        Set_startPos_ADD_X.Press = false
    end
    if(GUI.IfInRect(Set_startPos_SUB_X.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        startPos.x = startPos.x - 0.1
        Set_startPos_SUB_X.Press = true
    else
        Set_startPos_SUB_X.Press = false
    end
    if(GUI.IfInRect(Set_startPos_RESET_X.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        startPos.x = 0
        Set_startPos_RESET_X.Press = true
    else
        Set_startPos_RESET_X.Press = false
    end
    --Y
    if(GUI.IfInRect(Set_startPos_ADD_Y.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        startPos.y = startPos.y + 0.1
        Set_startPos_ADD_Y.Press = true
    else
        Set_startPos_ADD_Y.Press = false
    end
    if(GUI.IfInRect(Set_startPos_SUB_Y.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        startPos.y = startPos.y - 0.1
        Set_startPos_SUB_Y.Press = true
    else
        Set_startPos_SUB_Y.Press = false
    end
    if(GUI.IfInRect(Set_startPos_RESET_Y.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        startPos.y = 0
        Set_startPos_RESET_Y.Press = true
    else
        Set_startPos_RESET_Y.Press = false
    end
    --Z
    if(GUI.IfInRect(Set_startPos_ADD_Z.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        startPos.z = startPos.z + 0.1
        Set_startPos_ADD_Z.Press = true
    else
        Set_startPos_ADD_Z.Press = false
    end
    if(GUI.IfInRect(Set_startPos_SUB_Z.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        startPos.z = startPos.z - 0.1
        Set_startPos_SUB_Z.Press = true
    else
        Set_startPos_SUB_Z.Press = false
    end
    if(GUI.IfInRect(Set_startPos_RESET_Z.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        startPos.z = 0
        Set_startPos_RESET_Z.Press = true
    else
        Set_startPos_RESET_Z.Press = false
    end
end
local Set_barrel_yaw = GUI.Botton:new(2,10,0,10,"Set_barrel_yaw",0x80,0x1,0x1,0x1)
local Set_barrel_yaw_ADD = GUI.Botton:new(32,10,0,10,"+",0x800,0x1,0x1,0x1)
local Set_barrel_yaw_SUB = GUI.Botton:new(30,10,0,10,"-",0x800,0x1,0x1,0x1)
local Set_barrel_yaw_RESET_Z = GUI.Botton:new(35,10,0,10,"RESET",0x800,0x1,0x1,0x1)
function Set_barrel_yaw_function()
    if(GUI.IfInRect(Set_barrel_yaw_ADD.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        barrel_yaw = barrel_yaw + 1
        Set_barrel_yaw_ADD.Press = true
    else
        Set_barrel_yaw_ADD.Press = false
    end
    if(GUI.IfInRect(Set_barrel_yaw_SUB.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        barrel_yaw = barrel_yaw - 1
        Set_barrel_yaw_SUB.Press = true
    else
        Set_barrel_yaw_SUB.Press = false
    end
    if(GUI.IfInRect(Set_barrel_yaw_RESET_Z.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        barrel_yaw = 0
        Set_barrel_yaw_RESET_Z.Press = true
    else
        Set_barrel_yaw_RESET_Z.Press = false
    end
end
local Set_shell_speed = GUI.Botton:new(2,11,0,11,"Set_shell_speed",0x80,0x1,0x1,0x1)
local Set_shell_speed_ADD = GUI.Botton:new(32,11,0,11,"+",0x800,0x1,0x1,0x1)
local Set_shell_speed_SUB = GUI.Botton:new(30,11,0,11,"-",0x800,0x1,0x1,0x1)
local Set_shell_speed_RESET_Z = GUI.Botton:new(35,11,0,11,"RESET",0x800,0x1,0x1,0x1)
function Set_shell_speed_function()
    if(GUI.IfInRect(Set_shell_speed_ADD.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        shell_speed = shell_speed + 1
        Set_shell_speed_ADD.Press = true
    else
        Set_shell_speed_ADD.Press = false
    end
    if(GUI.IfInRect(Set_shell_speed_SUB.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        shell_speed = shell_speed - 1
        Set_shell_speed_SUB.Press = true
    else
        Set_shell_speed_SUB.Press = false
    end
    if(GUI.IfInRect(Set_shell_speed_RESET_Z.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        shell_speed = 0
        Set_shell_speed_RESET_Z.Press = true
    else
        Set_shell_speed_RESET_Z.Press = false
    end
end
local Set_reload_t_s = GUI.Botton:new(2,12,0,12,"Set_reload_t_s",0x80,0x1,0x1,0x1)
local Set_reload_t_s_ADD = GUI.Botton:new(32,12,0,12,"+",0x800,0x1,0x1,0x1)
local Set_reload_t_s_SUB = GUI.Botton:new(30,12,0,12,"-",0x800,0x1,0x1,0x1)
local Set_reload_t_s_RESET = GUI.Botton:new(35,12,0,12,"RESET",0x800,0x1,0x1,0x1)
function Set_reload_t_s_function()
    if(GUI.IfInRect(Set_reload_t_s_ADD.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        reload_t_s = reload_t_s + 0.01
        Set_reload_t_s_ADD.Press = true
    else
        Set_reload_t_s_ADD.Press = false
    end
    if(GUI.IfInRect(Set_reload_t_s_SUB.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        reload_t_s = reload_t_s - 0.01
        Set_reload_t_s_SUB.Press = true
    else
        Set_reload_t_s_SUB.Press = false
    end
    if(reload_t_s < 0.01)then
        reload_t_s = 0.01
    end
    if(GUI.IfInRect(Set_reload_t_s_RESET.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        reload_t_s = 5
        Set_reload_t_s_RESET.Press = true
    else
        Set_reload_t_s_RESET.Press = false
    end
end
local Set_Damage = GUI.Botton:new(2,13,0,13,"Set_Damage",0x80,0x1,0x1,0x1)
local Set_Damage_ADD = GUI.Botton:new(32,13,0,13,"+",0x800,0x1,0x1,0x1)
local Set_Damage_SUB = GUI.Botton:new(30,13,0,13,"-",0x800,0x1,0x1,0x1)
local Set_Damage_RESET = GUI.Botton:new(35,13,0,13,"RESET",0x800,0x1,0x1,0x1)
function Set_Damage_function()
    if(GUI.IfInRect(Set_Damage_ADD.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        Damage_value = Damage_value + 1
        Set_Damage_ADD.Press = true
    else
        Set_Damage_ADD.Press = false
    end
    if(GUI.IfInRect(Set_Damage_SUB.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        Damage_value = Damage_value - 1
        Set_Damage_SUB.Press = true
    else
        Set_Damage_SUB.Press = false
    end
    if(GUI.IfInRect(Set_Damage_RESET.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        Damage_value = 90
        Set_Damage_RESET.Press = true
    else
        Set_Damage_RESET.Press = false
    end
end
--固定按钮
local WORING = GUI.Botton:new(1,GUI.screenSize.y - 4,0,GUI.screenSize.y - 4,"If you want to modify the data of artillery",0x4000,0x1,0x1,0x1)
local WORING2 = GUI.Botton:new(1,GUI.screenSize.y - 3,0,GUI.screenSize.y - 3,"and shells,to:CBCcannonshellControl_Shell.data",0x4000,0x1,0x1,0x1)
local BACK = GUI.Botton:new(1,GUI.screenSize.y,0,GUI.screenSize.y,"<back",0x80,0x1,0x1,0x1)
local NEXT = GUI.Botton:new(GUI.screenSize.x - 4,GUI.screenSize.y,0,GUI.screenSize.y,"next>",0x80,0x1,0x1,0x1)
local SAVE = GUI.Botton:new(GUI.screenSize.x/2 - 5,GUI.screenSize.y,0,GUI.screenSize.y,"save",0x80,0x1,0x1,0x1)
local LOAD = GUI.Botton:new(GUI.screenSize.x/2 + 1,GUI.screenSize.y,0,GUI.screenSize.y,"load",0x80,0x1,0x1,0x1)
--gui界面添加
GUI.GUITable["Setting"] = {}
GUI.GUITable["Setting"]["ID"] = 0
GUI.GUITable["Setting"]["function"] = function()
    --标题
    GUI.MCCDrawLineR(1,TITLE.B_RECT.top,GUI.screenSize.x,TITLE.B_RECT.top,0x80)
    GUI.MCCDrawTextR(TITLE.B_RECT.left,TITLE.B_RECT.top,"Setting",0x1,0x80)

    --功能按钮
    debugMod_function()
    GUI.DrawBotton(debugMod)
    if(GUI.IfInRect(debugMod.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        debugMod_flag = debugMod_flag + 1
        if(debugMod_flag > 1)then
            debugMod_flag = 0
        end
        debugMod.color1 = 0x1
        debugMod.color2 = 0x1
    else
        debugMod.color1 = 0x2000
        debugMod.color2 = 0x4000
    end

    GUI.DrawBotton(Set_barrel_length)
    GUI.MCCDrawTextR(Set_barrel_length.B_RECT.right + 3,Set_barrel_length.B_RECT.top,string.format("%0.1f",barrel_length),0x1,0x80)
    Set_barrel_length_function()
    GUI.DrawBotton(Set_barrel_length_ADD)
    GUI.DrawBotton(Set_barrel_length_SUB)
    GUI.DrawBotton(Set_barrel_length_RESET)

    GUI.DrawBotton(Set_startPos)
    Set_startPos_function()
    GUI.MCCDrawTextR(Set_startPos.B_RECT.left,Set_startPos_ADD_X.B_RECT.top,string.format("x:%0.1f",startPos.x),0x1,0x80)
    GUI.DrawBotton(Set_startPos_ADD_X)
    GUI.DrawBotton(Set_startPos_SUB_X)
    GUI.DrawBotton(Set_startPos_RESET_X)
    GUI.MCCDrawTextR(Set_startPos.B_RECT.left,Set_startPos_ADD_Y.B_RECT.top,string.format("y:%0.1f",startPos.y),0x1,0x80)
    GUI.DrawBotton(Set_startPos_ADD_Y)
    GUI.DrawBotton(Set_startPos_SUB_Y)
    GUI.DrawBotton(Set_startPos_RESET_Y)
    GUI.MCCDrawTextR(Set_startPos.B_RECT.left,Set_startPos_ADD_Z.B_RECT.top,string.format("z:%0.1f",startPos.z),0x1,0x80)
    GUI.DrawBotton(Set_startPos_ADD_Z)
    GUI.DrawBotton(Set_startPos_SUB_Z)
    GUI.DrawBotton(Set_startPos_RESET_Z)

    GUI.DrawBotton(Set_barrel_yaw)
    GUI.MCCDrawTextR(Set_barrel_yaw.B_RECT.right + 3,Set_barrel_yaw.B_RECT.top,string.format("%0.1f",barrel_yaw),0x1,0x80)
    Set_barrel_yaw_function()
    GUI.DrawBotton(Set_barrel_yaw_ADD)
    GUI.DrawBotton(Set_barrel_yaw_SUB)
    GUI.DrawBotton(Set_barrel_yaw_RESET_Z)

    GUI.DrawBotton(Set_shell_speed)
    GUI.MCCDrawTextR(Set_shell_speed.B_RECT.right + 3,Set_shell_speed.B_RECT.top,string.format("%d",shell_speed),0x1,0x80)
    Set_shell_speed_function()
    GUI.DrawBotton(Set_shell_speed_ADD)
    GUI.DrawBotton(Set_shell_speed_SUB)
    GUI.DrawBotton(Set_shell_speed_RESET_Z)

    GUI.DrawBotton(Set_reload_t_s)
    GUI.MCCDrawTextR(Set_reload_t_s.B_RECT.right + 3,Set_reload_t_s.B_RECT.top,string.format("%0.2f",reload_t_s),0x1,0x80)
    Set_reload_t_s_function()
    GUI.DrawBotton(Set_reload_t_s_ADD)
    GUI.DrawBotton(Set_reload_t_s_SUB)
    GUI.DrawBotton(Set_reload_t_s_RESET)

    GUI.DrawBotton(Set_Damage)
    GUI.MCCDrawTextR(Set_Damage.B_RECT.right + 3,Set_Damage.B_RECT.top,string.format("%d",Damage_value),0x1,0x80)
    Set_Damage_function()
    GUI.DrawBotton(Set_Damage_ADD)
    GUI.DrawBotton(Set_Damage_SUB)
    GUI.DrawBotton(Set_Damage_RESET)

    --固定按钮
    GUI.DrawBotton(WORING)
    GUI.DrawBotton(WORING2)
    GUI.DrawBotton(NEXT)
    if(GUI.IfInRect(NEXT.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        NEXT.Press = true
    else
        NEXT.Press = false
    end
    GUI.DrawBotton(SAVE)
    if(GUI.IfInRect(SAVE.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        CBCcannonshellControlTable_W[1] = barrel_length
        CBCcannonshellControlTable_W[2] = startPos.x
        CBCcannonshellControlTable_W[3] = startPos.y
        CBCcannonshellControlTable_W[4] = startPos.z
        CBCcannonshellControlTable_W[5] = barrel_yaw
        CBCcannonshellControlTable_W[6] = shell_speed
        CBCcannonshellControlTable_W[7] = reload_t_s
        CBCcannonshellControlTable_W[8] = Damage_value
        CBCcannonshellControl = io.open("CBCcannonshellControl.data","r+")
        io.output(CBCcannonshellControl)
        io.write(
            CBCcannonshellControlTable_W[1],"\n",
            CBCcannonshellControlTable_W[2],"\n",
            CBCcannonshellControlTable_W[3],"\n",
            CBCcannonshellControlTable_W[4],"\n",
            CBCcannonshellControlTable_W[5],"\n",
            CBCcannonshellControlTable_W[6],"\n",
            CBCcannonshellControlTable_W[7],"\n",
            CBCcannonshellControlTable_W[8],"\n"
        )
        io.close(CBCcannonshellControl)
        SAVE.Press = true
    else
        SAVE.Press = false
    end
    GUI.DrawBotton(LOAD)
    if(GUI.IfInRect(LOAD.B_RECT,GUI.ExMsg) and GUI.ExMsg.botton == 1)then
        IO_i = 1
        CBCcannonshellControlTable = {}
        for line in io.lines("CBCcannonshellControl.data") do
            CBCcannonshellControlTable[IO_i] = tonumber(line)
            IO_i = IO_i + 1
        end
        barrel_length = CBCcannonshellControlTable[1]
        startPos.x = CBCcannonshellControlTable[2]
        startPos.y = CBCcannonshellControlTable[3]
        startPos.z = CBCcannonshellControlTable[4]
        barrel_yaw = CBCcannonshellControlTable[5]
        shell_speed = CBCcannonshellControlTable[6]
        reload_t_s = CBCcannonshellControlTable[7]
        Damage_value = CBCcannonshellControlTable[8]
        IO_i = 1
        CBCcannonshellControl_ShellTable = {}

        for line in io.lines("CBCcannonshellControl_Shell.data") do
            if(string.find(line,"shell:"))then
                CBCcannonshellControl_ShellTable[IO_i] = string.gsub(line,"shell:","")
            else
                CBCcannonshellControl_ShellTable[IO_i] = line
            end
            
            IO_i = IO_i + 1
        end
        shell = CBCcannonshellControl_ShellTable[1]
        fuze = CBCcannonshellControl_ShellTable[2]
        LOAD.Press = true
    else
        LOAD.Press = false
    end
end


--方法
--计算
function V3sub(V3_1,V3_2)
    local V3result = {}
    V3result.x = V3_1.x - V3_2.x
    V3result.y = V3_1.y - V3_2.y
    V3result.z = V3_1.z - V3_2.z
    return V3result
end

function V3add(V3_1,V3_2)
    local V3result = {}
    V3result.x = V3_1.x + V3_2.x
    V3result.y = V3_1.y + V3_2.y
    V3result.z = V3_1.z + V3_2.z
    return V3result
end

local RotateVectorByQuat = function(quat, v)
    local x = quat.x * 2
    local y = quat.y * 2
    local z = quat.z * 2
    local xx = quat.x * x
    local yy = quat.y * y
    local zz = quat.z * z
    local xy = quat.x * y
    local xz = quat.x * z
    local yz = quat.y * z
    local wx = quat.w * x
    local wy = quat.w * y
    local wz = quat.w * z
    local res = {}
    res.x = (1.0 - (yy + zz)) * v.x + (xy - wz) * v.y + (xz + wy) * v.z
    res.y = (xy + wz) * v.x + (1.0 - (xx + zz)) * v.y + (yz - wx) * v.z
    res.z = (xz - wy) * v.x + (yz + wx) * v.y + (1.0 - (xx + yy)) * v.z
    return res
end

function radianToDegree(angle)-- 弧-角
	return angle * (180.0 / math.pi)
end

function degreeToRadian(degree)-- 角-弧
	return degree * (math.pi / 180.0)
end

function getCoordinates(angle, radius)--已知角和半径求坐标
    local radians = angle * math.pi / 180

    local x = radius * math.cos(radians)
    local y = radius * math.sin(radians)

    return Vector2:new(x, y)
end

-- 定义计算点坐标的函数
local function calculate_point(r, pitch, yaw)
    -- 将角度转换为弧度
    local pitch_rad = degreeToRadian(pitch)  -- 俯仰角 (PITCH)
    local yaw_rad = degreeToRadian(yaw)      -- 偏航角 (YAW)

    -- 计算直角坐标系下的坐标
    local x = r * math.cos(pitch_rad) * math.sin(yaw_rad)
    local y = r * math.sin(pitch_rad)
    local z = r * math.cos(pitch_rad) * math.cos(yaw_rad)

    return Vector3:new(x, y, z)
end

--参数获取
function GetEuler()  --获取欧拉角
    local quat={w=0,x=0,y=0,z=0}
    quat.w=ship.getQuaternion().w
    quat.x=ship.getQuaternion().y
    quat.y=ship.getQuaternion().x
    quat.z=ship.getQuaternion().z
    Ag.yaw=math.deg(math.atan2(quat.y*quat.z+quat.w*quat.x,1/2-(quat.x*quat.x+quat.y*quat.y)))
    Ag.roll=math.deg(math.atan2(quat.x*quat.y+quat.w*quat.z,1/2-(quat.y*quat.y+quat.z*quat.z)))
    Ag.pitch=math.deg(math.asin(-2*(quat.x*quat.z-quat.w*quat.y)))
end

function GetShipTransform()
    GetEuler()
    Ps = ship.getWorldspacePosition()
    q = ship.getQuaternion()
    velocity = ship.getVelocity()
    barrel_pitch = CBC_CM.getPitch()
end

--功能
function posUpdate()
    local N_q = {}
    N_q.x = -q.x
    N_q.y = -q.y
    N_q.z = -q.z
    N_q.w = -q.w
    local shootPosOffset_barrel_v3 = calculate_point(barrel_length,barrel_pitch,barrel_yaw)
    local startPos_Offset = RotateVectorByQuat(N_q,startPos)
    --炮弹
    local shootPosOffset = RotateVectorByQuat(N_q,Vector3:new(shootPosOffset_barrel_v3.x,shootPosOffset_barrel_v3.y,shootPosOffset_barrel_v3.z))--发射位置偏移
    shootPos = V3add(V3add(shootPosOffset,startPos_Offset),Ps) 
    shootPos_command = string.format("%f %f %f",shootPos.x,shootPos.y,shootPos.z)
    --声音
    local soundPlayPosOffset = RotateVectorByQuat(N_q,Vector3:new(shootPosOffset_barrel_v3.x,shootPosOffset_barrel_v3.y,shootPosOffset_barrel_v3.z))--播放位置偏移
    soundPlayPos = V3add(V3add(soundPlayPosOffset,startPos_Offset),Ps)
    soundPlayPos_command = string.format("%f %f %f",soundPlayPos.x,soundPlayPos.y,soundPlayPos.z)
end

function tagUpdate()
    local N_q = {}
    N_q.x = -q.x
    N_q.y = -q.y
    N_q.z = -q.z
    N_q.w = -q.w
    local shell_v_Offset_barrel_v3 = calculate_point(shell_speed,barrel_pitch,barrel_yaw)
    local shell_v_Offset = RotateVectorByQuat(N_q,Vector3:new(shell_v_Offset_barrel_v3.x,shell_v_Offset_barrel_v3.y,shell_v_Offset_barrel_v3.z))--速度
    shell_v = shell_v_Offset
    Motion = string.format("Motion:[%f,%f,%f]",shell_v.x,shell_v.y,shell_v.z)
    tag = string.format("{%s,%s,%s}",Motion,Damage,fuze)
end

function shellControl()
    while(1)do
        posUpdate()
        tagUpdate()
        if(redstone.getInput("front"))then
            if(os.clock() - reload_t >= reload_t_s)then
                commands.execAsync(string.format("%s %s %s %s",summon,shell,shootPos_command,tag))
                commands.execAsync(string.format("%s %s %s %s %s",palysound,sound,soundType,targetPlayer,soundPlayPos_command))
                reload_t = os.clock()
            else
                commands.async.say(string.format("%0.1f",reload_t_s - (os.clock() - reload_t)))
            end
        end

        sleep(0)
    end
end

--参数显示
function showValue()
    local N_q = {}
    N_q.x = -q.x
    N_q.y = -q.y
    N_q.z = -q.z
    N_q.w = -q.w
    local startPos_world = V3add(Ps,RotateVectorByQuat(N_q,startPos))--发射位置偏移
    if(debugMod_flag == 1)then
        commands.execAsync(string.format("particle minecraft:glow %f %f %f",shootPos.x,shootPos.y,shootPos.z))
        commands.execAsync(string.format("particle minecraft:glow %f %f %f",startPos_world.x,startPos_world.y,startPos_world.z))
    end
end

GUI.start()
--主函数
function receiveMessage()
    while(1)do
        senderId,rednet_message = rednet.receive(protocol)
        sleep(0)
    end
end

function main()
    while(true) do
        GetShipTransform()

        showValue()

        sleep(0)
    end
end

parallel.waitForAll(main,receiveMessage,shellControl,GUI.GUI_main)