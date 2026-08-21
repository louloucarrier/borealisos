local basalt = dofile("basalt.lua")

local monitor = peripheral.find("monitor")

if not monitor then
    error("Aucun monitor")
end

local frame = basalt.createFrame()
frame:setTerm(monitor)
frame:setBackground(colors.black)

local button = frame:addButton()

button:setText("CLIQUER ICI")
button:setPosition(2, 2)
button:setSize(20, 5)

button:onClick(function()
    print("BOUTON CLIQUE !")
end)

basalt.run()