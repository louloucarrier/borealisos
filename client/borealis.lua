local monitor = peripheral.find("monitor")

local screen

if monitor then
    screen = monitor
else
    screen = term.native()
end

local width, height = screen.getSize()

local buttons = {}

local function clear()
    screen.setBackgroundColor(colors.black)
    screen.setTextColor(colors.white)
    screen.clear()
    screen.setCursorPos(1, 1)
end

local function write(text, x, y)
    screen.setCursorPos(x, y)
    screen.write(text)
end

local function center(text, y)
    local x = math.floor((width - #text) / 2) + 1

    if x < 1 then
        x = 1
    end

    write(text, x, y)
end

local function addButton(name, x, y, w, h, action)

    table.insert(buttons, {
        x = x,
        y = y,
        w = w,
        h = h,
        action = action
    })

    screen.setBackgroundColor(colors.gray)
    screen.setTextColor(colors.white)

    for yy = y, y + h - 1 do
        screen.setCursorPos(x, yy)
        screen.write(string.rep(" ", w))
    end

    local tx = x + math.floor((w - #name) / 2)

    if tx < x then
        tx = x
    end

    local ty = y + math.floor(h / 2)

    screen.setCursorPos(tx, ty)
    screen.write(name)

    screen.setBackgroundColor(colors.black)
end

local function back()
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
        write("R = RETOUR", 1, height)
    end
end

function home()

    buttons = {}
    clear()

    if width < 20 or height < 8 then

        center("BOREALIS", 1)

        write("T = TACHES", 1, 3)
        write("E = EMPLOYES", 1, 4)
        write("A = ADMIN", 1, 5)
        write("Q = QUITTER", 1, 6)

        return
    end

    center("BOREALIS OS", 2)
    center("SERVEUR : ONLINE", 4)

    local gap = 2
    local margin = 2

    local bw = math.floor(
        (width - margin * 2 - gap) / 2
    )

    local bh = 3

    addButton(
        "TACHES",
        margin,
        7,
        bw,
        bh,
        tasks
    )

    addButton(
        "EMPLOYES",
        margin + bw + gap,
        7,
        bw,
        bh,
        employees
    )

    addButton(
        "RAPPORTS",
        margin,
        12,
        bw,
        bh,
        reports
    )

    addButton(
        "MUSIQUE",
        margin + bw + gap,
        12,
        bw,
        bh,
        music
    )

    addButton(
        "ADMIN",
        margin,
        17,
        bw,
        bh,
        admin
    )
end

function tasks()

    buttons = {}
    clear()

    center("TACHES", 2)

    write("MES TACHES", 2, 5)
    write("[ ] Aucune tache", 2, 7)

    back()
end

function employees()

    buttons = {}
    clear()

    center("EMPLOYES", 2)

    write("EMPLOYES CONNECTES", 2, 5)
    write("Aucun employe", 2, 7)

    back()
end

function reports()

    buttons = {}
    clear()

    center("RAPPORTS", 2)

    write("Aucun rapport", 2, 5)

    if height >= 10 then
        addButton(
            "NOUVEAU",
            2,
            8,
            math.min(18, width - 4),
            3,
            function()
                write("Rapport cree !", 2, height - 3)
            end
        )
    end

    back()
end

function music()

    buttons = {}
    clear()

    center("MUSIQUE", 2)

    write("Aucune musique", 2, 5)

    if height >= 12 then

        addButton(
            "LECTURE",
            2,
            8,
            12,
            3,
            function()
                write("Lecture...", 2, height - 3)
            end
        )

        addButton(
            "STOP",
            16,
            8,
            12,
            3,
            function()
                write("Stop", 2, height - 3)
            end
        )
    end

    back()
end

function admin()

    buttons = {}
    clear()

    center("ADMINISTRATION", 2)

    if height >= 12 then

        addButton(
            "CREER TACHE",
            2,
            6,
            math.min(22, width - 4),
            3,
            function()
                write("Creation tache", 2, height - 3)
            end
        )

        addButton(
            "EMPLOYES",
            2,
            11,
            math.min(22, width - 4),
            3,
            function()
                write("Gestion employes", 2, height - 3)
            end
        )
    else

        write("1 = TACHE", 1, 4)
        write("2 = EMPLOYES", 1, 5)
    end

    back()
end

home()

if monitor then

    while true do

        local event, side, x, y =
            os.pullEvent("monitor_touch")

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

else

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
            break
        end
    end
end