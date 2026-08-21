local basalt = require("basalt")

-- ==========================================
-- BOREALIS OS V1
-- ==========================================

local monitor = peripheral.find("monitor")

if not monitor then
    error("Aucun Monitor détecté !")
end

-- Cadre principal
local frame = basalt.createFrame()
frame:setTerm(monitor)
frame:setBackground(colors.black)

-- Taille réelle du monitor
local width, height = monitor.getSize()

-- ==========================================
-- TITRE
-- ==========================================

local title = frame:addLabel()
title:setText("BOREALIS OS")
title:setPosition(2, 2)
title:setForeground(colors.cyan)

local status = frame:addLabel()
status:setText("● SERVEUR ONLINE")
status:setPosition(2, 3)
status:setForeground(colors.lime)

-- ==========================================
-- DIMENSIONS DES BOUTONS
-- ==========================================

local margin = 2
local gap = 2

local buttonWidth = math.floor((width - margin * 2 - gap) / 2)
local buttonHeight = 3

local x1 = margin
local x2 = margin + buttonWidth + gap

local y1 = 6
local y2 = y1 + buttonHeight + 1
local y3 = y2 + buttonHeight + 1

-- ==========================================
-- FONCTION BOUTON
-- ==========================================

local function createButton(text, x, y, color)

    local button = frame:addButton()

    button:setText(text)
    button:setPosition(x, y)
    button:setSize(buttonWidth, buttonHeight)
    button:setBackground(color)
    button:setForeground(colors.white)

    return button
end

-- ==========================================
-- APPLICATIONS
-- ==========================================

local tasks = createButton(
    "TACHES",
    x1,
    y1,
    colors.blue
)

local employees = createButton(
    "EMPLOYES",
    x2,
    y1,
    colors.green
)

local reports = createButton(
    "RAPPORTS",
    x1,
    y2,
    colors.orange
)

local music = createButton(
    "MUSIQUE",
    x2,
    y2,
    colors.purple
)

local admin = createButton(
    "ADMINISTRATION",
    x1,
    y3,
    colors.red
)

local settings = createButton(
    "PARAMETRES",
    x2,
    y3,
    colors.gray
)

-- ==========================================
-- EVENEMENTS
-- ==========================================

tasks:onClick(function()
    print("Ouverture des tâches")
end)

employees:onClick(function()
    print("Ouverture des employés")
end)

reports:onClick(function()
    print("Ouverture des rapports")
end)

music:onClick(function()
    print("Ouverture de la musique")
end)

admin:onClick(function()
    print("Ouverture de l'administration")
end)

settings:onClick(function()
    print("Ouverture des paramètres")
end)

-- ==========================================
-- BOUCLE BASALT
-- ==========================================

basalt.run()