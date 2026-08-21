local monitor = peripheral.wrap("left")

if not monitor then
    error("Monitor introuvable sur left")
end

local width, height = monitor.getSize()

local buttons = {}

-- ==================================================
-- OUTILS
-- ==================================================

local function clear()
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
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

local function button(textValue, x, y, w, h, action)

    local b = {
        x = x,
        y = y,
        w = w,
        h = h,
        action = action
    }

    table.insert(buttons, b)

    monitor.setBackgroundColor(colors.gray)
    monitor.setTextColor(colors.white)

    for yy = y, y + h - 1 do
        monitor.setCursorPos(x, yy)
        monitor.write(string.rep(" ", w))
    end

    local tx = x + math.floor((w - #textValue) / 2)

    if tx < x then
        tx = x
    end

    local ty = y + math.floor(h / 2)

    monitor.setCursorPos(tx, ty)
    monitor.setTextColor(colors.white)
    monitor.write(textValue)

    monitor.setBackgroundColor(colors.black)

end

local function backButton()

    button(
        "< RETOUR",
        2,
        height - 2,
        math.min(16, width - 2),
        2,
        home
    )

end

-- ==================================================
-- CALCUL DES BOUTONS
-- ==================================================

local function grid()

    local margin = math.max(1, math.floor(width * 0.05))

    local gap = math.max(1, math.floor(width * 0.04))

    local buttonWidth =
        math.floor((width - margin * 2 - gap) / 2)

    if buttonWidth < 8 then
        buttonWidth = 8
    end

    return margin, gap, buttonWidth

end

-- ==================================================
-- ACCUEIL
-- ==================================================

function home()

    buttons = {}

    clear()

    center("BOREALIS OS", 2)

    center("SERVEUR : ONLINE", 4)

    local margin, gap, bw = grid()

    local bh = math.max(2, math.floor(height * 0.12))

    local y1 = 6
    local y2 = y1 + bh + 1
    local y3 = y2 + bh + 1

    button(
        "TACHES",
        margin,
        y1,
        bw,
        bh,
        tasks
    )

    button(
        "EMPLOYES",
        margin + bw + gap,
        y1,
        bw,
        bh,
        employees
    )

    button(
        "RAPPORTS",
        margin,
        y2,
        bw,
        bh,
        reports
    )

    button(
        "MUSIQUE",
        margin + bw + gap,
        y2,
        bw,
        bh,
        music
    )

    button(
        "ADMIN",
        margin,
        y3,
        bw,
        bh,
        admin
    )

end

-- ==================================================
-- TACHES
-- ==================================================

function tasks()

    buttons = {}

    clear()

    center("TACHES", 2)

    text(
        "MES TACHES",
        2,
        5
    )

    text(
        "[ ] Aucune tache",
        2,
        7
    )

    backButton()

end

-- ==================================================
-- EMPLOYES
-- ==================================================

function employees()

    buttons = {}

    clear()

    center("EMPLOYES", 2)

    text(
        "EMPLOYES CONNECTES",
        2,
        5
    )

    text(
        "Aucun employe",
        2,
        7
    )

    backButton()

end

-- ==================================================
-- RAPPORTS
-- ==================================================

function reports()

    buttons = {}

    clear()

    center("RAPPORTS", 2)

    text(
        "RAPPORTS",
        2,
        5
    )

    text(
        "Aucun rapport",
        2,
        7
    )

    button(
        "NOUVEAU",
        2,
        9,
        math.min(18, width - 4),
        3,
        function()
            text("Rapport cree !", 2, 13)
        end
    )

    backButton()

end

-- ==================================================
-- MUSIQUE
-- ==================================================

function music()

    buttons = {}

    clear()

    center("MUSIQUE", 2)

    text(
        "LECTEUR BOREALIS",
        2,
        5
    )

    text(
        "Aucune musique",
        2,
        7
    )

    local bw = math.min(
        16,
        math.floor((width - 5) / 2)
    )

    button(
        "LECTURE",
        2,
        9,
        bw,
        3,
        function()
            text("Lecture...", 2, 13)
        end
    )

    button(
        "STOP",
        bw + 4,
        9,
        bw,
        3,
        function()
            text("Stop", 2, 13)
        end
    )

    backButton()

end

-- ==================================================
-- ADMINISTRATION
-- ==================================================

function admin()

    buttons = {}

    clear()

    center("ADMINISTRATION", 2)

    local bw = math.min(
        24,
        width - 4
    )

    button(
        "CREER TACHE",
        2,
        6,
        bw,
        3,
        function()
            text("Creation de tache", 2, 11)
        end
    )

    button(
        "EMPLOYES",
        2,
        11,
        bw,
        3,
        function()
            text("Gestion employes", 2, 16)
        end
    )

    backButton()

end

-- ==================================================
-- DEMARRAGE
-- ==================================================

home()

-- ==================================================
-- TACTILE
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