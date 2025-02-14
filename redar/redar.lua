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
local gpu = peripherals["tm_gpu"]
term.setTextColour(0x1)

term.setTextColour(0x20)
print("----------PinMu----------")
term.setTextColour(0x1)
gpu.refreshSize()
gpu.setSize(64)

local Cw,Ch = gpu.getSize()
print("w:",Cw,"h:",Ch)

local WindowTable = {left = 1,top = 1,right = Cw,bottom = Ch}

gpu.fill(0,0,0)

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

--变量--
local bkcolor = 0x00000000
local Mainlinecolor = 0x00999999
local Maintextcolor = 0x00999999
local signcolor = 0x00009900
local MainGaugescolor = 0x00222222
local red = 0x00990000
local bule = 0x00000099

--屏幕适配
local Cw_bCW = Cw/448
local Ch_bCH = Ch/256
local C_bC = Vector2:new(math.min(Cw_bCW, Ch_bCH),math.min(Cw_bCW, Ch_bCH))

--姿态
local Ag = Euler:new(0,0,0)
local Ps = Vector3:new(0,0,0)
local q = ship.getQuaternion()
local velocity = ship.getVelocity()

--消息
local ExMsg = {event = 0,botton = 0,x = 0, y = 0}
local ExMsg_long = {event = 0,botton = 0,x = 0, y = 0}

--雷达
local radarSearchDistance = 200
local maxSearchDistance = 2500
local minSearchDistance = 50
local ViewRotate = 180
local MonstersPosition = {}
local MonstersPosition_uuid = {}
local MonstersPosition_onScreen = {}
local Monsters_Id = {}

--红网
local protocol = "rednet:radar<<->>command_cbc_control"
local rednet_message = {msg = {position = Vector3:new(nil,nil,nil)},b_protocol = protocol}

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

function getCoordinates(angle, radius)--已知角和半径求坐标
    local radians = angle * math.pi / 180

    local x = radius * math.cos(radians)
    local y = radius * math.sin(radians)

    return x, y
end

-- 2维向量旋转
function vector2_rotate(v, angle)
    local theta = degreeToRadian(angle)
    local cos_theta = math.cos(theta)
    local sin_theta = math.sin(theta)
    return {x = v.x * cos_theta - v.y * sin_theta,
            y = v.x * sin_theta + v.y * cos_theta}
end

function V3add(V3_1,V3_2)
    local V3result = {}
    V3result.x = V3_1.x + V3_2.x
    V3result.y = V3_1.y + V3_2.y
    V3result.z = V3_1.z + V3_2.z
    return V3result
end

function V2add(V2_1,V2_2)
    local V2result = {}
    V2result.x = V2_1.x + V2_2.x
    V2result.y = V2_1.y + V2_2.y
    return V2result
end

function V3length(V3)
    local V3result = math.sqrt(V3.x^2 + V3.y^2 + V3.z^2)
    return V3result
end

function V2length(V2)
    local V2result = math.sqrt(V2.x^2 + V2.y^2)
    return V2result
end

function IfInRect(rect,v2)
    if(v2.x >= rect.left and v2.x <= rect.right and v2.y >= rect.top and v2.y <= rect.bottom)then
        return true
    else
        return false
    end
end

function V2toRect(v2,size)
    local resultRect = {left = v2.x,top = v2.y,right = v2.x + size.x,bottom = v2.y + size.y}
    return resultRect
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
end

--绘制
function W_MdrawLine(x,y,x_,y_,thickness,color,windowTable)
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
        if not(x < windowTable.left or y < windowTable.top or x + thickness > windowTable.right or y + thickness  > windowTable.bottom)then
            gpu.filledRectangle(x + 0.5,y + 0.5,thickness ,thickness ,color)
        end
        x = x + xadd
        y = y + yadd
    end
end

function drawCircleLine(centerX, centerY, radius,thickness, segments,colors,windowTable)
    local angleIncrement = 2 * math.pi / segments  -- 每一段的角度增加
    local lastX = centerX + radius  -- 起始点的 x 坐标
    local lastY = centerY           -- 起始点的 y 坐标

    for i = 1, segments + 1 do
        local angle = i * angleIncrement
        local x = centerX + radius * math.cos(angle)
        local y = centerY + radius * math.sin(angle)

        -- 画线段从 lastX，lastY 到 x，y
        W_MdrawLine(lastX, lastY,x, y,thickness,colors,windowTable)

        lastX = x
        lastY = y
    end
end

function drawPolygon(Points,lineNum,thickness,linecolor,WINTABLE)
    for i = 1,lineNum,1 do
        if(i == lineNum - 1)then
            W_MdrawLine(Points[i] + 1,Points[i + 1] + 1,Points[1] + 1,Points[2] + 1,thickness,linecolor,WINTABLE)
            break
        elseif((i + 1) % 2 == 0)then
            W_MdrawLine(Points[i] + 1,Points[i + 1] + 1,Points[i + 2] + 1,Points[i + 3] + 1,thickness,linecolor,WINTABLE)
        end
    end
end

-- 绘制填充三角形
function fillTriangle(v1, v2, v3,color,WINTABLE)
    -- 提取顶点坐标
    local x1, y1 = v1.x, v1.y
    local x2, y2 = v2.x, v2.y
    local x3, y3 = v3.x, v3.y

    -- 确保 y1 <= y2 <= y3
    if y2 < y1 then
        x1, y1, x2, y2, x3, y3 = x2, y2, x1, y1, x3, y3
    end
    if y3 < y2 then
        x2, y2, x3, y3 = x3, y3, x2, y2
    end
    if y2 < y1 then
        x1, y1, x2, y2, x3, y3 = x2, y2, x1, y1, x3, y3
    end

    -- 计算斜率
    local function interpolate(y, y1, y2, x1, x2)
        if y1 == y2 then
            return x1
        end
        return x1 + (y - y1) * (x2 - x1) / (y2 - y1)
    end

    -- 绘制上半部分
    for y = math.ceil(y1), math.floor(y2) do
        local xa = interpolate(y, y1, y2, x1, x2)
        local xb = interpolate(y, y1, y3, x1, x3)
        W_MdrawLine(math.ceil(xa), y, math.ceil(xb), y,1,color,WINTABLE)
    end

    -- 绘制下半部分
    for y = math.ceil(y2), math.floor(y3) do
        local xa = interpolate(y, y2, y3, x2, x3)
        local xb = interpolate(y, y1, y3, x1, x3)
        W_MdrawLine(math.ceil(xa), y, math.ceil(xb), y,1,color,WINTABLE)
    end
end

--绘制填充四边形
function fillRectangle(v1, v2, v3, v4,color,WINTABLE)
    fillTriangle(v1,v3,v2,color,WINTABLE)
    fillTriangle(v1,v3,v4,color,WINTABLE)
end

--绘制填充矩形
function fillRectangle(Positon, w, h,color,WINTABLE)
    local left_bottom = Vector2:new(Positon.x,Positon.y + h + 1)
    local right_top = Vector2:new(Positon.x + w,Positon.y)
    local right_bottom = Vector2:new(Positon.x + w,Positon.y + h + 1)
    fillTriangle(Positon,right_bottom,left_bottom,color,WINTABLE)
    fillTriangle(Positon,right_bottom,right_top,color,WINTABLE)
end

--功能
--雷达目标选中显示详细信息
local show_flag = false
local next_flag = false
local P_rect_size = 4
local D_rect_size = 2
local id_save = 1
function radar_target_details(x,y,target_tableID,viewRect)
    local p_target_rect = Rect:new(MonstersPosition_onScreen[target_tableID].x - P_rect_size,MonstersPosition_onScreen[target_tableID].y - P_rect_size,MonstersPosition_onScreen[target_tableID].x + P_rect_size,MonstersPosition_onScreen[target_tableID].y + P_rect_size)
    local d_target_rect = Rect:new(MonstersPosition_onScreen[target_tableID].x - D_rect_size,MonstersPosition_onScreen[target_tableID].y - D_rect_size,MonstersPosition_onScreen[target_tableID].x + D_rect_size,MonstersPosition_onScreen[target_tableID].y + D_rect_size)
    if(show_flag)and(id_save == Monsters_Id[target_tableID])then
        p_target_rect = Rect:new(MonstersPosition_onScreen[target_tableID].x - P_rect_size,MonstersPosition_onScreen[target_tableID].y - P_rect_size,MonstersPosition_onScreen[target_tableID].x + P_rect_size,MonstersPosition_onScreen[target_tableID].y + P_rect_size)
        d_target_rect = Rect:new(MonstersPosition_onScreen[target_tableID].x - D_rect_size,MonstersPosition_onScreen[target_tableID].y - D_rect_size,MonstersPosition_onScreen[target_tableID].x + D_rect_size,MonstersPosition_onScreen[target_tableID].y + D_rect_size)
    end
    local touch_v2 = Vector2:new(-99,-99)
    if(ExMsg)then
        touch_v2 = Vector2:new(ExMsg.x,ExMsg.y)
    end
    local target_rect_position = Vector3:new(d_target_rect.left,d_target_rect.top)
    if(ExMsg)then
        if(ExMsg.botton == "right")and(show_flag == false)and(IfInRect(p_target_rect,touch_v2))then
            show_flag = true
            id_save = Monsters_Id[target_tableID]
        end
        if(ExMsg.botton == "right")and(next_flag)and(IfInRect(viewRect,touch_v2))then
            show_flag = false
            next_flag = false
        end
    else
        if(show_flag == true)then
            next_flag = true
        end
    end

    if(show_flag)and(id_save == Monsters_Id[target_tableID])then
        if (Cw > 128 and Ch > 64)then
            gpu.drawText(x,y,string.format("x %0.1f | y %0.1f | z %0.1f",MonstersPosition_uuid[id_save].x,MonstersPosition_uuid[id_save].y,MonstersPosition_uuid[id_save].z),Maintextcolor,bkcolor,1,0x00000000)
            gpu.drawText(x + 20 * C_bC.x,y + 20 * C_bC.x,string.format("maxHealth %s",MonstersPosition_uuid[id_save].maxHealth),Maintextcolor,bkcolor,1,0x00000000)
            gpu.drawText(x + 20 * C_bC.x,y + 40 * C_bC.x,string.format("name %s",MonstersPosition_uuid[id_save].name),Maintextcolor,bkcolor,1,0x00000000)
        end
        rednet_message.msg.id = id_save
        if(MonstersPosition_uuid[id_save].x)then
            rednet_message.msg.position = Vector3:new(MonstersPosition_uuid[id_save].x,MonstersPosition_uuid[id_save].y,MonstersPosition_uuid[id_save].z)
        else
            rednet_message.msg.position = Vector3:new(nil,nil,nil)
        end
        rednet.broadcast(rednet_message,rednet_message.b_protocol)
        fillRectangle(target_rect_position,D_rect_size*2,D_rect_size*2,red,WindowTable)
    end
end
--雷达参数控制
function radar_control(x,y)
    local conrtorl_ui_rect_v2 = Vector2:new(x,y)
    local conrtorl_ui_rect_size = Vector2:new(45,7)
    local conrtorl_ui_inRect_line_length = 8
    fillRectangle(conrtorl_ui_rect_v2,conrtorl_ui_rect_size.x,conrtorl_ui_rect_size.y,signcolor,WindowTable)
    
    local control_ui_line_rect1_v2 = Vector2:new(conrtorl_ui_rect_v2.x + conrtorl_ui_rect_size.x - conrtorl_ui_inRect_line_length,conrtorl_ui_rect_v2.y)
    local control_ui_line_rect1_size = Vector2:new(conrtorl_ui_inRect_line_length,conrtorl_ui_inRect_line_length + 1)
    local control_ui_line_rect2_v2 = Vector2:new(conrtorl_ui_rect_v2.x,conrtorl_ui_rect_v2.y)
    local control_ui_line_rect2_size = Vector2:new(conrtorl_ui_inRect_line_length,conrtorl_ui_inRect_line_length + 1)
    fillRectangle(control_ui_line_rect1_v2,conrtorl_ui_inRect_line_length,conrtorl_ui_inRect_line_length - 1,red,WindowTable)
    fillRectangle(control_ui_line_rect2_v2,conrtorl_ui_inRect_line_length,conrtorl_ui_inRect_line_length - 1,bule,WindowTable)
    
    local line_1 = {}
    line_1[1] = control_ui_line_rect1_v2.x + conrtorl_ui_inRect_line_length/2
    line_1[2] = control_ui_line_rect1_v2.y + 1
    line_1[3] = control_ui_line_rect1_v2.x + conrtorl_ui_inRect_line_length/2
    line_1[4] = control_ui_line_rect1_v2.y + conrtorl_ui_inRect_line_length - 1
    local line_2 = {}
    line_2[1] = control_ui_line_rect1_v2.x + 1
    line_2[2] = control_ui_line_rect1_v2.y + conrtorl_ui_inRect_line_length/2
    line_2[3] = control_ui_line_rect1_v2.x + conrtorl_ui_inRect_line_length - 1
    line_2[4] = control_ui_line_rect1_v2.y + conrtorl_ui_inRect_line_length/2
    W_MdrawLine(line_1[1],line_1[2],line_1[3],line_1[4],1,Mainlinecolor,WindowTable)
    W_MdrawLine(line_2[1],line_2[2],line_2[3],line_2[4],1,Mainlinecolor,WindowTable)
    local line_3 = {}
    line_3[1] = control_ui_line_rect2_v2.x + 1
    line_3[2] = control_ui_line_rect2_v2.y + conrtorl_ui_inRect_line_length/2
    line_3[3] = control_ui_line_rect2_v2.x + conrtorl_ui_inRect_line_length - 1
    line_3[4] = control_ui_line_rect2_v2.y + conrtorl_ui_inRect_line_length/2
    W_MdrawLine(line_3[1],line_3[2],line_3[3],line_3[4],1,Mainlinecolor,WindowTable)

    local value_show_v2 = Vector2:new(conrtorl_ui_rect_v2.x + conrtorl_ui_inRect_line_length + 1,conrtorl_ui_rect_v2.y + 1)
    gpu.drawText(value_show_v2.x,value_show_v2.y,string.format(" %d",radarSearchDistance),Maintextcolor,signcolor,1,0x00000000)

    local r1 = V2toRect(control_ui_line_rect1_v2,control_ui_line_rect1_size)
    local r2 = V2toRect(control_ui_line_rect2_v2,control_ui_line_rect2_size)
    if(ExMsg)then
        local touch_v2 = Vector2:new(ExMsg.x,ExMsg.y)
        if(ExMsg.botton == "right")and(IfInRect(r1,touch_v2))then
            radarSearchDistance = radarSearchDistance + 100
            MonstersPosition = {}
        end
        if(ExMsg.botton == "right")and(IfInRect(r2,touch_v2))then
            radarSearchDistance = radarSearchDistance - 100
            MonstersPosition = {}
        end
    end
    if(radarSearchDistance > maxSearchDistance)then
        radarSearchDistance = maxSearchDistance
    elseif(radarSearchDistance < minSearchDistance)then
        radarSearchDistance = minSearchDistance
    end
end
--雷达界面
function radar_view()
    local viewR = math.min(Cw/2,Ch/2) - 10 * C_bC.y
    local viewPos = Vector2:new(Cw/2 - 80 * C_bC.x,Ch/2)
    local viewRotate = ViewRotate
    W_MdrawLine(viewPos.x - viewR,viewPos.y,viewPos.x + viewR,viewPos.y,1,signcolor,WindowTable)
    W_MdrawLine(viewPos.x,viewPos.y - viewR,viewPos.x,viewPos.y + viewR,1,signcolor,WindowTable)
    drawCircleLine(viewPos.x,viewPos.y,viewR,1,50,signcolor,WindowTable)
    local g = 1
    MonstersPosition_onScreen = {}
    Monsters_Id = {}
    for i = 1,#MonstersPosition,1 do
        local targetToShip = Vector2:new(MonstersPosition[i].x - Ps.x,MonstersPosition[i].z - Ps.z)

        local RotatedTargetToShip = vector2_rotate(targetToShip,Ag.yaw + viewRotate)

        local targetOnScreen = Vector2:new(0,0)
        targetOnScreen.x = RotatedTargetToShip.x * ((viewR * 2) / radarSearchDistance)
        targetOnScreen.y = RotatedTargetToShip.y * ((viewR * 2) / radarSearchDistance)

        local targetOnView = V2add(targetOnScreen,viewPos)

        if(V2length(targetOnScreen) < viewR)then
            MonstersPosition_onScreen[g] = targetOnView
            Monsters_Id[g] = MonstersPosition[i].id
            g = g + 1
        end
    end
    for i = 1,#MonstersPosition_onScreen,1 do
        radar_target_details(viewPos.x + viewR - 20 * C_bC.x,viewPos.y - 100 * C_bC.y,i,V2toRect(Vector2:new(viewPos.x - viewR,viewPos.y - viewR),Vector2:new(viewR*2,viewR*2)))
        fillRectangle(MonstersPosition_onScreen[i],0,0,signcolor,WindowTable)
    end
    radar_control(viewPos.x + viewR - 10 * C_bC.x,viewPos.y + 100 * C_bC.y)
end
--事件显示
function event_show()
    if(ExMsg_long.event)then
        --gpu.drawText(1,1,string.format("%s | %s | x %d | y %d",ExMsg_long.event,ExMsg_long.botton,ExMsg_long.x,ExMsg_long.y),Maintextcolor,bkcolor,1,0x00000000)
    else
        --gpu.drawText(1,1,"--,--",Maintextcolor,bkcolor,1,0x00000000)
    end
    if(ExMsg)then
        --gpu.drawText(100,100,string.format("%s | %s",ExMsg.event,ExMsg.botton),Maintextcolor,bkcolor,1,0x00000000)
    else
        --gpu.drawText(100,100,"--,--",Maintextcolor,bkcolor,1,0x00000000)
    end
end
--刷新
function reflesh()
    sleep(0)
    gpu.fill(bkcolor)
    gpu.sync()
end

--功能集合
function draw()
    event_show()
    radar_view()
    reflesh()
end

--主函数
function radar()
    while true do
        --local Mdatas = coordinate.getEntities(radarSearchDistance)--coordinate.getMonster(radarSearchDistance)
        local Mdatas = coordinate.getMobs(radarSearchDistance)
        local R_i = 1
        for k,v in pairs(Mdatas) do
            local target = {x = v["x"],y = v["y"],z = v["z"],id = v["uuid"],maxHealth = v["maxHealth"],name = v["name"]}
            MonstersPosition[R_i] = target
            MonstersPosition_uuid[target.id] = target
            R_i = R_i + 1
        end
        sleep(0)
    end
end

function GetEvent_tom_screen()
    local event,botton,x, y
    while true do
        event,botton,x, y = os.pullEvent("tm_monitor_touch")
        ExMsg = {event = event,botton = botton,x = x, y = y}
        ExMsg_long = {event = event,botton = botton,x = x, y = y}
        sleep(0)
    end
end

function main()
    while(true) do
        GetShipTransform()

        if(ExMsg)then
            draw()
            ExMsg = nil
        else
            draw()
        end
    end
end

parallel.waitForAll(main,GetEvent_tom_screen,radar)