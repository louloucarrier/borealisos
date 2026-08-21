local basalt = dofile("basalt.lua")

local monitor = peripheral.find("monitor")

if not monitor then
    error("Aucun monitor detecte !")
end

local frame = basalt.createFrame()
frame:setTerm(monitor)
frame:setBackground(colors.black)

local width, height = monitor.getSize()

-- ==================================================
-- DECLARATIONS
-- ==================================================

local home
local tasks
local employees
local reports
local music
local admin

-- ==================================================
-- OUTILS
-- ==================================================

local function clear()
    local children = frame:getChildren()

    for _, child in ipairs(children) do
        child:destroy()
    end
end

local function addLabel(text, x, y, color)

    local l = frame:addLabel()

    l:setText(text)
    l:setPosition(x, y)

    if color then
        l:setForeground(color)
    end

    return l
end

local function addButton(text, x, y, w, h, callback)

    local b = frame:addButton()

    b:setText(text)
    b:setPosition(x, y)
    b:setSize(w, h)

    b:onClick(function()
        callback()
    end)

    return b
end

local function backButton()

    addButton(
        "< RETOUR",
        2,
        height - 3,
        14,
        2,
        home
    )

end

-- ==================================================
-- ACCUEIL
-- ==================================================

home = function()

    clear()

    addLabel(
        "BOREALIS OS",
        2,
        1,
        colors.cyan
    )

    addLabel(
        "SERVEUR : ONLINE",
        2,
        3,
        colors.lime
    )

    local buttonWidth = math.floor((width - 6) / 2)

    -- TACHES

    addButton(
        "TACHES",
        2,
        6,
        buttonWidth,
        3,
        tasks
    )

    -- EMPLOYES

    addButton(
        "EMPLOYES",
        buttonWidth + 4,
        6,
        buttonWidth,
        3,
        employees
    )

    -- RAPPORTS

    addButton(
        "RAPPORTS",
        2,
        11,
        buttonWidth,
        3,
        reports
    )

    -- MUSIQUE

    addButton(
        "MUSIQUE",
        buttonWidth + 4,
        11,
        buttonWidth,
        3,
        music
    )

    -- ADMINISTRATION

    addButton(
        "ADMINISTRATION",
        2,
        16,
        buttonWidth,
        3,
        admin
    )

end

-- ==================================================
-- TACHES
-- ==================================================

tasks = function()

    clear()

    addLabel(
        "TACHES",
        2,
        1,
        colors.cyan
    )

    addLabel(
        "MES TACHES",
        2,
        4,
        colors.white
    )

    addLabel(
        "[ ] Aucune tache",
        2,
        6,
        colors.orange
    )

    backButton()

end

-- ==================================================
-- EMPLOYES
-- ==================================================

employees = function()

    clear()

    addLabel(
        "EMPLOYES",
        2,
        1,
        colors.cyan
    )

    addLabel(
        "EMPLOYES CONNECTES",
        2,
        4,
        colors.white
    )

    addLabel(
        "Aucun employe connecte.",
        2,
        6,
        colors.orange
    )

    backButton()

end

-- ==================================================
-- RAPPORTS
-- ==================================================

reports = function()

    clear()

    addLabel(
        "RAPPORTS",
        2,
        1,
        colors.cyan
    )

    addLabel(
        "RAPPORTS DE LA BASE",
        2,
        4,
        colors.white
    )

    addLabel(
        "Aucun rapport disponible.",
        2,
        6,
        colors.orange
    )

    addButton(
        "NOUVEAU RAPPORT",
        2,
        9,
        20,
        3,
        function()

            addLabel(
                "Rapport cree !",
                2,
                13,
                colors.lime
            )

        end
    )

    backButton()

end

-- ==================================================
-- MUSIQUE
-- ==================================================

music = function()

    clear()

    addLabel(
        "MUSIQUE",
        2,
        1,
        colors.cyan
    )

    addLabel(
        "LECTEUR BOREALIS",
        2,
        4,
        colors.white
    )

    addLabel(
        "Aucune musique.",
        2,
        6,
        colors.orange
    )

    addButton(
        "LECTURE",
        2,
        9,
        12,
        3,
        function()

            print("Lecture demandee")

        end
    )

    addButton(
        "STOP",
        16,
        9,
        12,
        3,
        function()

            print("Stop demande")

        end
    )

    backButton()

end

-- ==================================================
-- ADMINISTRATION
-- ==================================================

admin = function()

    clear()

    addLabel(
        "ADMINISTRATION",
        2,
        1,
        colors.red
    )

    addLabel(
        "PANNEAU ADMINISTRATEUR",
        2,
        4,
        colors.white
    )

    addButton(
        "CREER UNE TACHE",
        2,
        7,
        22,
        3,
        function()

            print("Creation d'une tache")

        end
    )

    addButton(
        "GERER EMPLOYES",
        2,
        12,
        22,
        3,
        function()

            print("Gestion des employes")

        end
    )

    backButton()

end

-- ==================================================
-- DEMARRAGE
-- ==================================================

home()

basalt.run()