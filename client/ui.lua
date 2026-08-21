local basalt = dofile("basalt.lua")

local UI = {}

local monitor = peripheral.find("monitor")

if not monitor then
    error("Aucun monitor détecté !")
end

local width, height = monitor.getSize()

UI.frame = basalt.createFrame()
UI.frame:setTerm(monitor)
UI.frame:setBackground(colors.black)

function UI.clear()
    UI.frame:removeChildren()
end

function UI.header(title)

    local label = UI.frame:addLabel()

    label:setText("BOREALIS OS | " .. title)
    label:setPosition(2, 1)
    label:setForeground(colors.cyan)

    return label
end

function UI.button(text, x, y, w, h, callback)

    local button = UI.frame:addButton()

    button:setText(text)
    button:setPosition(x, y)
    button:setSize(w, h)

    button:setBackground(colors.gray)
    button:setForeground(colors.white)

    button:onClick(function()
        callback()
    end)

    return button
end

function UI.back(callback)

    return UI.button(
        "< RETOUR",
        2,
        height - 3,
        math.min(15, width - 4),
        2,
        callback
    )

end

function UI.getSize()

    return width, height

end

UI.basalt = basalt

return UI