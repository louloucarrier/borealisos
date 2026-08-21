local monitor = peripheral.find("monitor")

local term = term

local usingMonitor = monitor ~= nil

if usingMonitor then
    term = monitor
end

local width, height = term.getSize()

local buttons = {}

-- ==================================================
-- OUTILS
-- ==================================================

local function clear()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
end

local function text(txt, x, y)
    term.setCursorPos(x, y)
    term.write(txt)
end

local function center(txt, y)

    local x = math.floor((width - #txt) / 2) + 1

    if x < 1 then
        x = 1
    end

    text(txt, x, y)

end

local function addButton(name, x, y, w, h, action)

    local b = {
        name = name,
        x = x,
        y = y,
        w = w,
        h = h,
        action = action
    }

    table.insert(buttons, b)

    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)

    for yy = y, y + h - 1 do

        term.setCursorPos(x, yy)

        term.write(
            string.rep(" ", w)
        )

    end

    local tx =
        x + math.floor((w - #name) / 2)

    if tx < x then
        tx = x
    end

    local ty =
        y + math.floor(h / 2)

    term.setCursorPos(tx, ty)

    term.write(name)

    term.setBackgroundColor(colors.black)

end

local function backButton()

    if height >= 6 then

        addButton(
            "RETOUR",
            2,
            height - 2,
            math.min(14, width - 2),
            2,
            home
        )

    else

        text(
            "R=RETOUR",
            1,
            height
        )

    end

end

-- ==================================================
-- ACCUEIL
-- ==================================================

function home()

    buttons = {}

    clear()

    -- Ecran tres petit

    if width < 20 or height < 8 then

        center("BOREALIS", 1)

        text(
            "T=TACHES",
            1,
            3
        )

        text(
            "E=EMPLOYES",
            1,
            4
        )

        text(
            "A=ADMIN",
            1,
            5
        )

        text(
            "Q=QUITTER",
            1,
            6
        )

        return

    end

    center(
        "BOREALIS OS",
        2
    )

    center(
        "SERVEUR : ONLINE",
        4
    )

    local margin =
        math.max(
            1,
            math.floor(width * 0.05)
        )

    local gap =
        math.max(
            1,
            math.floor(width * 0.04)
        )

    local bw =
        math.floor(
            (width - margin * 2 - gap) / 2
        )

    if bw < 8 then
        bw = 8
    end

    local bh =
        math.max(
            2,
            math.floor(height * 0.12)
        )

    local y1 = 6

    local y2 =
        y1 + bh + 1

    local y3 =
        y2 + bh + 1

    addButton(
        "TACHES",
        margin,
        y1,
        bw,
        bh,
        tasks
    )

    addButton(
        "EMPLOYES",
        margin + bw + gap,
        y1,
        bw,
        bh,
        employees
    )

    addButton(
        "RAPPORTS",
        margin,
        y2,
        bw,
        bh,
        reports
    )

    addButton(
        "MUSIQUE",
        margin + bw + gap,
        y2,
        bw,
        bh,
        music
    )

    addButton(
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

    center(
        "TACHES",
        2
    )

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

    center(
        "EMPLOYES",
        2
    )

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

    center(
        "RAPPORTS",
        2
    )

    text(
        "Aucun rapport",
        2,
        5
    )

    if height >= 10 then

        addButton(
            "NOUVEAU",
            2,
            8,
            math.min(18, width - 4),
            3,
            function()

                text(
                    "Rapport cree !",
                    2,
                    height - 4
                )

            end
        )

    end

    backButton()

end

-- ==================================================
-- MUSIQUE
-- ==================================================

function music()

    buttons = {}

    clear()

    center(
        "MUSIQUE",
        2
    )

    text(
        "Aucune musique",
        2,
        5
    )

    if height >= 12 then

        local bw =
            math.min(
                16,
                math.floor(
                    (width - 5) / 2
                )
            )

        addButton(
            "LECTURE",
            2,
            8,
            bw,
            3,
            function()

                text(
                    "Lecture...",
                    2,
                    height - 4
                )

            end
        )

        addButton(
            "STOP",
            bw + 4,
            8,
            bw,
            3,
            function()

                text(
                    "Stop",
                    2,
                    height - 4
                )

            end
        )

    end

    backButton()

end

-- ==================================================
-- ADMIN
-- ==================================================

function admin()

    buttons = {}

    clear()

    center(
        "ADMIN",
        2
    )

    if height >= 12 then

        addButton(
            "CREER TACHE",
            2,
            6,
            math.min(22, width - 4),
            3,
            function()

                text(
                    "Creation tache",
                    2,
                    height - 4
                )

            end
        )

        addButton(
            "EMPLOYES",
            2,
            11,
            math.min(22, width - 4),
            3,
            function()

                text(
                    "Gestion employes",
                    2,
                    height - 4
                )

            end
        )

    else

        text(
            "1=TACHE",
            1,
            4
        )

        text(
            "2=EMPLOYES",
            1,
            5
        )

    end

    backButton()

end

-- ==================================================
-- INTERFACE PC
-- ==================================================

local function keyboardLoop()

    while true do

        local event, key =
            os.pullEvent("key")

        if key == keys.t then
            tasks()

        elseif key == keys.e then
            employees()

        elseif key == keys.a then
            admin()

        elseif key == keys.r then
            home()

        elseif key == keys.q then
            return

        end

    end

end

-- ==================================================
-- INTERFACE MONITOR
-- ==================================================

local function monitorLoop()

    while true do

        local event, side, x, y =
            os.pullEvent("monitor_touch")

        if monitor
        and side == peripheral.getName(monitor) then

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

end

-- ==================================================
-- DEMARRAGE
-- ==================================================

home()

if usingMonitor then

    monitorLoop()

else

    keyboardLoop()

end