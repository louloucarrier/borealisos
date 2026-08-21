local basalt = dofile("basalt.lua")

local monitor = peripheral.wrap("left")

if not monitor then
    error("Monitor introuvable sur left")
end

local width, height = monitor.getSize()

local page = "home"

-- ==================================================
-- AFFICHAGE
-- ==================================================

local function clear()
    monitor.clear()
    monitor.setCursorPos(1, 1)
end

local function text(txt, x, y)
    monitor.setCursorPos(x, y)
    monitor.write(txt)
end

local function center(txt, y)

    local x = math.floor((width - #txt) / 2) + 1

    if x < 1 then
        x = 1
    end

    text(txt, x, y)

end

-- ==================================================
-- BOUTON
-- ==================================================

local buttons = {}

local function addButton(name, x, y, w, h, action)

    table.insert(buttons, {
        name = name,
        x = x,
        y = y,
        w = w,
        h = h,
        action = action
    })

    for yy = y, y + h - 1 do

        monitor.setCursorPos(x, yy)

        monitor.write(
            string.rep(" ", w)
        )

    end

    local tx = x + math.floor((w - #name) / 2)

    if tx < x then
        tx = x
    end

    monitor.setCursorPos(tx, y + math.floor(h / 2))

    monitor.write(name)

end

-- ==================================================
-- ACCUEIL
-- ==================================================

local function home()

    page = "home"

    buttons = {}

    clear()

    center("BOREALIS OS", 2)

    center("SERVEUR : ONLINE", 4)

    local w = math.floor((width - 6) / 2)

    addButton(
        "TACHES",
        2,
        7,
        w,
        3,
        function()
            tasks()
        end
    )

    addButton(
        "EMPLOYES",
        w + 4,
        7,
        w,
        3,
        function()
            employees()
        end
    )

    addButton(
        "RAPPORTS",
        2,
        12,
        w,
        3,
        function()
            reports()
        end
    )

    addButton(
        "MUSIQUE",
        w + 4,
        12,
        w,
        3,
        function()
            music()
        end
    )

    addButton(
        "ADMIN",
        2,
        17,
        w,
        3,
        function()
            admin()
        end
    )

end

-- ==================================================
-- TACHES
-- ==================================================

function tasks()

    page = "tasks"

    buttons = {}

    clear()

    center("TACHES", 2)

    text("MES TACHES", 2, 5)

    text("[ ] Aucune tache", 2, 7)

    addButton(
        "RETOUR",
        2,
        height - 2,
        12,
        2,
        home
    )

end

-- ==================================================
-- EMPLOYES
-- ==================================================

function employees()

    page = "employees"

    buttons = {}

    clear()

    center("EMPLOYES", 2)

    text("EMPLOYES CONNECTES", 2, 5)

    text("Aucun employe", 2, 7)

    addButton(
        "RETOUR",
        2,
        height - 2,
        12,
        2,
        home
    )

end

-- ==================================================
-- RAPPORTS
-- ==================================================

function reports()

    page = "reports"

    buttons = {}

    clear()

    center("RAPPORTS", 2)

    text("Aucun rapport disponible.", 2, 5)

    addButton(
        "NOUVEAU",
        2,
        8,
        15,
        3,
        function()
            text("Rapport cree !", 2, 12)
        end
    )

    addButton(
        "RETOUR",
        2,
        height - 2,
        12,
        2,
        home
    )

end

-- ==================================================
-- MUSIQUE
-- ==================================================

function music()

    page = "music"

    buttons = {}

    clear()

    center("MUSIQUE", 2)

    text("Aucune musique.", 2, 5)

    addButton(
        "LECTURE",
        2,
        8,
        12,
        3,
        function()
            text("Lecture...", 2, 13)
        end
    )

    addButton(
        "STOP",
        16,
        8,
        12,
        3,
        function()
            text("Arret.", 2, 13)
        end
    )

    addButton(
        "RETOUR",
        2,
        height - 2,
        12,
        2,
        home
    )

end

-- ==================================================
-- ADMINISTRATION
-- ==================================================

function admin()

    page = "admin"

    buttons = {}

    clear()

    center("ADMINISTRATION", 2)

    addButton(
        "CREER TACHE",
        2,
        6,
        20,
        3,
        function()
            text("Creation de tache", 2, 11)
        end
    )

    addButton(
        "EMPLOYES",
        2,
        11,
        20,
        3,
        function()
            text("Gestion des employes", 2, 16)
        end
    )

    addButton(
        "RETOUR",
        2,
        height - 2,
        12,
        2,
        home
    )

end

-- ==================================================
-- DEMARRAGE
-- ==================================================

home()

-- ==================================================
-- BOUCLE TACTILE
-- ==================================================

while true do

    local event, side, x, y =
        os.pullEvent("monitor_touch")

    if side == "left" then

        for _, b in ipairs(buttons) do

            if x >= b.x
            and x < b.x + b.w
            and y >= b.y
            and y < b.y + b.h then

                b.action()

                break

            end

        end

    end

end