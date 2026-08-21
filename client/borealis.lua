local basalt = require("basalt")

local monitor = peripheral.find("monitor")

if not monitor then
    error("Aucun monitor détecté !")
end

local frame = basalt.createFrame()
frame:setTerm(monitor)

frame:setBackground(colors.black)

frame:addLabel()
    :setText("BOREALIS")
    :setPosition(2, 2)
    :setForeground(colors.white)

frame:addLabel()
    :setText("CENTRE DE CONTROLE")
    :setPosition(2, 3)
    :setForeground(colors.lightGray)

frame:addLabel()
    :setText("● SERVEUR ONLINE")
    :setPosition(2, 5)
    :setForeground(colors.lime)

local tasks = frame:addButton()
    :setText("TACHES")
    :setPosition(2, 8)
    :setSize(15, 3)

local employees = frame:addButton()
    :setText("EMPLOYES")
    :setPosition(20, 8)
    :setSize(15, 3)

local reports = frame:addButton()
    :setText("RAPPORTS")
    :setPosition(2, 12)
    :setSize(15, 3)

local music = frame:addButton()
    :setText("MUSIQUE")
    :setPosition(20, 12)
    :setSize(15, 3)

basalt.run()