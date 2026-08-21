local basalt = dofile("basalt.lua")

local monitor = peripheral.find("monitor")

local frame = basalt.createFrame()
frame:setTerm(monitor)
frame:setBackground(colors.black)

local title = frame:addLabel()
title:setText("BOREALIS OS")
title:setPosition(2, 2)

local button = frame:addButton()
button:setText("TACHES")
button:setPosition(2, 6)
button:setSize(15, 3)

button:onClick(function()
    button:setText("CA MARCHE !")
end)

basalt.run()