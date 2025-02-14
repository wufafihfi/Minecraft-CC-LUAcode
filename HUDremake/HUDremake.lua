term.clear()
term.setCursorPos(1,1)

term.setTextColour(0x20)
print("----------WaiShe----------")
local hologram = peripheral.find("hologram")
local NamesTable = peripheral.getNames()
term.setTextColour(0x1)
for k,v in pairs(NamesTable) do
    print(k,"|",v,"-->",peripheral.getType(v))
end
term.setTextColour(0x1)

term.setTextColour(0x20)
print("----------InitPinMu----------")
local HologramScale = {x = 0.1,y = 0.1}
local HologramSize = {x = 280,y = 200}--7:5
local HologramSize_World = {x = HologramSize.x * HologramScale.x^2,y = HologramSize.y * HologramScale.y^2}
hologram.Resize(HologramSize.x,HologramSize.y)
hologram.SetScale(HologramScale.x,HologramScale.y)
local HUDRotation = {yaw = 0,pitch = 15,roll = 0}
hologram.SetRotation(HUDRotation.yaw,HUDRotation.pitch,HUDRotation.roll)--0,15,0
local HUDTranslation = {x = 0,y = 0.1,z = 1}
hologram.SetTranslation(HUDTranslation.x,HUDTranslation.y,HUDTranslation.z)
hologram.SetClearColor(0x1)
local ShipyardHUDPos = {x = 0,y = 0,z = 0}
local HUDPos = {x = 0,y = 0,z = 0}
--平面
local HUDscreenPs_offset
local HUDscreenPs
local Plane_point
local plane_ABC_V3
local plane_coefficients
--直线
local IO_i = 1
local HUD_DataTable = {}
for line in io.lines("HUD.data") do
    HUD_DataTable[IO_i] = tonumber(line)
    IO_i = IO_i + 1
end
local line_point_OnShip = {x = HUD_DataTable[1],y = HUD_DataTable[2],z = HUD_DataTable[3]}
local line_point = {0,0,0}
local HUDscreenPs_OnShip = {x = HUD_DataTable[4],y = HUD_DataTable[5],z = HUD_DataTable[6]}
local SetScreenPixelOffset_V2 = {x = HUD_DataTable[7],y = HUD_DataTable[8]}
local HUD_DataTable_W = {0,0,0,0,0,0,0,0}
term.setTextColour(0x1)

term.setTextColour(0x100)
print("----------Press leftMose to Start----------")
term.setTextColour(0x1)

--基础参数
local WindowTable = {left=0,top=0,right=HologramSize.x,bottom=HologramSize.y}

local CCscreenSize = {x,y}
CCscreenSize.x,CCscreenSize.y = term.getSize()

--全局变量
local bkcolor_CC = 0x8000
--消息
local ExMsg = {event = 0,botton = 0,x = 0, y = 0}
--UI控件位置
--主菜单
local TitlePosition = {x = CCscreenSize.x / 2 - 6,y = 1}
local HUDbottonPosition = {x,y,right,bottom}
HUDbottonPosition.x = 3
HUDbottonPosition.y = 3
HUDbottonPosition.right = HUDbottonPosition.x + 2
HUDbottonPosition.bottom = HUDbottonPosition.y + 0
--HUD设置
--夜视
local NightVisionMode = {x,y,right,bottom}
NightVisionMode.x = 3
NightVisionMode.y = 5
NightVisionMode.right = NightVisionMode.x + 14
NightVisionMode.bottom = NightVisionMode.y + 0
local NightVisionMode_BOOL = 0 --按钮状态
local NightVisionMode_BottonColor = 0x4000 --按钮颜色
--原点
local SetOrigin = {x,y,right,bottom}
SetOrigin.x = 3
SetOrigin.y = 7
SetOrigin.right = SetOrigin.x + 8
SetOrigin.bottom = SetOrigin.y + 0
local SetOrigin_timeSave = 0 --计时
local SetOrigin_time = 10 --延时（秒）
local SetOrigin_BOOL = 0 --按钮状态
local SetOrigin_BottonColor = 0x2000 --按钮颜色
local SetOrigin_value_sub_1 = {x,y,right,bottom}
SetOrigin_value_sub_1.x = SetOrigin.x
SetOrigin_value_sub_1.y = SetOrigin.y + 1
SetOrigin_value_sub_1.addx = 0
SetOrigin_value_sub_1.addy = 0
local SetOrigin_value_sub_1_BottonColor = 0x800 --按钮颜色
local SetOrigin_value_sub_1_BottonColor_add = 0x800 --按钮颜色
local SetOrigin_value_sub_2 = {x,y,right,bottom}
SetOrigin_value_sub_2.x = SetOrigin.x
SetOrigin_value_sub_2.y = SetOrigin.y + 2
SetOrigin_value_sub_2.addx = 0
SetOrigin_value_sub_2.addy = 0
local SetOrigin_value_sub_2_BottonColor = 0x800 --按钮颜色
local SetOrigin_value_sub_2_BottonColor_add = 0x800 --按钮颜色
local SetOrigin_value_sub_3 = {x,y,right,bottom}
SetOrigin_value_sub_3.x = SetOrigin.x
SetOrigin_value_sub_3.y = SetOrigin.y + 3
SetOrigin_value_sub_3.addx = 0
SetOrigin_value_sub_3.addy = 0
local SetOrigin_value_sub_3_BottonColor = 0x800 --按钮颜色
local SetOrigin_value_sub_3_BottonColor_add = 0x800 --按钮颜色
local SetOrigin_ReSet = {x,y,right,bottom}
SetOrigin_ReSet.x = SetOrigin.x
SetOrigin_ReSet.y = SetOrigin.y + 4
SetOrigin_ReSet.right = SetOrigin_ReSet.x + 4
SetOrigin_ReSet.bottom = SetOrigin_ReSet.y + 0
local SetOrigin_ReSet_BottonColor = 0x800 --按钮颜色
local SetOrigin_Load = {x,y,right,bottom}
SetOrigin_Load.x = SetOrigin.x
SetOrigin_Load.y = SetOrigin.y + 5
SetOrigin_Load.right = SetOrigin_Load.x + 3
SetOrigin_Load.bottom = SetOrigin_Load.y + 0
local SetOrigin_Load_BottonColor = 0x800 --按钮颜色
--屏幕位置
local SetScreenPos = {x,y,right,bottom}
SetScreenPos.x = 20
SetScreenPos.y = 7
SetScreenPos.right = SetScreenPos.x + 11
SetScreenPos.bottom = SetScreenPos.y + 0
local SetScreenPos_BottonColor = 0x8000 --按钮颜色
local SetScreenPos_value_sub_1 = {x,y,right,bottom}
SetScreenPos_value_sub_1.x = SetScreenPos.x
SetScreenPos_value_sub_1.y = SetScreenPos.y + 1
SetScreenPos_value_sub_1.addx = 0
SetScreenPos_value_sub_1.addy = 0
local SetScreenPos_value_sub_1_BottonColor = 0x800 --按钮颜色
local SetScreenPos_value_sub_1_BottonColor_add = 0x800 --按钮颜色
local SetScreenPos_value_sub_2 = {x,y,right,bottom}
SetScreenPos_value_sub_2.x = SetScreenPos.x
SetScreenPos_value_sub_2.y = SetScreenPos.y + 2
SetScreenPos_value_sub_2.addx = 0
SetScreenPos_value_sub_2.addy = 0
local SetScreenPos_value_sub_2_BottonColor = 0x800 --按钮颜色
local SetScreenPos_value_sub_2_BottonColor_add = 0x800 --按钮颜色
local SetScreenPos_value_sub_3 = {x,y,right,bottom}
SetScreenPos_value_sub_3.x = SetScreenPos.x
SetScreenPos_value_sub_3.y = SetScreenPos.y + 3
SetScreenPos_value_sub_3.addx = 0
SetScreenPos_value_sub_3.addy = 0
local SetScreenPos_value_sub_3_BottonColor = 0x800 --按钮颜色
local SetScreenPos_value_sub_3_BottonColor_add = 0x800 --按钮颜色
local SetScreenPos_ReSet = {x,y,right,bottom}
SetScreenPos_ReSet.x = SetScreenPos.x
SetScreenPos_ReSet.y = SetScreenPos.y + 4
SetScreenPos_ReSet.right = SetScreenPos_ReSet.x + 4
SetScreenPos_ReSet.bottom = SetScreenPos_ReSet.y + 0
local SetScreenPos_ReSet_BottonColor = 0x800 --按钮颜色
local SetScreenPos_Load = {x,y,right,bottom}
SetScreenPos_Load.x = SetScreenPos.x
SetScreenPos_Load.y = SetScreenPos.y + 5
SetScreenPos_Load.right = SetScreenPos_Load.x + 3
SetScreenPos_Load.bottom = SetScreenPos_Load.y + 0
local SetScreenPos_Load_BottonColor = 0x800 --按钮颜色
--屏幕像素偏移
local SetScreenPixelOffset = {x,y,right,bottom}
SetScreenPixelOffset.x = 35
SetScreenPixelOffset.y = 7
SetScreenPixelOffset.right = SetScreenPixelOffset.x + 16
SetScreenPixelOffset.bottom = SetScreenPixelOffset.y + 0
local SetScreenPixelOffset_BottonColor = 0x8000 --按钮颜色
local SetScreenPixelOffset_value_sub_1 = {x,y,right,bottom}
SetScreenPixelOffset_value_sub_1.x = SetScreenPixelOffset.x
SetScreenPixelOffset_value_sub_1.y = SetScreenPixelOffset.y + 1
SetScreenPixelOffset_value_sub_1.addx = 0
SetScreenPixelOffset_value_sub_1.addy = 0
local SetScreenPixelOffset_value_sub_1_BottonColor = 0x800 --按钮颜色
local SetScreenPixelOffset_value_sub_1_BottonColor_add = 0x800 --按钮颜色
local SetScreenPixelOffset_value_sub_2 = {x,y,right,bottom}
SetScreenPixelOffset_value_sub_2.x = SetScreenPixelOffset.x
SetScreenPixelOffset_value_sub_2.y = SetScreenPixelOffset.y + 2
SetScreenPixelOffset_value_sub_2.addx = 0
SetScreenPixelOffset_value_sub_2.addy = 0
local SetScreenPixelOffset_value_sub_2_BottonColor = 0x800 --按钮颜色
local SetScreenPixelOffset_value_sub_2_BottonColor_add = 0x800 --按钮颜色
local SetScreenPixelOffset_ReSet = {x,y,right,bottom}
SetScreenPixelOffset_ReSet.x = SetScreenPixelOffset.x
SetScreenPixelOffset_ReSet.y = SetScreenPixelOffset.y + 3
SetScreenPixelOffset_ReSet.right = SetScreenPixelOffset_ReSet.x + 4
SetScreenPixelOffset_ReSet.bottom = SetScreenPixelOffset_ReSet.y + 0
local SetScreenPixelOffset_ReSet_BottonColor = 0x800 --按钮颜色
local SetScreenPixelOffset_Load = {x,y,right,bottom}
SetScreenPixelOffset_Load.x = SetScreenPixelOffset.x
SetScreenPixelOffset_Load.y = SetScreenPixelOffset.y + 4
SetScreenPixelOffset_Load.right = SetScreenPixelOffset_Load.x + 3
SetScreenPixelOffset_Load.bottom = SetScreenPixelOffset_Load.y + 0
local SetScreenPixelOffset_Load_BottonColor = 0x800 --按钮颜色
--调试模式
local DebuggerMod = {x,y,right,bottom}
DebuggerMod.x = 20
DebuggerMod.y = 5
DebuggerMod.right = DebuggerMod.x + 11
DebuggerMod.bottom = DebuggerMod.y + 0
local DebuggerMod_flag = 0
local DebuggerMod_BottonColor = 0x4000	 --按钮颜色
--前后成像
local BOrFMod = {x,y,right,bottom}
BOrFMod.x = 35
BOrFMod.y = 5
BOrFMod.right = BOrFMod.x + 6
BOrFMod.bottom = BOrFMod.y + 0
local BOrFMod_flag = 1
local BOrFMod_BottonColor = 0x4000	 --按钮颜色
--固定按钮
local Save = {x,y,right,bottom}
Save.x = CCscreenSize.x/2 - 2
Save.y = CCscreenSize.y
Save.right = Save.x + 3
Save.bottom = Save.y + 0
local Save_BottonColor = 0x80
local BackBottonPosition = {x,y,right,bottom}
BackBottonPosition.x = 1
BackBottonPosition.y = CCscreenSize.y
BackBottonPosition.right = BackBottonPosition.x + 4
BackBottonPosition.bottom = BackBottonPosition.y + 0
local NextBottonPosition = {x,y,right,bottom}
NextBottonPosition.x = CCscreenSize.x - 4
NextBottonPosition.y = CCscreenSize.y
NextBottonPosition.right = NextBottonPosition.x + 4
NextBottonPosition.bottom = NextBottonPosition.y + 0
--UI界面ID
local nowUiIDshow = 0
local UiID = {}
UiID["SettingMap"] = 0
UiID["HUDsetting_P1"] = 1
UiID["HUDsetting_P2"] = 1.1
--HUD
local TextTableM = {}

local bkcolor = 0x00000000
local Mainlinecolor = 0xFFFFFFFF
local Maintextcolor = 0xFFFFFFFF
local red = 0xFF0000FF
local signcolor = 0x00FF00FF

local seaY = -65

local Ag={yaw=0,pitch=0,roll=0}
local Speed = {x=0,y=0,z=0}
local Ps={x=0,y=0,z=0}
local ShipyardPS={x=0,y=0,z=0}
local ShipWorldPos = {x=0,y=0,z=0}
local q = ship.getQuaternion()
local velocity = ship.getVelocity()
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

local radarSearchDistance = 2500
local EradarSearchDistance = 2500
local playerSearchDistance = 20
local PlayerPos = Vector3:new(0,0,0)
local PlayerAngle = Vector3:new(0,0,0)
local HUDonShip = {x = 0,y = 0,z = 0}

local target1_ChuShengDian = {x=0,y=-60,z=0}
local target2_BiaoBa = {x=-86,y=-59,z=-166}

--物理量
local g = 9.81
local air_density = 1.213
local CD = 150--阻力系数
local bombRadius = 1
local bombArea = math.pi * bombRadius^2
local bombMass = 2000


local PointTable = {1,1,60,1,60,60,1,60,30,30}
local JiZhunXian_PointTable = {
    1,1,0,1,0,1,1,0,
    0,0,1,0,1,0,0,0
}
local TEXT_Table = {}
TEXT_Table["0"] = {--0
1,1,1,
1,0,1,
1,0,1,
1,0,1,
1,1,1
}
TEXT_Table["1"] = {--1
0,1,0,
0,1,0,
0,1,0,
0,1,0,
0,1,0
}
TEXT_Table["2"] = {--2
1,1,1,
0,0,1,
1,1,1,
1,0,0,
1,1,1
}
TEXT_Table["3"] = {--3
1,1,1,
0,0,1,
1,1,1,
0,0,1,
1,1,1
}
TEXT_Table["4"] = {--4
1,0,1,
1,0,1,
1,1,1,
0,0,1,
0,0,1
}
TEXT_Table["5"] = {--5
1,1,1,
1,0,0,
1,1,1,
0,0,1,
1,1,1
}
TEXT_Table["6"] = {--6
1,1,1,
1,0,0,
1,1,1,
1,0,1,
1,1,1
}
TEXT_Table["7"] = {--7
1,1,1,
0,0,1,
0,0,1,
0,0,1,
0,0,1
}
TEXT_Table["8"] = {--8
1,1,1,
1,0,1,
1,1,1,
1,0,1,
1,1,1
}
TEXT_Table["9"] = {--9
1,1,1,
1,0,1,
1,1,1,
0,0,1,
1,1,1
}
TEXT_Table["."] = {--.
0,0,0,
0,0,0,
0,0,0,
0,0,0,
0,1,0
}
TEXT_Table["-"] = {-- -
0,0,0,
0,0,0,
1,1,1,
0,0,0,
0,0,0
}
TEXT_Table[" "] = {--  
0,0,0,
0,0,0,
0,0,0,
0,0,0,
0,0,0
}
TEXT_Table["P"] = {--  
1,1,0,
1,0,1,
1,1,0,
1,0,0,
1,0,0
}
TEXT_Table["R"] = {--  
1,1,0,
1,0,1,
1,1,0,
1,0,1,
1,0,1
}
--类似静态变量
local isStart = false
local isUsed = false
local isUsed2 = false
--方法
--计算
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

function calculateAngle(x1, y1, x2, y2)
	local deltaX = x2 - x1 -- x 坐标差
	local deltaY = y2 - y1 -- y 坐标差
	local angle = math.atan2(deltaY, deltaX) -- 计算角度（弧度）

	return radianToDegree(angle) -- 转换为度并返回
end

function atanh(x)
    return 0.5 * math.log((1 + x) / (1 - x))
end

function calculateDropTime(height, k)
    return math.sqrt(1.0 / (g * k)) * atanh(math.sqrt(k / g)) --初始垂直速度为 0
end

function calculateHorizontalDistance(speed,k,time)
    return (speed / k) * math.log(1.0 + k * speed * time);
end

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

-- 计算直线与平面的交点
function line_plane_intersection(line_point, direction_vector, plane_coefficients,Plane_point)
    -- 解包参数
    local x0, y0, z0 = table.unpack(line_point)  -- 直线上的点
    local a, b, c = table.unpack(direction_vector)  -- 直线的方向向量
    local A, B, C = table.unpack(plane_coefficients)  -- 平面的系数 (Ax + By + Cz + D = 0)
    local Px0, Py0, Pz0 = table.unpack(Plane_point) --平面上一点 计算D

    local D = -(A * Px0 + B * Py0 + C * Pz0)

    -- 计算分母
    local denominator = A * a + B * b + C * c

    -- 判断是否平行
    if denominator == 0 then
        -- 判断直线是否在平面内
        local point_on_plane = A * x0 + B * y0 + C * z0 + D
        if not(point_on_plane == 0) then
            return Vector3:new(nil, nil, nil)
        end

        return Vector3:new(nil, nil, nil)
    end

    -- 计算参数 t
    local t = -(A * x0 + B * y0 + C * z0 + D) / denominator

    -- 计算交点坐标
    local x = x0 + a * t
    local y = y0 + b * t
    local z = z0 + c * t

    return Vector3:new(x, y, z)  -- 返回交点坐标
end
-- 函数：根据 PITCH 和 YAW 计算方向矢量
function calculateDirectionVector(pitch, yaw, magnitude)
    local pitchRad = degreeToRadian(pitch)
    local yawRad = degreeToRadian(yaw)
    
    local cosPitch = math.cos(pitchRad)
    local sinPitch = math.sin(pitchRad)
    local cosYaw = math.cos(yawRad)
    local sinYaw = math.sin(yawRad)
    
    local directionVector = {
        x = magnitude * cosPitch * cosYaw,
        y = magnitude * sinPitch,
        z = magnitude * cosPitch * sinYaw
    }
    
    return directionVector
end
-- 将四元数转换为旋转向量
function quaternionToRotationVector(q)
    local w, x, y, z = q.w, q.x, q.y, q.z
    local angle = 2 * math.acos(w)
    local sin_half_angle = math.sin(angle / 2)
    
    -- 处理 sin_half_angle 接近零的情况
    if math.abs(sin_half_angle) < 1e-6 then
        -- 当四元数接近 (1, 0, 0, 0) 或 (-1, 0, 0, 0) 时
        -- 返回旋转轴为 (1, 0, 0) 或 (-1, 0, 0)，角度为 0 或 pi
        if w > 0 then
            return {0, 0, 0}  -- 角度为 0 度
        else
            return {math.pi, 0, 0}  -- 角度为 pi 度，旋转轴为任意轴，这里选择 (1, 0, 0)
        end
    end
    
    local rotation_vector = Vector3:new(
        x * angle / sin_half_angle,
        y * angle / sin_half_angle,
        z * angle / sin_half_angle
    )
    
    return rotation_vector
end
function intersectionToScreen(HUDscreenPs_v3,Line_startPoint,Line_vector,Plane_startPoint,Plane_ABC)

    local intersection = line_plane_intersection(Line_startPoint, Line_vector, Plane_ABC,Plane_startPoint)
    
    local _q = {}
    _q.x = -q.x
    _q.y = -q.y
    _q.z = -q.z
    _q.w = q.w
    local intersectionOnScreen = RotateVectorByQuat(_q,Vector3:new(intersection.x - HUDscreenPs_v3.x,intersection.y - HUDscreenPs_v3.y,intersection.z - HUDscreenPs_v3.z))

    local screenPoint_CDN = {}
    screenPoint_CDN.x = 2 * intersectionOnScreen.x / HologramSize_World.x;
    screenPoint_CDN.y = 2 * intersectionOnScreen.y / HologramSize_World.y;

    local IN_b = 1
    if(BOrFMod_flag == 1)then
        IN_b = -1
    else
        IN_b = 1
    end

    local screenPoint_RCS = {} --raster coordinate system
    screenPoint_RCS.x = (screenPoint_CDN.x + 1) * (HologramSize.x + SetScreenPixelOffset_V2.x) / 2;
    screenPoint_RCS.y = (1 - screenPoint_CDN.y) * (HologramSize.y + SetScreenPixelOffset_V2.y) / 2 * IN_b;

    return screenPoint_RCS
end

function targetToHud(targetPos)
    local _q = {}
    _q.x = -q.x
    _q.y = -q.y
    _q.z = -q.z
    _q.w = q.w
    local targetPos_OnHUD = RotateVectorByQuat(_q,V3sub(targetPos,Vector3:new(line_point[1],line_point[2],line_point[3])))
    local direction_vector = {targetPos.x - line_point[1], targetPos.y - line_point[2], targetPos.z - line_point[3]}  -- 直线的方向向量 (a, b, c)
    local screenPoint_RCS = intersectionToScreen(HUDscreenPs,line_point,direction_vector,Plane_point,plane_coefficients)

    if(BOrFMod_flag == 1)then
        if(targetPos_OnHUD.z >= 0)then
            return screenPoint_RCS
        else
            return Vector2:new(screenPoint_RCS.x + HologramSize.x*5,screenPoint_RCS.y)
        end
    else
        if(targetPos_OnHUD.z <= 0)then
            return screenPoint_RCS
        else
            return Vector2:new(screenPoint_RCS.x + HologramSize.x*5,screenPoint_RCS.y)
        end
    end
end

--标点坐标计算

--CC屏绘制
function MCCDrawTextR(x,y,text,textcolor,backcolor)
    local NowTextColour = term.getTextColour()
    local NowBkColour = term.getBackgroundColour()
    term.setTextColour(textcolor)
    term.setBackgroundColour(backcolor)
    term.setCursorPos(x,y)
    term.write(text)
    term.setTextColour(NowTextColour)
    term.setBackgroundColour(NowBkColour)
end
function MCCDrawTextR_NoXY(text,textcolor,backcolor)
    local NowTextColour = term.getTextColour()
    local NowBkColour = term.getBackgroundColour()
    term.setTextColour(textcolor)
    term.setBackgroundColour(backcolor)
    term.write(text)
    term.setTextColour(NowTextColour)
    term.setBackgroundColour(NowBkColour)
end

function MCCDrawLineR(x,y,dx,dy,colour)
    local NowBkColour = term.getBackgroundColour()
    paintutils.drawLine(x,y,dx,dy,colour)
    term.setBackgroundColour(NowBkColour)
end

--UI
function SetScreenPixelOffset_D()
    --屏幕像素偏移
    MCCDrawTextR(SetScreenPixelOffset.x,SetScreenPixelOffset.y,"ScreenPixelOffset",0x1,SetScreenPixelOffset_BottonColor)
    --x
    MCCDrawTextR(SetScreenPixelOffset_value_sub_1.x,SetScreenPixelOffset_value_sub_1.y,"-",0x1,SetScreenPixelOffset_value_sub_1_BottonColor)
    MCCDrawTextR(SetScreenPixelOffset_value_sub_1.x + 1,SetScreenPixelOffset_value_sub_1.y,string.format("x:%.1f",SetScreenPixelOffset_V2.x),0x1,bkcolor_CC)
    SetScreenPixelOffset_value_sub_1.addx,SetScreenPixelOffset_value_sub_1.addy = term.getCursorPos()
    MCCDrawTextR_NoXY("+",0x1,SetScreenPixelOffset_value_sub_1_BottonColor_add)
    --y
    MCCDrawTextR(SetScreenPixelOffset_value_sub_2.x,SetScreenPixelOffset_value_sub_2.y,"-",0x1,SetScreenPixelOffset_value_sub_2_BottonColor)
    MCCDrawTextR(SetScreenPixelOffset_value_sub_2.x + 1,SetScreenPixelOffset_value_sub_2.y,string.format("y:%.1f",SetScreenPixelOffset_V2.y),0x1,bkcolor_CC)
    SetScreenPixelOffset_value_sub_2.addx,SetScreenPixelOffset_value_sub_2.addy = term.getCursorPos()
    MCCDrawTextR_NoXY("+",0x1,SetScreenPixelOffset_value_sub_2_BottonColor_add)
    --重置
    MCCDrawTextR(SetScreenPixelOffset_ReSet.x,SetScreenPixelOffset_ReSet.y,"ReSet",0x1,SetScreenPixelOffset_ReSet_BottonColor)
    --加载
    MCCDrawTextR(SetScreenPixelOffset_Load.x,SetScreenPixelOffset_Load.y,"Load",0x1,SetScreenPixelOffset_Load_BottonColor)
end

function SetScreenPixelOffset_B()
    --屏幕像素偏移
    if(ExMsg.botton == 1 and ExMsg.x == SetScreenPixelOffset_value_sub_1.x and ExMsg.y == SetScreenPixelOffset_value_sub_1.y)then
        SetScreenPixelOffset_V2.x = SetScreenPixelOffset_V2.x - 1
        SetScreenPixelOffset_value_sub_1_BottonColor = 0x1
    else
        SetScreenPixelOffset_value_sub_1_BottonColor = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetScreenPixelOffset_value_sub_1.addx and ExMsg.y == SetScreenPixelOffset_value_sub_1.addy)then
        SetScreenPixelOffset_V2.x = SetScreenPixelOffset_V2.x + 1
        SetScreenPixelOffset_value_sub_1_BottonColor_add = 0x1
    else
        SetScreenPixelOffset_value_sub_1_BottonColor_add = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetScreenPixelOffset_value_sub_2.x and ExMsg.y == SetScreenPixelOffset_value_sub_2.y)then
        SetScreenPixelOffset_V2.y = SetScreenPixelOffset_V2.y - 1
        SetScreenPixelOffset_value_sub_2_BottonColor = 0x1
    else
        SetScreenPixelOffset_value_sub_2_BottonColor = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetScreenPixelOffset_value_sub_2.addx and ExMsg.y == SetScreenPixelOffset_value_sub_2.addy)then
        SetScreenPixelOffset_V2.y = SetScreenPixelOffset_V2.y + 1
        SetScreenPixelOffset_value_sub_2_BottonColor_add = 0x1
    else
        SetScreenPixelOffset_value_sub_2_BottonColor_add = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x >= SetScreenPixelOffset_ReSet.x and ExMsg.y >= SetScreenPixelOffset_ReSet.y and ExMsg.x <= SetScreenPixelOffset_ReSet.right and ExMsg.y <= SetScreenPixelOffset_ReSet.bottom)then
        SetScreenPixelOffset_V2.x = 0
        SetScreenPixelOffset_V2.y = 0
        SetScreenPixelOffset_ReSet_BottonColor = 0x1
    else
        SetScreenPixelOffset_ReSet_BottonColor = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x >= SetScreenPixelOffset_Load.x and ExMsg.y >= SetScreenPixelOffset_Load.y and ExMsg.x <= SetScreenPixelOffset_Load.right and ExMsg.y <= SetScreenPixelOffset_Load.bottom)then
        IO_i = 1
        for line in io.lines("HUD.data") do
            HUD_DataTable[IO_i] = tonumber(line)
            IO_i = IO_i + 1
        end
        SetScreenPixelOffset_V2.x = HUD_DataTable[7]
        SetScreenPixelOffset_V2.y = HUD_DataTable[8]
        SetScreenPixelOffset_Load_BottonColor = 0x1
    else
        SetScreenPixelOffset_Load_BottonColor = 0x800
    end
end

function SetOriginAndSetScreenPos()
    --原点
    MCCDrawTextR(SetOrigin.x,SetOrigin.y,"SetOrigin",0x1,SetOrigin_BottonColor)
    if(SetOrigin_BOOL == 1)then
        SetOrigin_BottonColor = 0x4000
        if(os.clock() - SetOrigin_timeSave >= SetOrigin_time)then
            local _q = {}
            _q.x = -q.x
            _q.y = -q.y
            _q.z = -q.z
            _q.w = q.w
            line_point_OnShip = RotateVectorByQuat(_q,Vector3:new(PlayerPos.x - Ps.x,PlayerPos.y - Ps.y,PlayerPos.z - Ps.z))
            SetOrigin_BOOL = 0
        end
        MCCDrawTextR(SetOrigin.right + 1,SetOrigin.y,string.format(" %.1fs",SetOrigin_time - os.clock() + SetOrigin_timeSave),0x1,SetOrigin_BottonColor)
    else
        SetOrigin_BottonColor = 0x2000
    end
    --x
    MCCDrawTextR(SetOrigin_value_sub_1.x,SetOrigin_value_sub_1.y,"-",0x1,SetOrigin_value_sub_1_BottonColor)
    MCCDrawTextR(SetOrigin_value_sub_1.x + 1,SetOrigin_value_sub_1.y,string.format("x:%.1f",line_point_OnShip.x),0x1,bkcolor_CC)
    SetOrigin_value_sub_1.addx,SetOrigin_value_sub_1.addy = term.getCursorPos()
    MCCDrawTextR_NoXY("+",0x1,SetOrigin_value_sub_1_BottonColor_add)
    --y
    MCCDrawTextR(SetOrigin_value_sub_2.x,SetOrigin_value_sub_2.y,"-",0x1,SetOrigin_value_sub_2_BottonColor)
    MCCDrawTextR(SetOrigin_value_sub_2.x + 1,SetOrigin_value_sub_2.y,string.format("y:%.1f",line_point_OnShip.y),0x1,bkcolor_CC)
    SetOrigin_value_sub_2.addx,SetOrigin_value_sub_2.addy = term.getCursorPos()
    MCCDrawTextR_NoXY("+",0x1,SetOrigin_value_sub_2_BottonColor_add)
    --z
    MCCDrawTextR(SetOrigin_value_sub_3.x,SetOrigin_value_sub_3.y,"-",0x1,SetOrigin_value_sub_3_BottonColor)
    MCCDrawTextR(SetOrigin_value_sub_3.x + 1,SetOrigin_value_sub_3.y,string.format("z:%.1f",line_point_OnShip.z),0x1,bkcolor_CC)
    SetOrigin_value_sub_3.addx,SetOrigin_value_sub_3.addy = term.getCursorPos()
    MCCDrawTextR_NoXY("+",0x1,SetOrigin_value_sub_3_BottonColor_add)
    --重置
    MCCDrawTextR(SetOrigin_ReSet.x,SetOrigin_ReSet.y,"ReSet",0x1,SetOrigin_ReSet_BottonColor)
    --加载
    MCCDrawTextR(SetOrigin_Load.x,SetOrigin_Load.y,"Load",0x1,SetOrigin_Load_BottonColor)

    --屏幕位置
    MCCDrawTextR(SetScreenPos.x,SetScreenPos.y,"SetScreenPos",0x1,SetScreenPos_BottonColor)
    --x
    MCCDrawTextR(SetScreenPos_value_sub_1.x,SetScreenPos_value_sub_1.y,"-",0x1,SetScreenPos_value_sub_1_BottonColor)
    MCCDrawTextR(SetScreenPos_value_sub_1.x + 1,SetScreenPos_value_sub_1.y,string.format("x:%.1f",HUDscreenPs_OnShip.x),0x1,bkcolor_CC)
    SetScreenPos_value_sub_1.addx,SetScreenPos_value_sub_1.addy = term.getCursorPos()
    MCCDrawTextR_NoXY("+",0x1,SetScreenPos_value_sub_1_BottonColor_add)
    --y
    MCCDrawTextR(SetScreenPos_value_sub_2.x,SetScreenPos_value_sub_2.y,"-",0x1,SetScreenPos_value_sub_2_BottonColor)
    MCCDrawTextR(SetScreenPos_value_sub_2.x + 1,SetScreenPos_value_sub_2.y,string.format("y:%.1f",HUDscreenPs_OnShip.y),0x1,bkcolor_CC)
    SetScreenPos_value_sub_2.addx,SetScreenPos_value_sub_2.addy = term.getCursorPos()
    MCCDrawTextR_NoXY("+",0x1,SetScreenPos_value_sub_2_BottonColor_add)
    --z
    MCCDrawTextR(SetScreenPos_value_sub_3.x,SetScreenPos_value_sub_3.y,"-",0x1,SetScreenPos_value_sub_3_BottonColor)
    MCCDrawTextR(SetScreenPos_value_sub_3.x + 1,SetScreenPos_value_sub_3.y,string.format("z:%.1f",HUDscreenPs_OnShip.z),0x1,bkcolor_CC)
    SetScreenPos_value_sub_3.addx,SetScreenPos_value_sub_3.addy = term.getCursorPos()
    MCCDrawTextR_NoXY("+",0x1,SetScreenPos_value_sub_3_BottonColor_add)
    --重置
    MCCDrawTextR(SetScreenPos_ReSet.x,SetScreenPos_ReSet.y,"ReSet",0x1,SetScreenPos_ReSet_BottonColor)
    --加载
    MCCDrawTextR(SetScreenPos_Load.x,SetScreenPos_Load.y,"Load",0x1,SetScreenPos_Load_BottonColor)
end

function SetOriginAndSetScreenPos_B()
    --原点
    if(ExMsg.botton == 1 and ExMsg.x >= SetOrigin.x and ExMsg.y >= SetOrigin.y and ExMsg.x <= SetOrigin.right and ExMsg.y <= SetOrigin.bottom)then
        SetOrigin_timeSave = os.clock();
        SetOrigin_BOOL = 1
        SetOrigin_BottonColor =  0x1
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetOrigin_value_sub_1.x and ExMsg.y == SetOrigin_value_sub_1.y)then
        line_point_OnShip.x = line_point_OnShip.x - 0.1
        SetOrigin_value_sub_1_BottonColor = 0x1
    else
        SetOrigin_value_sub_1_BottonColor = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetOrigin_value_sub_1.addx and ExMsg.y == SetOrigin_value_sub_1.addy)then
        line_point_OnShip.x = line_point_OnShip.x + 0.1
        SetOrigin_value_sub_1_BottonColor_add = 0x1
    else
        SetOrigin_value_sub_1_BottonColor_add = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetOrigin_value_sub_2.x and ExMsg.y == SetOrigin_value_sub_2.y)then
        line_point_OnShip.y = line_point_OnShip.y - 0.1
        SetOrigin_value_sub_2_BottonColor = 0x1
    else
        SetOrigin_value_sub_2_BottonColor = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetOrigin_value_sub_2.addx and ExMsg.y == SetOrigin_value_sub_2.addy)then
        line_point_OnShip.y = line_point_OnShip.y + 0.1
        SetOrigin_value_sub_2_BottonColor_add = 0x1
    else
        SetOrigin_value_sub_2_BottonColor_add = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetOrigin_value_sub_3.x and ExMsg.y == SetOrigin_value_sub_3.y)then
        line_point_OnShip.z = line_point_OnShip.z - 0.1
        SetOrigin_value_sub_3_BottonColor = 0x1
    else
        SetOrigin_value_sub_3_BottonColor = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetOrigin_value_sub_3.addx and ExMsg.y == SetOrigin_value_sub_3.addy)then
        line_point_OnShip.z = line_point_OnShip.z + 0.1
        SetOrigin_value_sub_3_BottonColor_add = 0x1
    else
        SetOrigin_value_sub_3_BottonColor_add = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x >= SetOrigin_ReSet.x and ExMsg.y >= SetOrigin_ReSet.y and ExMsg.x <= SetOrigin_ReSet.right and ExMsg.y <= SetOrigin_ReSet.bottom)then
        line_point_OnShip.x = 0
        line_point_OnShip.y = 0
        line_point_OnShip.z = 0
        SetOrigin_ReSet_BottonColor = 0x1
    else
        SetOrigin_ReSet_BottonColor = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x >= SetOrigin_Load.x and ExMsg.y >= SetOrigin_Load.y and ExMsg.x <= SetOrigin_Load.right and ExMsg.y <= SetOrigin_Load.bottom)then
        IO_i = 1
        for line in io.lines("HUD.data") do
            HUD_DataTable[IO_i] = tonumber(line)
            IO_i = IO_i + 1
        end
        line_point_OnShip.x = HUD_DataTable[1]
        line_point_OnShip.y = HUD_DataTable[2]
        line_point_OnShip.z = HUD_DataTable[3]
        SetOrigin_Load_BottonColor = 0x1
    else
        SetOrigin_Load_BottonColor = 0x800
    end
    --屏幕位置
    if(ExMsg.botton == 1 and ExMsg.x == SetScreenPos_value_sub_1.x and ExMsg.y == SetScreenPos_value_sub_1.y)then
        HUDscreenPs_OnShip.x = HUDscreenPs_OnShip.x - 0.5
        SetScreenPos_value_sub_1_BottonColor = 0x1
    else
        SetScreenPos_value_sub_1_BottonColor = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetScreenPos_value_sub_1.addx and ExMsg.y == SetScreenPos_value_sub_1.addy)then
        HUDscreenPs_OnShip.x = HUDscreenPs_OnShip.x + 0.5
        SetScreenPos_value_sub_1_BottonColor_add = 0x1
    else
        SetScreenPos_value_sub_1_BottonColor_add = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetScreenPos_value_sub_2.x and ExMsg.y == SetScreenPos_value_sub_2.y)then
        HUDscreenPs_OnShip.y = HUDscreenPs_OnShip.y - 0.5
        SetScreenPos_value_sub_2_BottonColor = 0x1
    else
        SetScreenPos_value_sub_2_BottonColor = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetScreenPos_value_sub_2.addx and ExMsg.y == SetScreenPos_value_sub_2.addy)then
        HUDscreenPs_OnShip.y = HUDscreenPs_OnShip.y + 0.5
        SetScreenPos_value_sub_2_BottonColor_add = 0x1
    else
        SetScreenPos_value_sub_2_BottonColor_add = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetScreenPos_value_sub_3.x and ExMsg.y == SetScreenPos_value_sub_3.y)then
        HUDscreenPs_OnShip.z = HUDscreenPs_OnShip.z - 0.5
        SetScreenPos_value_sub_3_BottonColor = 0x1
    else
        SetScreenPos_value_sub_3_BottonColor = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x == SetScreenPos_value_sub_3.addx and ExMsg.y == SetScreenPos_value_sub_3.addy)then
        HUDscreenPs_OnShip.z = HUDscreenPs_OnShip.z + 0.5
        SetScreenPos_value_sub_3_BottonColor_add = 0x1
    else
        SetScreenPos_value_sub_3_BottonColor_add = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x >= SetScreenPos_ReSet.x and ExMsg.y >= SetScreenPos_ReSet.y and ExMsg.x <= SetScreenPos_ReSet.right and ExMsg.y <= SetScreenPos_ReSet.bottom)then
        HUDscreenPs_OnShip.x = 0
        HUDscreenPs_OnShip.y = 0
        HUDscreenPs_OnShip.z = 0
        SetScreenPos_ReSet_BottonColor = 0x1
    else
        SetScreenPos_ReSet_BottonColor = 0x800
    end
    if(ExMsg.botton == 1 and ExMsg.x >= SetScreenPos_Load.x and ExMsg.y >= SetScreenPos_Load.y and ExMsg.x <= SetScreenPos_Load.right and ExMsg.y <= SetScreenPos_Load.bottom)then
        IO_i = 1
        for line in io.lines("HUD.data") do
            HUD_DataTable[IO_i] = tonumber(line)
            IO_i = IO_i + 1
        end
        HUDscreenPs_OnShip.x = HUD_DataTable[4]
        HUDscreenPs_OnShip.y = HUD_DataTable[5]
        HUDscreenPs_OnShip.z = HUD_DataTable[6]
        SetScreenPos_Load_BottonColor = 0x1
    else
        SetScreenPos_Load_BottonColor = 0x800
    end
end

function HUDsetting_P1()
    --标题
    MCCDrawLineR(1,1,CCscreenSize.x,1,0x80)
    MCCDrawTextR(TitlePosition.x,TitlePosition.y,"HUDsetting P1",0x1,0x80)

    --功能
    --夜视
    MCCDrawTextR(NightVisionMode.x,NightVisionMode.y,"NightVisionMode",0x1,NightVisionMode_BottonColor)
    if(NightVisionMode_BOOL == 1)then
        hologram.SetClearColor(0x00AA00AA)
        NightVisionMode_BottonColor = 0x2000
    else
        hologram.SetClearColor(0x1)
        NightVisionMode_BottonColor = 0x4000	
    end

    SetOriginAndSetScreenPos()

    SetScreenPixelOffset_D()

    --调试模式
    MCCDrawTextR(DebuggerMod.x,DebuggerMod.y,"DebuggerMod",0x1,DebuggerMod_BottonColor)
    if(DebuggerMod_flag == 1)then
        DebuggerMod_BottonColor = 0x2000
    else
        DebuggerMod_BottonColor = 0x4000	
    end

    --前后成像
    MCCDrawTextR(BOrFMod.x,BOrFMod.y,"BOrFMod",0x1,BOrFMod_BottonColor)
    if(BOrFMod_flag == 1)then
        BOrFMod_BottonColor = 0x2000
        MCCDrawTextR(BOrFMod.right + 1,BOrFMod.y,string.format(" former %d",BOrFMod_flag),0x1,bkcolor_CC)
    else
        BOrFMod_BottonColor = 0x4000
        MCCDrawTextR(BOrFMod.right + 1,BOrFMod.y,string.format(" back %d",BOrFMod_flag),0x1,bkcolor_CC)
    end

    --返回按钮
    MCCDrawTextR(BackBottonPosition.x,BackBottonPosition.y,"<Back",0x1,0x80)
    --保存
    MCCDrawTextR(Save.x,Save.y,"Save",0x1,Save_BottonColor)
    --下一页
    MCCDrawTextR(NextBottonPosition.x,NextBottonPosition.y,"Next>",0x1,0x80)
end

function HUDsetting_P2()
    --标题
    MCCDrawLineR(1,1,CCscreenSize.x,1,0x80)
    MCCDrawTextR(TitlePosition.x,TitlePosition.y,"HUDsetting P2",0x1,0x80)

    --功能


    --返回按钮
    MCCDrawTextR(BackBottonPosition.x,BackBottonPosition.y,"<Back",0x1,0x80)
end

function SettingMap()
    --标题
    MCCDrawLineR(1,1,CCscreenSize.x,1,0x80)
    MCCDrawTextR(TitlePosition.x,TitlePosition.y,"Setting",0x1,0x80)



    --HUD设置
    MCCDrawTextR(HUDbottonPosition.x,HUDbottonPosition.y,"HUD",0x1,0x2000)
end

function UIChange()
    if(ExMsg)then
        --HUD设置界面操作判断
        if(nowUiIDshow == UiID["HUDsetting_P1"])then
            --固定按钮
            if(ExMsg.botton == 1 and ExMsg.x >= BackBottonPosition.x and ExMsg.y >= BackBottonPosition.y and ExMsg.x <= BackBottonPosition.right and ExMsg.y <= BackBottonPosition.bottom)then
                nowUiIDshow = UiID["SettingMap"]
            end
            if(ExMsg.botton == 1 and ExMsg.x >= NextBottonPosition.x and ExMsg.y >= NextBottonPosition.y and ExMsg.x <= NextBottonPosition.right and ExMsg.y <= NextBottonPosition.bottom)then
                nowUiIDshow = UiID["HUDsetting_P2"]
            end
            --夜视
            if(ExMsg.botton == 1 and ExMsg.x >= NightVisionMode.x and ExMsg.y >= NightVisionMode.y and ExMsg.x <= NightVisionMode.right and ExMsg.y <= NightVisionMode.bottom)then
                NightVisionMode_BOOL = NightVisionMode_BOOL + 1
                if(NightVisionMode_BOOL > 1)then
                    NightVisionMode_BOOL = 0
                end
                NightVisionMode_BottonColor = 0x1
            end
            SetOriginAndSetScreenPos_B()
            SetScreenPixelOffset_B()
            --调试模式
            if(ExMsg.botton == 1 and ExMsg.x >= DebuggerMod.x and ExMsg.y >= DebuggerMod.y and ExMsg.x <= DebuggerMod.right and ExMsg.y <= DebuggerMod.bottom)then
                DebuggerMod_flag = DebuggerMod_flag + 1
                if(DebuggerMod_flag > 1)then
                    DebuggerMod_flag = 0
                end
                DebuggerMod_BottonColor = 0x1
            end
            --前后成像
            if(ExMsg.botton == 1 and ExMsg.x >= BOrFMod.x and ExMsg.y >= BOrFMod.y and ExMsg.x <= BOrFMod.right and ExMsg.y <= BOrFMod.bottom)then
                BOrFMod_flag = BOrFMod_flag + 1
                if(BOrFMod_flag > 1)then
                    BOrFMod_flag = 0
                end
                BOrFMod_BottonColor = 0x1
            end
        end
        if(nowUiIDshow == UiID["HUDsetting_P2"])then
            --固定按钮
            if(ExMsg.botton == 1 and ExMsg.x >= BackBottonPosition.x and ExMsg.y >= BackBottonPosition.y and ExMsg.x <= BackBottonPosition.right and ExMsg.y <= BackBottonPosition.bottom)then
                nowUiIDshow = UiID["HUDsetting_P1"]
            end
        end
        if(ExMsg.botton == 1 and ExMsg.x >= Save.x and ExMsg.y >= Save.y and ExMsg.x <= Save.right and ExMsg.y <= Save.bottom)then
            HUD_DataTable_W[1] = line_point_OnShip.x
            HUD_DataTable_W[2] = line_point_OnShip.y
            HUD_DataTable_W[3] = line_point_OnShip.z
            HUD_DataTable_W[4] = HUDscreenPs_OnShip.x
            HUD_DataTable_W[5] = HUDscreenPs_OnShip.y
            HUD_DataTable_W[6] = HUDscreenPs_OnShip.z
            HUD_DataTable_W[7] = SetScreenPixelOffset_V2.x
            HUD_DataTable_W[8] = SetScreenPixelOffset_V2.y
            HUDdata = io.open("HUD.data","r+")
            io.output(HUDdata)
            io.write(HUD_DataTable_W[1],"\n",HUD_DataTable_W[2],"\n",HUD_DataTable_W[3],"\n",HUD_DataTable_W[4],"\n",HUD_DataTable_W[5],"\n",HUD_DataTable_W[6],"\n",HUD_DataTable_W[7],"\n",HUD_DataTable_W[8])
            io.close(HUDdata)
            Save_BottonColor = 0x1
        else
            Save_BottonColor = 0x80
        end
        --设置菜单界面判断
        if(nowUiIDshow == UiID["SettingMap"])then
            if(ExMsg.botton == 1 and ExMsg.x >= HUDbottonPosition.x and ExMsg.y >= HUDbottonPosition.y and ExMsg.x <= HUDbottonPosition.right and ExMsg.y <= HUDbottonPosition.bottom)then
                nowUiIDshow = UiID["HUDsetting_P1"]
            end
        end
    end
end

--HUD相关
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

function quaternionMultiply(q1, q2)
    -- 返回两个四元数的乘积
    local Q = {
        w = q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z,
        x = q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y,
        y = q1.w * q2.y - q1.x * q2.z + q1.y * q2.w + q1.z * q2.x,
        z = q1.w * q2.z + q1.x * q2.y - q1.y * q2.x + q1.z * q2.w
    }
    return Q
end

function rotateVectorWithQuaternion(vector, quaternion)
    local q = quaternion
    local v = {w = 0, x = vector.x, y = vector.y, z = vector.z}  -- 将向量转为四元数

    -- 旋转
    local q_conjugate = {w = q.w,x = -q.x,y = -q.y,z = -q.z}
    local rotated = quaternionMultiply(quaternionMultiply(q, v), q_conjugate)

    local result = {x = rotated.x, y = rotated.y, z = rotated.z}

    return result
end

function BakeBitMap(buf, color)
    local b = {}
    i = 0
    for _, v in ipairs(buf) do
        if v == 1 then
            b[i] = color
        else
            b[i] = 0x00000000
        end
        i = i + 1
    end
    return b
end

local HUDandShipPOSoffset = {x = 0,y = 0,z = 0}
function GetPosition()
    ShipWorldPos = ship.getWorldspacePosition()
    ShipyardPS = ship.getShipyardPosition()
    q = ship.getQuaternion()
    velocity = ship.getVelocity()
    ShipyardHUDPos.x,ShipyardHUDPos.y,ShipyardHUDPos.z = hologram.GetBlockPos()
    HUDandShipPOSoffset = {x = ShipyardPS.x - ShipyardHUDPos.x,y = ShipyardPS.y - ShipyardHUDPos.y,z = ShipyardPS.z - ShipyardHUDPos.z}
    local GPq = {}
    GPq.x = -q.x
    GPq.y = -q.y
    GPq.z = -q.z
    GPq.w = q.w
    HUDonShip = RotateVectorByQuat(GPq,HUDandShipPOSoffset)
    Ps = ship.getWorldspacePosition()
end

function computePlanePositon()
    local _q_vrq = {}
    _q_vrq.x = -q.x
    _q_vrq.y = -q.y
    _q_vrq.z = -q.z
    _q_vrq.w = -q.w
    --屏幕坐标
    HUDscreenPs_offset = RotateVectorByQuat(_q_vrq,Vector3:new(HUDscreenPs_OnShip.x,HUDscreenPs_OnShip.y,HUDscreenPs_OnShip.z))
    HUDscreenPs = Vector3:new(Ps.x + HUDscreenPs_offset.x,Ps.y + HUDscreenPs_offset.y,Ps.z + HUDscreenPs_offset.z)
    --平面
    Plane_point = {HUDscreenPs.x ,HUDscreenPs.y,HUDscreenPs.z}
    plane_ABC_V3 = RotateVectorByQuat(_q_vrq,Vector3:new(0,0,1))
    plane_coefficients = {plane_ABC_V3.x, plane_ABC_V3.y, plane_ABC_V3.z}  -- 平面的系数 (A, B, C)
    --直线
    line_point_offset = RotateVectorByQuat(_q_vrq,line_point_OnShip)
    line_point = {Ps.x + line_point_offset.x,Ps.y + line_point_offset.y,Ps.z + line_point_offset.z}
end

function MdrawText(x,y,text,color)
    for i = 1,#text,1 do
        hologram.Blit(x + i * 4 - 4,y,3,5,BakeBitMap(TEXT_Table[string.sub(text,i,i)],color),2)
    end
end

function WMdrawText(x,y,text,color,WINTABLE)
    for i = 1,#text,1 do
        if(x >= WINTABLE.left and y >= WINTABLE.top and x <= WINTABLE.right and y <= WINTABLE.bottom)then
            hologram.Blit(x + i * 4 - 4,y,3,5,BakeBitMap(TEXT_Table[string.sub(text,i,i)],color),2)
        end
    end
end

function getCoordinates(angle, radius)--已知角和半径求坐标
    local radians = angle * math.pi / 180

    local x = radius * math.cos(radians)
    local y = radius * math.sin(radians)

    return x, y
end

function W_MdrawLine(x,y,x_,y_,color,windowTable)
    local dx = x_ - x
    local dy = y_ - y
    local k = dy / dx

    local e = 0
    if(math.abs(k) > 1)then
        e = math.abs(dy)
    else
        e = math.abs(dx)
    end
    local xadd = dx / e
    local yadd = dy / e

    for i = 0,e,1 do
        if not(x + 0.5 < windowTable.left or y + 0.5 < windowTable.top or x + 0.5 > windowTable.right or y + 0.5 > windowTable.bottom)then
            hologram.Fill(x - 0.5,y - 0.5,1,1,color,0)
        end
        x = x + xadd
        y = y + yadd
    end
end


function drawCircleLine(centerX, centerY, radius, segments,colors,windowTable)
    local angleIncrement = 2 * math.pi / segments  -- 每一段的角度增加
    local lastX = centerX + radius  -- 起始点的 x 坐标
    local lastY = centerY           -- 起始点的 y 坐标

    for i = 1, segments + 1 do
        local angle = i * angleIncrement
        local x = centerX + radius * math.cos(angle)
        local y = centerY + radius * math.sin(angle)

        -- 画线段从 lastX，lastY 到 x，y
        W_MdrawLine(lastX, lastY,x, y,colors,windowTable)

        lastX = x
        lastY = y
    end
end

function drawPolygon(Points,lineNum,linecolor,WINTABLE)
    for i = 1,lineNum,1 do
        if(i == lineNum - 1)then
            W_MdrawLine(Points[i] + 1,Points[i + 1] + 1,Points[1] + 1,Points[2] + 1,linecolor,WINTABLE)
            break
        elseif((i + 1) % 2 == 0)then
            W_MdrawLine(Points[i] + 1,Points[i + 1] + 1,Points[i + 2] + 1,Points[i + 3] + 1,linecolor,WINTABLE)
        end
    end
end

local projectionMatrix = {
    {HologramSize.x, 0, 0, 0},  -- 实际中应根据视图和透视参数计算
    {0, HologramSize.y, 0, 0},
    {0, 0, -1, -1},
    {0, 0, -2, 0}
}

function projectToScreen(vertex, projectionMatrix, screenWidth, screenHeight)
    -- 齐次坐标
    local x, y, z = vertex[1], vertex[2], vertex[3]
    local w = 1  -- 齐次坐标的 w 部分
    local v_prime = {}

    -- 使用投影矩阵转换坐标
    v_prime[1] = projectionMatrix[1][1] * x + projectionMatrix[1][4] * w
    v_prime[2] = projectionMatrix[2][2] * y + projectionMatrix[2][4] * w
    v_prime[3] = projectionMatrix[3][3] * z + projectionMatrix[3][4] * w
    w = projectionMatrix[3][4] * w

    -- 齐次除法
    if w ~= 0 then
        local x_normalized = v_prime[1] / w
        local y_normalized = v_prime[2] / w

        -- 计算屏幕坐标
        local screenX = (x_normalized + 1) * 0.5 * screenWidth
        local screenY = (1 - y_normalized) * 0.5 * screenHeight
        
        return screenX, screenY
    else
        return nil, nil  -- 无效坐标
    end
end

--整合
function DrawPitchAndRoll(x,y,WINTABLE)
    if(string.format("%.1f", Ag.roll) == "0.0")then
        Ag.roll = -Ag.roll
    end

    local yaw
    local pitch
    local roll
    if(BOrFMod_flag == 1)then
        yaw = -Ag.yaw
        pitch = -Ag.pitch
        roll = -Ag.roll
    else
        yaw = Ag.yaw
        pitch = Ag.pitch
        roll = Ag.roll
    end
    --local Lx, Ly = getCoordinates(-Ag.roll,24)
    --local Lx1, Ly1 = getCoordinates(-Ag.roll,7)
    --local Lx2, Ly2 = getCoordinates(-Ag.roll - 90,13)
    --local Lx3, Ly3 = getCoordinates(-Ag.roll - 90,7)

    --线的参数
    --地平线
    local DiPinXianChuShiWeiZhi = 10
    local DiPinXianChang = 50
    --俯仰梯
    local FuYangTiChuShiWeiZhi = 10
    local FuYangTiChang = 13

    local ShuXianWeiZhi = 10
    local ShuXianChang = 3

    local XuXianJianGe = 5

    local XuXian1WeiZhi = FuYangTiChuShiWeiZhi + 1
    local XuXian1Chang = (FuYangTiChang - XuXianJianGe * 4) / 4

    local XuXian2WeiZhi = XuXian1WeiZhi + (FuYangTiChang - XuXianJianGe * 4) / 4 * 1 + XuXianJianGe
    local XuXian2Chang = (FuYangTiChang - XuXianJianGe * 4) / 4

    local XuXian3WeiZhi = XuXian1WeiZhi + (FuYangTiChang - XuXianJianGe * 4) / 4 * 2 + XuXianJianGe * 2
    local XuXian3Chang = (FuYangTiChang - XuXianJianGe * 4) / 4

    local XuXian4WeiZhi = XuXian1WeiZhi + (FuYangTiChang - XuXianJianGe * 4) / 4 * 3 + XuXianJianGe * 3
    local XuXian4Chang = (FuYangTiChang - XuXianJianGe * 4) / 4

    local TextWeiZhiLeftZheng = {x = FuYangTiChuShiWeiZhi + FuYangTiChang - 3,y = -1}
    local TextWeiZhiRightZheng = {x = FuYangTiChuShiWeiZhi + FuYangTiChang + 3,y = -1}

    local TextWeiZhiLeft = {x = FuYangTiChuShiWeiZhi + FuYangTiChang - 3,y = 6}
    local TextWeiZhiRight = {x = FuYangTiChuShiWeiZhi + FuYangTiChang + 3,y = 6}


    local showYBiZhi = 1300/180
    local lineY = y - string.format("%.1f",showYBiZhi * pitch)
    local Px, Py = getCoordinates(roll - 90,lineY - 100)
    local Px1, Py1 = getCoordinates(roll,DiPinXianChuShiWeiZhi + DiPinXianChang) 
    local Px2, Py2 = getCoordinates(roll,DiPinXianChuShiWeiZhi) 
    local Px3, Py3
    local WIN_table = WINTABLE
    W_MdrawLine(x + Px + Px2 + 1,y + Py + Py2 + 1,x + Px + Px1 + 1,y + Py + Py1 + 1,signcolor,WIN_table)
    W_MdrawLine(x + Px - Px2 + 1,y + Py - Py2 + 1,x + Px - Px1 + 1,y + Py - Py1 + 1,signcolor,WIN_table)
    for i = 1,90/5,1 do
        lineY = y - string.format("%.1f",showYBiZhi * pitch - showYBiZhi * (180/36*i))
        Px, Py = getCoordinates(roll - 90,lineY - 100)
        Px1, Py1 = getCoordinates(roll,FuYangTiChuShiWeiZhi + FuYangTiChang) 
        Px2, Py2 = getCoordinates(roll,FuYangTiChuShiWeiZhi) 
        W_MdrawLine(x + Px + Px2 + 1,y + Py + Py2 + 1,x + Px + Px1 + 1,y + Py + Py1 + 1,signcolor,WIN_table)
        W_MdrawLine(x + Px - Px2 + 1,y + Py - Py2 + 1,x + Px - Px1 + 1,y + Py - Py1 + 1,signcolor,WIN_table)
        Px1, Py1 = getCoordinates(roll,ShuXianWeiZhi) 
        Px3,Py3 = getCoordinates(roll - 90,ShuXianChang)
        W_MdrawLine(x + Px + Px1 - Px3 + 1,y + Py + Py1 - Py3 + 1,x + Px + Px1 + 1,y + Py + Py1 + 1,signcolor,WIN_table)
        W_MdrawLine(x + Px - Px1 - Px3 + 1,y + Py - Py1 - Py3 + 1,x + Px - Px1 + 1,y + Py - Py1 + 1,signcolor,WIN_table)
        --Px1, Py1 = getCoordinates(-Ag.roll,TextWeiZhiLeftZheng.x)
        --Px3, Py3 = getCoordinates(-Ag.roll - 90,TextWeiZhiLeftZheng.y)
        --WMdrawText(x + Px + Px1 + Px3 + 1,y + Py + Py1 + Py3 + 1,string.format("%d",180/36*i),signcolor,WIN_table)
        Px1, Py1 = getCoordinates(roll,TextWeiZhiRightZheng.x) 
        Px3, Py3 = getCoordinates(roll - 90,TextWeiZhiRightZheng.y - 1)
        WMdrawText(x + Px - Px1 + Px3 + 1,y + Py - Py1 + Py3 + 1,string.format("%d",180/36*i),signcolor,WIN_table)
    end
    for i = 1,90/5,1 do
        lineY = y - string.format("%.1f",showYBiZhi * pitch + showYBiZhi * (180/36*i))
        Px, Py = getCoordinates(roll - 90,lineY - 100)
        Px1, Py1 = getCoordinates(roll,XuXian1WeiZhi + XuXian1Chang) 
        Px2, Py2 = getCoordinates(roll,XuXian1WeiZhi) 
        W_MdrawLine(x + Px + Px2 + 1,y + Py + Py2 + 1,x + Px + Px1 + 1,y + Py + Py1 + 1,signcolor,WIN_table)
        W_MdrawLine(x + Px - Px2 + 1,y + Py - Py2 + 1,x + Px - Px1 + 1,y + Py - Py1 + 1,signcolor,WIN_table)
        Px1, Py1 = getCoordinates(roll,XuXian2WeiZhi + XuXian2Chang) 
        Px2, Py2 = getCoordinates(roll,XuXian2WeiZhi) 
        W_MdrawLine(x + Px + Px2 + 1,y + Py + Py2 + 1,x + Px + Px1 + 1,y + Py + Py1 + 1,signcolor,WIN_table)
        W_MdrawLine(x + Px - Px2 + 1,y + Py - Py2 + 1,x + Px - Px1 + 1,y + Py - Py1 + 1,signcolor,WIN_table)
        Px1, Py1 = getCoordinates(roll,XuXian3WeiZhi + XuXian3Chang) 
        Px2, Py2 = getCoordinates(roll,XuXian3WeiZhi) 
        W_MdrawLine(x + Px + Px2 + 1,y + Py + Py2 + 1,x + Px + Px1 + 1,y + Py + Py1 + 1,signcolor,WIN_table)
        W_MdrawLine(x + Px - Px2 + 1,y + Py - Py2 + 1,x + Px - Px1 + 1,y + Py - Py1 + 1,signcolor,WIN_table)
        Px1, Py1 = getCoordinates(roll,XuXian4WeiZhi + XuXian4Chang) 
        Px2, Py2 = getCoordinates(roll,XuXian4WeiZhi) 
        W_MdrawLine(x + Px + Px2 + 1,y + Py + Py2 + 1,x + Px + Px1 + 1,y + Py + Py1 + 1,signcolor,WIN_table)
        W_MdrawLine(x + Px - Px2 + 1,y + Py - Py2 + 1,x + Px - Px1 + 1,y + Py - Py1 + 1,signcolor,WIN_table)
        Px1, Py1 = getCoordinates(roll,ShuXianWeiZhi) 
        Px3, Py3 = getCoordinates(roll - 90,ShuXianChang)
        W_MdrawLine(x + Px + Px1 + Px3 + 1,y + Py + Py1 + Py3 + 1,x + Px + Px1 + 1,y + Py + Py1 + 1,signcolor,WIN_table)
        W_MdrawLine(x + Px - Px1 + Px3 + 1,y + Py - Py1 + Py3 + 1,x + Px - Px1 + 1,y + Py - Py1 + 1,signcolor,WIN_table)
        --Px1, Py1 = getCoordinates(-Ag.roll,TextWeiZhiLeft.x)
        --Px3, Py3 = getCoordinates(-Ag.roll - 90,TextWeiZhiLeft.y)
        --WMdrawText(x + Px + Px1 + Px3 + 1,y + Py + Py1 + Py3 + 1,string.format("%d",-(180/36*i)),signcolor,WIN_table)
        Px1, Py1 = getCoordinates(roll,TextWeiZhiRight.x) 
        Px3, Py3 = getCoordinates(roll - 90,TextWeiZhiRight.y)
        WMdrawText(x + Px - Px1 + Px3 + 1,y + Py - Py1 + Py3 + 1,string.format("%d",-(180/36*i)),signcolor,WIN_table)
    end
end

local HUDsOffsetX = 0--x=20 x=10 
local HUDsOffsetY = 40--y=40 y=30
function guidancePoint(x,y,targetXYZ_,color)
    local xOffset = 3
    local yOffset = 3
    local targetXYZ = targetXYZ_
    local PlayerToShipZ = 2
    local HUDtoShip = 2
    local Gpoint_ = {x = targetXYZ.x - (ShipWorldPos.x + HUDandShipPOSoffset.x),y = targetXYZ.y - (ShipWorldPos.y + HUDandShipPOSoffset.y),z = targetXYZ.z - (ShipWorldPos.z + HUDandShipPOSoffset.z)}

    local WindowTable = {left=0,top=0,right=HologramSize.x,bottom=HologramSize.y}

    local GPq = {}
    GPq.x = -q.x
    GPq.y = -q.y
    GPq.z = -q.z
    GPq.w = q.w
    local GpointOnHUD = RotateVectorByQuat(GPq,Gpoint_)
    local PlayerOnHUD = RotateVectorByQuat(GPq,{x = (ShipWorldPos.x + HUDandShipPOSoffset.x) - PlayerPos.x,y = (ShipWorldPos.y + HUDandShipPOSoffset.y) - PlayerPos.y,z = (ShipWorldPos.z + HUDandShipPOSoffset.z) - PlayerPos.z})
    local YuanDianToPinMu = {x = HologramSize.x / 2,y = HologramSize.y / 2,z = 2.5}--z=2.5 z=1.5
    --local YuanDianToPinMu = {x = PlayerOnHUD.x - 1/2 + HUDTranslation.x,y = PlayerOnHUD.y + 1 + 1/2 + HUDTranslation.y + 1,z = PlayerOnHUD.z - HUDTranslation.z + 1/2}
    --print (YuanDianToPinMu.y)

    --local Vx = (GpointOnHUD.x - PlayerOnHUD.x) / -(GpointOnHUD.z - YuanDianToPinMu.z) * YuanDianToPinMu.z
    --local Vy = (GpointOnHUD.y - PlayerOnHUD.y) / (GpointOnHUD.z - YuanDianToPinMu.z) * YuanDianToPinMu.z
    local Vx = (GpointOnHUD.x) / -(GpointOnHUD.z) * YuanDianToPinMu.z
    local Vy = (GpointOnHUD.y) / (GpointOnHUD.z) * YuanDianToPinMu.z

    local Psx = (Vx + 1) * (HologramSize.x + HUDsOffsetX) / 2--x=0 x=10 
    local Psy = (1 - Vy) * (HologramSize.y + HUDsOffsetY) / 2--y=40 y=30

    --local PsAx,PsAy = projectToScreen({targetXYZ.x,targetXYZ.y,targetXYZ.z},projectionMatrix,HologramSize.x,HologramSize.y)

    local Mx = Psx
    local My = Psy

    if(Mx and My)then
        if (Mx >= WindowTable.left and Mx <= WindowTable.right and My >= WindowTable.top and My <= WindowTable.bottom and GpointOnHUD.z >= 0)then
            drawPolygon({Mx - xOffset,My,Mx,My - yOffset,Mx + xOffset,My,Mx,My + yOffset},8,color,WindowTable) 
            --drawPolygon({Mx - xOffset,My - yOffset,Mx + xOffset,My - yOffset,Mx,My},6,red,WindowTable) 
        end
    end
end

function guidancePointXY(x,y,targetXYZ_,color,_HUDsOffsetX,_HUDsOffsetY)
    local xOffset = 3
    local yOffset = 3
    local targetXYZ = targetXYZ_
    local PlayerToShipZ = 2
    local HUDtoShip = 2
    local Gpoint_ = {x = targetXYZ.x - (ShipWorldPos.x + HUDandShipPOSoffset.x),y = targetXYZ.y - (ShipWorldPos.y + HUDandShipPOSoffset.y),z = targetXYZ.z - (ShipWorldPos.z + HUDandShipPOSoffset.z)}

    local WindowTable = {left=0,top=0,right=HologramSize.x,bottom=HologramSize.y}

    local GPq = {}
    GPq.x = -q.x
    GPq.y = -q.y
    GPq.z = -q.z
    GPq.w = q.w
    local GpointOnHUD = RotateVectorByQuat(GPq,Gpoint_)
    local PlayerOnHUD = RotateVectorByQuat(GPq,{x = (ShipWorldPos.x + HUDandShipPOSoffset.x) - line_point[1],y = (ShipWorldPos.y + HUDandShipPOSoffset.y) - line_point[2],z = (ShipWorldPos.z + HUDandShipPOSoffset.z) - line_point[3]})
    local YuanDianToPinMu = {x = HologramSize.x / 2,y = HologramSize.y / 2,z = 2.5}--z=2.5 z=1.5
    --local YuanDianToPinMu = {x = PlayerOnHUD.x,y = PlayerOnHUD.y,z = PlayerOnHUD.z}
    --print (YuanDianToPinMu.y)

    --local Vx = (GpointOnHUD.x - PlayerOnHUD.x) / -(GpointOnHUD.z - YuanDianToPinMu.z) * YuanDianToPinMu.z
    --local Vy = (GpointOnHUD.y - PlayerOnHUD.y) / (GpointOnHUD.z - YuanDianToPinMu.z) * YuanDianToPinMu.z
    local Vx = (GpointOnHUD.x) / -(GpointOnHUD.z) * YuanDianToPinMu.z
    local Vy = (GpointOnHUD.y) / (GpointOnHUD.z) * YuanDianToPinMu.z

    local Psx = (Vx + 1) * (HologramSize.x + _HUDsOffsetX) / 2--x=0 x=10 
    local Psy = (1 - Vy) * (HologramSize.y + _HUDsOffsetY) / 2--y=40 y=30

    local Mx = Psx
    local My = Psy

    local onHUD = false

    if (Mx >= WindowTable.left and Mx <= WindowTable.right and My >= WindowTable.top and My <= WindowTable.bottom and GpointOnHUD.z >= 0)then
        onHUD = true
    end

    return Mx,My,onHUD
end

function guidancePointLine(x,y,targetXYZ_,color)
    local xOffset = 3
    local yOffset = 3
    local targetXYZ = targetXYZ_
    local PlayerToShipZ = 2
    local HUDtoShip = 2
    local Gpoint_ = {x = targetXYZ.x - (ShipWorldPos.x + HUDandShipPOSoffset.x),y = targetXYZ.y - (ShipWorldPos.y + HUDandShipPOSoffset.y),z = targetXYZ.z - (ShipWorldPos.z + HUDandShipPOSoffset.z)}

    local WindowTable = {left=0,top=0,right=HologramSize.x,bottom=HologramSize.y}

    local GPq = {}
    GPq.x = -q.x
    GPq.y = -q.y
    GPq.z = -q.z
    GPq.w = q.w
    local GpointOnHUD = RotateVectorByQuat(GPq,Gpoint_)
    local PlayerOnHUD = RotateVectorByQuat(GPq,{x = (ShipWorldPos.x + HUDandShipPOSoffset.x) - PlayerPos.x,y = (ShipWorldPos.y + HUDandShipPOSoffset.y) - PlayerPos.y,z = (ShipWorldPos.z + HUDandShipPOSoffset.z) - PlayerPos.z})
    local YuanDianToPinMu = {x = HologramSize.x / 2,y = HologramSize.y / 2,z = 2.5}--z=2.5 z=1.5
    --local YuanDianToPinMu = {x = PlayerOnHUD.x - 1/2 + HUDTranslation.x,y = PlayerOnHUD.y + 1 + 1/2 + HUDTranslation.y + 1,z = PlayerOnHUD.z - HUDTranslation.z + 1/2}
    --print (YuanDianToPinMu.y)

    --local Vx = (GpointOnHUD.x - PlayerOnHUD.x) / -(GpointOnHUD.z - YuanDianToPinMu.z) * YuanDianToPinMu.z
    --local Vy = (GpointOnHUD.y - PlayerOnHUD.y) / (GpointOnHUD.z - YuanDianToPinMu.z) * YuanDianToPinMu.z
    local Vx = (GpointOnHUD.x) / -(GpointOnHUD.z) * YuanDianToPinMu.z
    local Vy = (GpointOnHUD.y) / (GpointOnHUD.z) * YuanDianToPinMu.z

    local Psx = (Vx + 1) * (HologramSize.x + HUDsOffsetX) / 2--x=20 x=10 
    local Psy = (1 - Vy) * (HologramSize.y + HUDsOffsetY) / 2--y=40 y=30

    --local PsAx,PsAy = projectToScreen({targetXYZ.x,targetXYZ.y,targetXYZ.z},projectionMatrix,HologramSize.x,HologramSize.y)

    local Mx = Psx
    local My = Psy

    if(GpointOnHUD.z >= 0)then
        W_MdrawLine(x,y,Mx,My,signcolor,WindowTable) 
    end

    if(Mx and My)then
            --if(My > y)then
            if (Mx >= WindowTable.left and Mx <= WindowTable.right and My >= WindowTable.top and My <= WindowTable.bottom and GpointOnHUD.z >= 0)then
                --drawPolygon({Mx - xOffset,My,Mx,My - yOffset,Mx + xOffset,My,Mx,My + yOffset},8,color,WindowTable) 
                drawCircleLine(Mx,My,3,20,signcolor,WindowTable)
                    --drawPolygon({Mx - xOffset,My - yOffset,Mx + xOffset,My - yOffset,Mx,My},6,red,WindowTable) 
            end
            --end
    end
end

function speedVectors(x,y)
    local xOffset = 1
    local yOffset = 1
    local Mx = x
    local My = y

    local WindowTable = {left=HologramSize.x / 2 - 70,top=HologramSize.y / 2 - 100,right=HologramSize.x / 2 + 70,bottom=HologramSize.y / 2 + 100}

    local SVq = {}
    SVq.x = -q.x
    SVq.y = -q.y
    SVq.z = -q.z
    SVq.w = q.w
    Speed = RotateVectorByQuat(SVq, velocity)

    local SpeedInShip = {x=0,y=0,z=0}
    --local RP = rotatePointWithQuaternions({ Speed.x,Speed.y,Speed.z},{Ag.roll,Ag.yaw,Ag.pitch})
    --SpeedInShip.x = RP[1]
    --SpeedInShip.y = RP[2]
    --SpeedInShip.z = RP[3]

    SpeedInShip = Speed

    local Vx = -SpeedInShip.x*7
    local Vy = -SpeedInShip.y*7

    --local OnHUD

    --local PPX = targetToHud(V3add(velocity,HUDscreenPs))

    --Mx = PPX.x
    --My = PPX.y - 75

    local MaxOffset = 60

    Mx = x + Vx
    My = y + Vy

    if(Mx > x + MaxOffset)then
        Mx = x + MaxOffset
    elseif(Mx < x - MaxOffset)then
        Mx = x - MaxOffset
    end

    DrawPitchAndRoll(Mx,My,WindowTable)
    --机载武器准星，可以根据位置和散布自行调整
    --HUDshowGunline(70 + Vx,69 + Vy,10,10,4)--第三个参数是圆半径，第四个第五个分别是虚线间隔长度和虚线个数
    --HUDshowCannotLine(70 + Vx,62 + Vy)
    if (Mx >= WindowTable.left and Mx <= WindowTable.right and My >= WindowTable.top and My <= WindowTable.bottom)then
        hologram.DrawLine(Mx - xOffset - 2,My,Mx - xOffset,My,signcolor)
        hologram.DrawLine(Mx + xOffset + 2,My,Mx + xOffset,My,signcolor)
        hologram.DrawLine(Mx,My - yOffset - 2,Mx,My - yOffset,signcolor)
        hologram.DrawLine(Mx - xOffset,My - yOffset,  Mx + xOffset,My - yOffset,signcolor)
        hologram.DrawLine(Mx + xOffset,My - yOffset,  Mx + xOffset,My + yOffset,signcolor)
        hologram.DrawLine(Mx + xOffset,My + yOffset,  Mx - xOffset,My + yOffset,signcolor)
        hologram.DrawLine(Mx - xOffset,My - yOffset,  Mx - xOffset,My + yOffset + 1,signcolor)
    end
end

function HUDshowHeight(x,y)
    local x_,y_ = x,y + 5
    local h = 500

    local ship_height = Ps.y - seaY

    local WIN_table = {left=x + 40,top=y-30,right=x+45,bottom=y+30}

    local h_Height = h/10

    local SB = 60 --显示高度

    local ab = 0

    W_MdrawLine(x_ + 40,y_ + ship_height - ab * SB,x_ + 43,y_ + ship_height - ab * SB,signcolor,WIN_table)
    MdrawText(x_ + 45,y_ - 8,string.format("%.1f",Ps.y - seaY),signcolor)
    for i = 1,h_Height,1 do
        W_MdrawLine(x_ + 40,y_ - i*10  + ship_height - ab * SB,x_ + 43,y_ - i*10 + ship_height - ab * SB,signcolor,WIN_table)
    end
end

function HUDshowYaw(x,y)
    local x_,y_ = x,y - 40
    local w = 240

    local WIN_table = {left=x-40,top=y-40,right=x+40,bottom=y-20}

    local w_Height = w/10

    for i = 1,w_Height,1 do
        W_MdrawLine(x_ + Ag.yaw + i*10 + 1,y_ + 7 + 1,x_ + Ag.yaw + i*10 + 1,y_ + 10 + 1,signcolor,WIN_table)
    end
    W_MdrawLine(x_ + Ag.yaw + 1,y_ + 5 + 1,x_ + Ag.yaw + 1,y_ + 10 + 1,signcolor,WIN_table)
    MdrawText(x_ - 8,y_,string.format("%.1f",Ag.yaw),signcolor)
    for i = 1,w_Height,1 do
        W_MdrawLine(x_ + Ag.yaw - i*10 + 1,y_ + 7 + 1,x_ + Ag.yaw - i*10 + 1,y_ + 10 + 1,signcolor,WIN_table)
    end

    local pointRalble_1 = {x,y - 30,x - 2,y - 28,x + 2,y - 28}
    drawPolygon(pointRalble_1,6,signcolor,WIN_table)
end

function HUDshowSpeed(x,y)
    MdrawText(x - 50,y - 3,string.format("%.1f",math.sqrt(ship.getVelocity().z^2 + ship.getVelocity().x^2 + ship.getVelocity().y^2)),signcolor)
end

local V3save_speed={}
local save_time = os.clock()
local beAllowedUpdata = false
function radar()
    local Rdatas = coordinate.getShips(radarSearchDistance)
    local Pdatas = coordinate.getPlayers(playerSearchDistance)
    --local Pdatas = coord.getEntitiesAll(playerSearchDistance)
    --local Edatas = coord.getEntitiesAll(EradarSearchDistance)
    for k,v in pairs(Pdatas) do
        local targetPos = Vector3:new(v["x"],v["y"] + v["eyeHeight"] + 0.1,v["z"])
        PlayerPos = targetPos
        local targetAngle = v["viewVector"]
        PlayerAngle = targetAngle

        if(DebuggerMod_flag == 1)then
            --直线
            local direction_vector = {PlayerAngle.x, PlayerAngle.y, PlayerAngle.z}  -- 直线的方向向量 (a, b, c)
            --计算
            local IIX = intersectionToScreen(HUDscreenPs,line_point,direction_vector,Plane_point,plane_coefficients)  -- 计算交点并放回屏幕上坐标

            --绘制 
            drawCircleLine(IIX.x,IIX.y,5,20,signcolor,WindowTable)
        end
    end

    local i = 0
    for k,v in pairs(Rdatas) do
        i = i + 1
        local targetPos = {x = v["x"],y = v["y"],z = v["z"]}
        local id = v["id"]

        --local PstV2 = WorldV3toScreenV2({x = 0,y = -60,z = 0},Ppos,Ps,q,HologramSize,HologramSize_World)
        --drawCircleLine(PstV2.x,PstV2.y,5,20,signcolor,WindowTable)
        --WMdrawText(PstV2.x + 5,PstV2.y + 1,string.format("%.1f %.1f %.1f",Ps.x,Ps.y,Ps.z),signcolor,WindowTable)

        local PPX = targetToHud(targetPos)
        local Offset = Vector2:new(3,3)
        drawPolygon({PPX.x - Offset.x,PPX.y,PPX.x,PPX.y - Offset.y,PPX.x + Offset.x,PPX.y,PPX.x,PPX.y + Offset.y},8,signcolor,WindowTable)

        --id
        MdrawText(PPX.x + 5,PPX.y - 1,string.format("%d",id),signcolor)
        --speed
        if(V3save_speed[i])then
            MdrawText(PPX.x + 5,PPX.y + 5,string.format("%.1f",(math.sqrt(targetPos.x^2+targetPos.y^2+targetPos.z^2) - math.sqrt(V3save_speed[i].x^2+V3save_speed[i].y^2+V3save_speed[i].z^2))*20 - math.sqrt(velocity.x^2+velocity.y^2+velocity.z^2)),signcolor)
        end
        if((os.clock() - save_time) >= 0.05)then
            beAllowedUpdata = true
            V3save_speed[i]=Vector3:new(targetPos.x,targetPos.y,targetPos.z)
        end
    end
    if(beAllowedUpdata == true)then--speedSave_Updata
        beAllowedUpdata = false
        save_time = os.clock()
    end
end

function LuoDianJiSuan()
    --velocity
    local GPq = {}
    GPq.x = -q.x
    GPq.y = -q.y
    GPq.z = -q.z
    GPq.w = q.w
    local VonShip = RotateVectorByQuat(GPq,velocity)
    
    local TD_height = HUDscreenPs.y - seaY
    local speed = math.sqrt(velocity.x^2 + velocity.z^2)
    --[[
    --投弹角度
    local angle = Ag.pitch

    local radian = angle * math.pi / 180.0;

    --计算速度分量
    local verticalSpeed = speed * math.sin(radian);
    local horizontalSpeed = speed * math.cos(radian);

    --计算下降时间
    local time = math.sqrt(2 * TD_height / g);

    --计算水平落点
    local horizontalDistance = horizontalSpeed * time;

    local Tz,Tx = getCoordinates(Ag.yaw,horizontalDistance)

    local TD_targetPos = {x = Ps.x + Tx,y = seaY,z = Ps.z + Tz}
    ]]
    
    local k = (CD * air_density * bombArea) / (2.0 * bombMass); -- 计算阻力系数 k

    --投弹角度
    local angle = Ag.pitch

    local radian = angle * math.pi / 180.0;
    local horizontalSpeed = speed * math.cos(radian);

    local dropTime = calculateDropTime(TD_height, k);
    local horizontalDistance = calculateHorizontalDistance(horizontalSpeed, k, dropTime);

    local Tz,Tx = getCoordinates(Ag.yaw,horizontalDistance)

    local TD_targetPos
    if(BOrFMod_flag == 1)then
        TD_targetPos = {x = HUDscreenPs.x + Tx,y = seaY,z = HUDscreenPs.z + Tz}
    else
        TD_targetPos = {x = HUDscreenPs.x - Tx,y = seaY,z = HUDscreenPs.z - Tz}
    end
    
    if(math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2) >= 10)then
        local PPX = targetToHud(TD_targetPos)
        drawCircleLine(PPX.x,PPX.y,3,20,signcolor,WindowTable)
        W_MdrawLine(PPX.x,PPX.y,HologramSize.x/2,HologramSize.y/2,signcolor,WindowTable)
    end
end

--MAIN中直接调用
function UI()
    --特殊
    if(ExMsg.botton == 1 and isStart == false)then
        term.clear()
        isStart = true
    end
    --调用
    UIChange()
    if(isStart == true)then
        if(nowUiIDshow == UiID["SettingMap"])then
            SettingMap()
        end
        if(nowUiIDshow == UiID["HUDsetting_P1"])then
            HUDsetting_P1()
        end
        if(nowUiIDshow == UiID["HUDsetting_P2"])then
            HUDsetting_P2()
        end
    end
end

function HUD()
    GetEuler()
    GetPosition()
    computePlanePositon()
    radar()
    speedVectors(HologramSize.x / 2,HologramSize.y / 2)
    local PPX = targetToHud(target1_ChuShengDian)
    local Offset = Vector2:new(3,3)
    drawPolygon({PPX.x - Offset.x,PPX.y,PPX.x,PPX.y - Offset.y,PPX.x + Offset.x,PPX.y,PPX.x,PPX.y + Offset.y},8,red,WindowTable)
    LuoDianJiSuan()
    hologram.Blit(HologramSize.x / 2 - 3,HologramSize.y / 2,8,2,BakeBitMap(JiZhunXian_PointTable,signcolor),2) --飞机朝向
    --MdrawText(HologramSize.x / 2 - 25,HologramSize.y / 2 + 40,string.format("R %.1f",Ag.roll),signcolor)--滚
    --MdrawText(HologramSize.x / 2 + 5,HologramSize.y / 2 + 40,string.format("P %.1f",Ag.pitch),signcolor)--俯仰
    HUDshowHeight(HologramSize.x / 2 + 30,HologramSize.y / 2)
    HUDshowYaw(HologramSize.x / 2,HologramSize.y / 2 - 50)
    HUDshowSpeed(HologramSize.x / 2 - 30,HologramSize.y / 2)
end

function showEvent(x,y)
    term.setCursorPos(x,y)
    print(ExMsg.event,ExMsg.botton,ExMsg.x,ExMsg.y)
end

function reflesh()
    hologram.Clear()
    hologram.Flush()
end

--主函数与并发函数
function GetEvent()
    local event,botton,x, y
    while true do
        event,botton,x, y = os.pullEvent("mouse_click")
        ExMsg = {event = event,botton = botton,x = x, y = y}
        sleep(0)
    end
end

function CCui()
    while true do
        if(ExMsg)then

            --if(isStart == true)then
                --showEvent(3,CCscreenSize.y)
            --end
            UI()
            ExMsg = {event = nil,botton = nil,x = nil, y = nil}
        else
            --if(isStart == true)then
                --showEvent(3,CCscreenSize.y)
            --end
            UI()
        end
        sleep(0)
        if(isStart == true)then
            term.clear()
        end
    end
end

function main()
    while true do
        HUD()
        sleep(0)
        reflesh()
    end
end

parallel.waitForAll(main,GetEvent,CCui)