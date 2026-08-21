local modem = peripheral.find("modem")

if not modem then
    error("Aucun modem detecte")
end

local modemSide = peripheral.getName(modem)
rednet.open(modemSide)

local monitor = peripheral.find("monitor")
local screen = monitor or term.native()

local width, height = screen.getSize()

local buttons = {}

local currentUser = nil
local currentRole = nil
local serverID = nil

-- Forward declarations
local home
local accounts
local tasks
local reports
local createAccount
local listAccounts
local chooseRole

-- =========================================================
-- AFFICHAGE
-- =========================================================

local function clear()
    screen.setBackgroundColor(colors.black)
    screen.setTextColor(colors.white)
    screen.clear()
    screen.setCursorPos(1, 1)
end

local function writeText(value, x, y)
    if y < 1 or y > height then
        return
    end

    if x < 1 then
        x = 1
    end

    screen.setCursorPos(x, y)
    screen.write(tostring(value))
end

local function center(value, y)
    value = tostring(value)

    local x = math.floor((width - #value) / 2) + 1

    if x < 1 then
        x = 1
    end

    writeText(value, x, y)
end

-- =========================================================
-- BOUTONS
-- =========================================================

local function addButton(label, x, y, w, h, action)
    if w < 1 or h < 1 then
        return
    end

    if x < 1 then
        x = 1
    end

    if y < 1 then
        y = 1
    end

    if x + w - 1 > width then
        w = width - x + 1
    end

    if y + h - 1 > height then
        h = height - y + 1
    end

    if w < 1 or h < 1 then
        return
    end

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

    local tx = x + math.floor((w - #label) / 2)
    local ty = y + math.floor(h / 2)

    if tx < x then
        tx = x
    end

    screen.setCursorPos(tx, ty)
    screen.write(label)

    screen.setBackgroundColor(colors.black)
end

-- =========================================================
-- ATTENTE TACTILE
-- =========================================================

local function waitTouch()
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")

        if monitor and side == peripheral.getName(monitor) then
            for _, button in ipairs(buttons) do
                if x >= button.x
                    and x < button.x + button.w
                    and y >= button.y
                    and y < button.y + button.h then

                    return button.action()
                end
            end
        end
    end
end

-- =========================================================
-- SERVEUR
-- =========================================================

local function findServer()
    rednet.broadcast({
        action = "ping"
    }, "borealis")

    local timer = os.startTimer(3)

    while true do
        local event, a, b = os.pullEvent()

        if event == "rednet_message" then
            local sender = a
            local message = b

            if type(message) == "table"
                and message.action == "server" then

                serverID = sender
                os.cancelTimer(timer)

                return true
            end

        elseif event == "timer" and a == timer then
            return false
        end
    end
end

-- =========================================================
-- CLAVIER TACTILE
-- =========================================================

local keyboardRows = {
    {"1","2","3","4","5","6","7","8","9","0"},
    {"Q","W","E","R","T","Y","U","I","O","P"},
    {"A","S","D","F","G","H","J","K","L"},
    {"Z","X","C","V","B","N","M"}
}

local function touchInput(title, password)
    if not monitor then
        clear()

        center("BOREALIS OS", 2)
        center(title, 4)

        writeText("> ", 2, 7)
        screen.setCursorPos(4, 7)

        if password then
            return read("*")
        end

        return read()
    end

    local value = ""

    while true do
        buttons = {}
        clear()

        center("BOREALIS OS", 1)
        center(title, 3)

        -- Champ de texte
        screen.setBackgroundColor(colors.gray)

        screen.setCursorPos(2, 5)
        screen.write(string.rep(" ", math.max(1, width - 2)))

        local displayed = value

        if password then
            displayed = string.rep("*", #value)
        end

        local maxLength = math.max(1, width - 3)

        if #displayed > maxLength then
            displayed = string.sub(
                displayed,
                #displayed - maxLength + 1
            )
        end

        screen.setCursorPos(2, 5)
        screen.write(displayed)

        screen.setBackgroundColor(colors.black)

        -- Calcul des touches
        local startY = 7
        local rowGap = 1
        local keyHeight = 2

        for rowNumber, row in ipairs(keyboardRows) do
            local count = #row
            local gap = 1

            local keyWidth = math.floor(
                (width - gap * (count + 1)) / count
            )

            if keyWidth < 1 then
                keyWidth = 1
            end

            local y = startY +
                (rowNumber - 1) *
                (keyHeight + rowGap)

            for index, key in ipairs(row) do
                local x = gap +
                    (index - 1) *
                    (keyWidth + gap)

                addButton(
                    key,
                    x,
                    y,
                    keyWidth,
                    keyHeight,
                    function()
                        value = value .. key
                    end
                )
            end
        end

        -- Boutons du bas
        local commandY = height - 3

        if commandY < 1 then
            commandY = 1
        end

        local backWidth = math.max(
            3,
            math.floor(width * 0.25)
        )

        local spaceWidth = math.max(
            4,
            math.floor(width * 0.35)
        )

        local okWidth = math.max(
            3,
            math.floor(width * 0.25)
        )

        addButton(
            "<",
            1,
            commandY,
            backWidth,
            2,
            function()
                if #value > 0 then
                    value = string.sub(
                        value,
                        1,
                        #value - 1
                    )
                end
            end
        )

        local spaceX = backWidth + 2

        if spaceX + spaceWidth - 1 <= width then
            addButton(
                "ESPACE",
                spaceX,
                commandY,
                spaceWidth,
                2,
                function()
                    value = value .. " "
                end
            )
        end

        local okX = width - okWidth + 1

        if okX < 1 then
            okX = 1
        end

        addButton(
            "OK",
            okX,
            commandY,
            okWidth,
            2,
            function()
                return value
            end
        )

        local event, side, x, y =
            os.pullEvent("monitor_touch")

        if side == peripheral.getName(monitor) then
            for _, button in ipairs(buttons) do
                if x >= button.x
                    and x < button.x + button.w
                    and y >= button.y
                    and y < button.y + button.h then

                    local result = button.action()

                    if result ~= nil then
                        return result
                    end

                    break
                end
            end
        end
    end
end

-- =========================================================
-- CONNEXION
-- =========================================================

local function login()
    while true do
        clear()

        center("BOREALIS OS", 2)
        center("CONNEXION", 4)

        if not serverID then
            center("Recherche du serveur...", 7)

            if not findServer() then
                clear()

                center(
                    "SERVEUR INTROUVABLE",
                    4
                )

                if monitor then
                    center(
                        "TOUCHEZ POUR REESSAYER",
                        8
                    )

                    os.pullEvent("monitor_touch")
                else
                    center(
                        "APPUYEZ SUR UNE TOUCHE",
                        8
                    )

                    os.pullEvent("key")
                end
            end
        else
            local username = touchInput(
                "UTILISATEUR",
                false
            )

            local password = touchInput(
                "MOT DE PASSE",
                true
            )

            rednet.send(
                serverID,
                {
                    action = "login",
                    username = username,
                    password = password
                },
                "borealis"
            )

            local sender, message =
                rednet.receive(
                    "borealis",
                    5
                )

            if sender == serverID
                and type(message) == "table"
                and message.action == "login_result" then

                if message.success then
                    currentUser = username
                    currentRole = message.result

                    return true
                end

                clear()

                center(
                    "CONNEXION REFUSEE",
                    4
                )

                center(
                    message.result,
                    6
                )

                if monitor then
                    center(
                        "TOUCHEZ POUR CONTINUER",
                        9
                    )

                    os.pullEvent(
                        "monitor_touch"
                    )
                else
                    os.pullEvent("key")
                end

            else
                serverID = nil
            end
        end
    end
end

-- =========================================================
-- TACHES
-- =========================================================

tasks = function()
    buttons = {}
    clear()

    center("TACHES", 2)

    center(
        "Aucune tache pour le moment.",
        5
    )

    addButton(
        "RETOUR",
        2,
        height - 3,
        math.min(20, width - 2),
        2,
        home
    )

    if monitor then
        waitTouch()
    else
        os.pullEvent("key")
        home()
    end
end

-- =========================================================
-- RAPPORTS
-- =========================================================

reports = function()
    buttons = {}
    clear()

    center("RAPPORTS", 2)

    center(
        "Aucun rapport.",
        5
    )

    addButton(
        "RETOUR",
        2,
        height - 3,
        math.min(20, width - 2),
        2,
        home
    )

    if monitor then
        waitTouch()
    else
        os.pullEvent("key")
        home()
    end
end

-- =========================================================
-- ENVOI CREATION COMPTE
-- =========================================================

local function sendCreateAccount(
    username,
    password,
    newRole
)
    rednet.send(
        serverID,
        {
            action = "create_account",
            requester = currentUser,
            username = username,
            password = password,
            role = newRole
        },
        "borealis"
    )

    local sender, message =
        rednet.receive(
            "borealis",
            5
        )

    buttons = {}
    clear()

    if sender == serverID
        and type(message) == "table" then

        center(
            message.result,
            5
        )
    else
        center(
            "SERVEUR INDISPONIBLE",
            5
        )
    end

    if monitor then
        center(
            "TOUCHEZ POUR CONTINUER",
            8
        )

        os.pullEvent("monitor_touch")
    else
        os.pullEvent("key")
    end

    accounts()
end

-- =========================================================
-- CHOIX DU ROLE
-- =========================================================

chooseRole = function(username, password)
    buttons = {}
    clear()

    center(
        "CHOISIR LE ROLE",
        2
    )

    local buttonWidth = math.min(
        22,
        width - 2
    )

    local x = math.floor(
        (width - buttonWidth) / 2
    ) + 1

    addButton(
        "USER",
        x,
        5,
        buttonWidth,
        2,
        function()
            sendCreateAccount(
                username,
                password,
                "user"
            )
        end
    )

    addButton(
        "ADMIN",
        x,
        9,
        buttonWidth,
        2,
        function()
            sendCreateAccount(
                username,
                password,
                "admin"
            )
        end
    )

    if currentRole == "root" then
        addButton(
            "ROOT",
            x,
            13,
            buttonWidth,
            2,
            function()
                sendCreateAccount(
                    username,
                    password,
                    "root"
                )
            end
        )
    end

    addButton(
        "ANNULER",
        x,
        height - 3,
        buttonWidth,
        2,
        accounts
    )

    waitTouch()
end

-- =========================================================
-- CREER UN COMPTE
-- =========================================================

createAccount = function()
    local username = touchInput(
        "NOUVEAU NOM",
        false
    )

    local password = touchInput(
        "NOUVEAU MOT DE PASSE",
        true
    )

    if monitor then
        chooseRole(
            username,
            password
        )
    else
        clear()

        center(
            "CHOISIR LE ROLE",
            2
        )

        center(
            "1 = USER",
            5
        )

        center(
            "2 = ADMIN",
            7
        )

        if currentRole == "root" then
            center(
                "3 = ROOT",
                9
            )
        end

        local event, key =
            os.pullEvent("key")

        if key == keys.one then
            sendCreateAccount(
                username,
                password,
                "user"
            )
        elseif key == keys.two then
            sendCreateAccount(
                username,
                password,
                "admin"
            )
        elseif key == keys.three
            and currentRole == "root" then

            sendCreateAccount(
                username,
                password,
                "root"
            )
        else
            accounts()
        end
    end
end

-- =========================================================
-- LISTE DES COMPTES
-- =========================================================

listAccounts = function()
    rednet.send(
        serverID,
        {
            action = "list_accounts",
            requester = currentUser
        },
        "borealis"
    )

    local sender, message =
        rednet.receive(
            "borealis",
            5
        )

    buttons = {}
    clear()

    center(
        "COMPTES",
        2
    )

    if sender == serverID
        and type(message) == "table"
        and message.success then

        local y = 4

        for _, account in
            ipairs(message.accounts) do

            if y < height - 4 then
                writeText(
                    account.username ..
                    " : " ..
                    account.role,
                    2,
                    y
                )

                y = y + 1
            end
        end
    else
        center(
            "ACCES REFUSE",
            5
        )
    end

    addButton(
        "RETOUR",
        2,
        height - 3,
        math.min(20, width - 2),
        2,
        accounts
    )

    if monitor then
        waitTouch()
    else
        os.pullEvent("key")
        accounts()
    end
end

-- =========================================================
-- GESTION DES COMPTES
-- =========================================================

accounts = function()
    buttons = {}
    clear()

    center(
        "GESTION DES COMPTES",
        2
    )

    local buttonWidth = math.min(
        22,
        width - 2
    )

    local x = math.floor(
        (width - buttonWidth) / 2
    ) + 1

    addButton(
        "CREER COMPTE",
        x,
        6,
        buttonWidth,
        2,
        createAccount
    )

    addButton(
        "LISTE COMPTES",
        x,
        10,
        buttonWidth,
        2,
        listAccounts
    )

    addButton(
        "RETOUR",
        x,
        height - 3,
        buttonWidth,
        2,
        home
    )

    if monitor then
        waitTouch()
    else
        os.pullEvent("key")
        home()
    end
end

-- =========================================================
-- ACCUEIL
-- =========================================================

home = function()
    buttons = {}
    clear()

    center(
        "BOREALIS OS",
        2
    )

    center(
        "Bienvenue " .. currentUser,
        4
    )

    center(
        "Role : " .. currentRole,
        6
    )

    local buttonWidth = math.min(
        22,
        width - 2
    )

    local x = math.floor(
        (width - buttonWidth) / 2
    ) + 1

    addButton(
        "TACHES",
        x,
        8,
        buttonWidth,
        2,
        tasks
    )

    addButton(
        "RAPPORTS",
        x,
        11,
        buttonWidth,
        2,
        reports
    )

    local y = 14

    if currentRole == "admin"
        or currentRole == "root" then

        addButton(
            "COMPTES",
            x,
            y,
            buttonWidth,
            2,
            accounts
        )

        y = y + 3
    end

    addButton(
        "DECONNEXION",
        x,
        y,
        buttonWidth,
        2,
        function()
            currentUser = nil
            currentRole = nil
            serverID = nil
            login()
            home()
        end
    )

    if monitor then
        waitTouch()
    else
        while true do
            local event, key =
                os.pullEvent("key")

            if key == keys.t then
                tasks()
                break
            elseif key == keys.r then
                reports()
                break
            elseif key == keys.a
                and (
                    currentRole == "admin"
                    or currentRole == "root"
                ) then

                accounts()
                break
            elseif key == keys.q then
                return
            end
        end
    end
end

-- =========================================================
-- DEMARRAGE
-- =========================================================

if login() then
    home()
end

-- =========================================================
