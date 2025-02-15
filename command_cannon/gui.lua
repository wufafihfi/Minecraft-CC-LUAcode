BZD_gui = {}

--矩形
BZD_gui.RECT = {left=0,top=0,right=0,bottom=0}
BZD_gui.RECT.__index = RECT
function BZD_gui.RECT:new(_left,_top,_right,_bottom)
    local rect = {}
    setmetatable(rect, RECT)

    rect.left = _left
    rect.top = _top
    rect.right = _right
    rect.bottom = _bottom

    return rect
end

--按钮
BZD_gui.Botton = {B_RECT,text,color1,color2,textcolor1,textcolor2,Press}
BZD_gui.Botton.__index = Botton
function BZD_gui.Botton:new(_left,_top,_right,_bottom,_text,_color1,_color2,_textcolor1,_textcolor2)
    local botton = {}
    setmetatable(botton, Botton)

    botton.B_RECT = BZD_gui.RECT:new(_left,_top,_right,_bottom)
    if(_right - _left<#_text-1)then
        botton.B_RECT.right = _left + #_text - 1
    end
    botton.text = _text
    botton.color1 = _color1
    botton.color2 = _color2
    botton.textcolor1 = _textcolor1
    botton.textcolor2 = _textcolor2
    botton.Press = false

    return botton
end

--标识
BZD_gui.nowUiIDshow = 0
BZD_gui.isStart = false
BZD_gui.screenSize = {}
BZD_gui.screenSize.x,BZD_gui.screenSize.y = term.getSize()
--消息
BZD_gui.ExMsg = {event = 0,botton = 0,x = 0, y = 0}
--窗口
BZD_gui.GUITable = {}


--非包内
function BZD_gui.UI()
    --特殊(启用GUI)
    if(BZD_gui.ExMsg)then
        if(BZD_gui.ExMsg.botton == 1 and BZD_gui.isStart == false)then
            term.clear()
            BZD_gui.isStart = true
        end
    end
        --调用
    if(BZD_gui.isStart == true)then
        for k,v in pairs(BZD_gui.GUITable) do
            if(BZD_gui.nowUiIDshow == v["ID"])then
                v["function"]()
            end
        end
    end
end

--加入包
--CC屏绘制
function BZD_gui.MCCDrawTextR(x,y,text,textcolor,backcolor)
    local NowTextColour = term.getTextColour()
    local NowBkColour = term.getBackgroundColour()
    term.setTextColour(textcolor)
    term.setBackgroundColour(backcolor)
    term.setCursorPos(x,y)
    term.write(text)
    term.setTextColour(NowTextColour)
    term.setBackgroundColour(NowBkColour)
end
function BZD_gui.MCCDrawTextR_NoXY(text,textcolor,backcolor)
    local NowTextColour = term.getTextColour()
    local NowBkColour = term.getBackgroundColour()
    term.setTextColour(textcolor)
    term.setBackgroundColour(backcolor)
    term.write(text)
    term.setTextColour(NowTextColour)
    term.setBackgroundColour(NowBkColour)
end
function BZD_gui.MCCDrawLineR(x,y,dx,dy,colour)
    local NowBkColour = term.getBackgroundColour()
    paintutils.drawLine(x,y,dx,dy,colour)
    term.setBackgroundColour(NowBkColour)
end
function BZD_gui.DrawBotton(botton)
    local color,textcolor = botton.color1,botton.textcolor1
    if(botton.Press == false)then
        color,textcolor = botton.color1,botton.textcolor1
    else
        color,textcolor = botton.color2,botton.textcolor2
    end
    BZD_gui.MCCDrawTextR(botton.B_RECT.left,botton.B_RECT.top,botton.text,textcolor,color)
end

function BZD_gui.IfInRect(Rect,POS)
    if (BZD_gui.ExMsg)then
        if(POS.x >= Rect.left) and (POS.y >= Rect.top) and (POS.x <= Rect.right) and (POS.y <= Rect.bottom)then
            return true
        else
            return false
        end
    else
        return false
    end
end

function BZD_gui.start()
    term.setTextColour(0x100)
    print("----------Press leftMose to Start----------")
    term.setTextColour(0x1)
end

--事件
function BZD_gui.GetEvent()
    local event,botton,x, y
    while true do
        event,botton,x, y = os.pullEvent("mouse_click")
        BZD_gui.ExMsg = {event = event,botton = botton,x = x, y = y}
        sleep(0)
    end
end

--主函数
function BZD_gui.gui()
    while true do
        if(BZD_gui.ExMsg)then
            BZD_gui.UI()
            BZD_gui.ExMsg = nil
        else
            BZD_gui.UI()
        end
        sleep(0)
        if(BZD_gui.isStart == true)then
            term.clear()
        end
    end
end

--携程
function BZD_gui.GUI_main()
    parallel.waitForAll(BZD_gui.gui,BZD_gui.GetEvent)
end

return BZD_gui