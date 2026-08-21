local UI = dofile("ui.lua")

local basalt = UI.basalt

local width, height = UI.getSize()

-- ==========================================
-- BOREALIS OS
-- ==========================================


-- ==========================================
-- ACCUEIL
-- ==========================================

local function home()

    UI.clear()

    UI.header("ACCUEIL")

    local status = UI.frame:addLabel()

    status:setText("SERVEUR : ONLINE")
    status:setPosition(2, 3)
    status:setForeground(colors.lime)

    local info = UI.frame:addLabel()

    info:setText("Centre de controle Borealis")
    info:setPosition(2, 5)
    info:setForeground(colors.white)

    local margin = 2
    local gap = 2

    local buttonWidth =
        math.floor((width - margin * 2 - gap) / 2)

    local buttonHeight = 3

    local x1 = margin
    local x2 = margin + buttonWidth + gap

    local y1 = 7
    local y2 = y1 + buttonHeight + 1
    local y3 = y2 + buttonHeight + 1

    UI.button(
        "TACHES",
        x1,
        y1,
        buttonWidth,
        buttonHeight,
        tasks
    )

    UI.button(
        "EMPLOYES",
        x2,
        y1,
        buttonWidth,
        buttonHeight,
        employees
    )

    UI.button(
        "RAPPORTS",
        x1,
        y2,
        buttonWidth,
        buttonHeight,
        reports
    )

    UI.button(
        "MUSIQUE",
        x2,
        y2,
        buttonWidth,
        buttonHeight,
        music
    )

    UI.button(
        "ADMINISTRATION",
        x1,
        y3,
        buttonWidth,
        buttonHeight,
        admin
    )

    UI.button(
        "PARAMETRES",
        x2,
        y3,
        buttonWidth,
        buttonHeight,
        settings
    )

end


-- ==========================================
-- TACHES
-- ==========================================

function tasks()

    UI.clear()

    UI.header("TACHES")

    local title = UI.frame:addLabel()

    title:setText("MES TACHES")
    title:setPosition(2, 3)
    title:setForeground(colors.white)

    local task = UI.frame:addLabel()

    task:setText("[ ] Aucune tache")
    task:setPosition(2, 5)
    task:setForeground(colors.orange)

    UI.back(home)

end


-- ==========================================
-- EMPLOYES
-- ==========================================

function employees()

    UI.clear()

    UI.header("EMPLOYES")

    local title = UI.frame:addLabel()

    title:setText("EMPLOYES CONNECTES")
    title:setPosition(2, 3)
    title:setForeground(colors.white)

    local none = UI.frame:addLabel()

    none:setText("Aucun employe")
    none:setPosition(2, 5)
    none:setForeground(colors.orange)

    UI.back(home)

end


-- ==========================================
-- RAPPORTS
-- ==========================================

function reports()

    UI.clear()

    UI.header("RAPPORTS")

    local title = UI.frame:addLabel()

    title:setText("RAPPORTS DE LA BASE")
    title:setPosition(2, 3)
    title:setForeground(colors.white)

    local none = UI.frame:addLabel()

    none:setText("Aucun rapport")
    none:setPosition(2, 5)
    none:setForeground(colors.orange)

    UI.button(
        "NOUVEAU RAPPORT",
        2,
        7,
        math.min(25, width - 4),
        3,
        function()
            print("Nouveau rapport")
        end
    )

    UI.back(home)

end


-- ==========================================
-- MUSIQUE
-- ==========================================

function music()

    UI.clear()

    UI.header("MUSIQUE")

    local title = UI.frame:addLabel()

    title:setText("LECTEUR BOREALIS")
    title:setPosition(2, 3)
    title:setForeground(colors.white)

    local status = UI.frame:addLabel()

    status:setText("Aucune musique")
    status:setPosition(2, 5)
    status:setForeground(colors.orange)

    UI.button(
        "LECTURE",
        2,
        7,
        12,
        3,
        function()
            print("Lecture demandee")
        end
    )

    UI.button(
        "STOP",
        16,
        7,
        12,
        3,
        function()
            print("Stop")
        end
    )

    UI.back(home)

end


-- ==========================================
-- ADMINISTRATION
-- ==========================================

function admin()

    UI.clear()

    UI.header("ADMINISTRATION")

    local title = UI.frame:addLabel()

    title:setText("PANNEAU ADMINISTRATEUR")
    title:setPosition(2, 3)
    title:setForeground(colors.red)

    UI.button(
        "CREER UNE TACHE",
        2,
        5,
        math.min(25, width - 4),
        3,
        function()
            print("Creation de tache")
        end
    )

    UI.button(
        "GERER EMPLOYES",
        2,
        9,
        math.min(25, width - 4),
        3,
        function()
            print("Gestion employes")
        end
    )

    UI.button(
        "JOURNAL",
        2,
        13,
        math.min(25, width - 4),
        3,
        function()
            print("Journal")
        end
    )

    UI.back(home)

end


-- ==========================================
-- PARAMETRES
-- ==========================================

function settings()

    UI.clear()

    UI.header("PARAMETRES")

    local title = UI.frame:addLabel()

    title:setText("BOREALIS OS")
    title:setPosition(2, 3)
    title:setForeground(colors.white)

    local version = UI.frame:addLabel()

    version:setText("Version 0.2")
    version:setPosition(2, 5)
    version:setForeground(colors.lime)

    local server = UI.frame:addLabel()

    server:setText("Serveur : Borealis")
    server:setPosition(2, 7)
    server:setForeground(colors.lime)

    UI.back(home)

end


-- ==========================================
-- LANCEMENT
-- ==========================================

home()

basalt.run()