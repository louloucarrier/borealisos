local modem = peripheral.find("modem")

if not modem then
    error("Aucun modem detecte")
end

rednet.open(peripheral.getName(modem))

local monitor = peripheral.find("monitor")
local screen = monitor or term.current()

local width, height = screen.getSize()

local buttons = {}

local currentUser = nil
local currentRole = nil
local serverID = nil

-- =========================================================
-- AFFICHAGE
-- =========================================================

local function clear()
    screen.setBackgroundColor(colors.black)
    screen.setTextColor(colors.white)
    screen.clear()
    screen.setCursorPos(1, 1)
end

local function center(text, y)
    text = tostring(text)

    if y < 1 or y > height then
        return
    end

    local x = math.floor((width - #text) / 2) + 1

    if x < 1 then
        x = 1
    end

    screen.setCursorPos(x, y)
    screen.write(text)
end

local function writeAt(text, x, y)
    if y < 1 or y > height then
        return
    end

    screen.setCursorPos(x, y)
    screen.write(tostring(text))
end

-- =========================================================
-- BOUTONS
-- =========================================================

local function drawButton(text, x, y, w, h, action)
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

    local tx = x + math.floor((w - #text) / 2)
    local ty = y + math.floor(h / 2)

    if tx < x then
        tx = x
    end

    screen.setCursorPos(tx, ty)
    screen.write(text)

    screen.setBackgroundColor(colors.black)
end

-- =========================================================
-- ATTENTE BOUTON
-- =========================================================

local function waitButton()
    if not monitor then
        return nil
    end

    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")

        if side == peripheral.getName(monitor) then
            for _, button in ipairs(buttons) do
                if x >= button.x
                    and x < button.x + button.w
                    and y >= button.y
                    and y < button.y + button.h then

                    return button.action
                end
            end
        end
    end
end

-- =========================================================
-- MESSAGE
-- =========================================================

local function message(title, line)
    buttons = {}
    clear()

    center(title, 3)

    if line then
        center(line, 5)
    end

    if monitor then
        drawButton(
            "OK",
            math.max(1, math.floor((width - 14) / 2)),
            height - 3,
            math.min(14, width),
            2,
            "ok"
        )

        waitButton()
    else
        print("")
        print("Appuyez sur ENTREE...")
        read()
    end
end

-- =========================================================
-- RECHERCHE SERVEUR
-- =========================================================

local function findServer()
    rednet.broadcast(
        {
            action = "ping"
        },
        "borealis"
    )

    local timer = os.startTimer(3)

    while true do
        local event, a, b = os.pullEvent()

        if event == "rednet_message" then
            local sender = a
            local msg = b

            if type(msg) == "table"
                and msg.action == "server" then

                os.cancelTimer(timer)
                return sender
            end

        elseif event == "timer" and a == timer then
            return nil
        end
    end
end

-- =========================================================
-- LOGIN
-- =========================================================

local function login()
    while true do
        clear()

        center("BOREALIS OS", 2)
        center("CONNEXION", 4)

        if not serverID then
            center("Recherche du serveur...", 7)

            serverID = findServer()

            if not serverID then
                message(
                    "SERVEUR INTROUVABLE",
                    "Impossible de trouver Borealis"
                )
            end
        else
            -- Toujours saisir sur le Computer
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)

            term.clear()
            term.setCursorPos(1, 1)

            print("================================")
            print("        BOREALIS OS")
            print("          CONNEXION")
            print("================================")
            print("")
            write("Utilisateur : ")

            local username = read()

            write("Mot de passe : ")

            local password = read("*")

            print("")
            print("Connexion...")

            rednet.send(
                serverID,
                {
                    action = "login",
                    username = username,
                    password = password
                },
                "borealis"
            )

            local sender, response =
                rednet.receive(
                    "borealis",
                    5
                )

            if sender == serverID
                and type(response) == "table"
                and response.action == "login_result" then

                if response.success then
                    currentUser = username
                    currentRole = response.result

                    return true
                end

                message(
                    "CONNEXION REFUSEE",
                    tostring(response.result)
                )
            else
                serverID = nil

                message(
                    "ERREUR",
                    "Serveur inaccessible"
                )
            end
        end
    end
end

-- =========================================================
-- TACHES
-- =========================================================

local function showTasks()
    buttons = {}
    clear()

    center("BOREALIS OS", 2)
    center("TACHES", 4)

    center(
        "Aucune tache pour le moment.",
        7
    )

    drawButton(
        "RETOUR",
        math.max(1, math.floor((width - 18) / 2)),
        height - 3,
        math.min(18, width),
        2,
        "home"
    )

    if monitor then
        return waitButton()
    end

    print("")
    print("Appuyez sur ENTREE...")
    read()

    return "home"
end

-- =========================================================
-- RAPPORTS
-- =========================================================

local function showReports()
    buttons = {}
    clear()

    center("BOREALIS OS", 2)
    center("RAPPORTS", 4)

    center(
        "Aucun rapport pour le moment.",
        7
    )

    drawButton(
        "RETOUR",
        math.max(1, math.floor((width - 18) / 2)),
        height - 3,
        math.min(18, width),
        2,
        "home"
    )

    if monitor then
        return waitButton()
    end

    print("")
    print("Appuyez sur ENTREE...")
    read()

    return "home"
end

-- =========================================================
-- CREATION COMPTE
-- =========================================================

local function sendCreateAccount(username, password, newRole)
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

    local sender, response =
        rednet.receive(
            "borealis",
            5
        )

    if sender == serverID
        and type(response) == "table" then

        message(
            "CREATION COMPTE",
            tostring(response.result)
        )
    else
        message(
            "ERREUR",
            "Serveur inaccessible"
        )
    end

    return "accounts"
end

-- =========================================================
-- CHOIX DU ROLE
-- =========================================================

local function roleMenu(username, password)
    buttons = {}
    clear()

    center("BOREALIS OS", 2)
    center("CHOISIR LE ROLE", 4)

    local buttonWidth = math.min(
        24,
        width - 2
    )

    local x = math.floor(
        (width - buttonWidth) / 2
    ) + 1

    drawButton(
        "USER",
        x,
        7,
        buttonWidth,
        2,
        "create_user"
    )

    drawButton(
        "ADMIN",
        x,
        10,
        buttonWidth,
        2,
        "create_admin"
    )

    if currentRole == "root" then
        drawButton(
            "ROOT",
            x,
            13,
            buttonWidth,
            2,
            "create_root"
        )
    end

    drawButton(
        "ANNULER",
        x,
        height - 3,
        buttonWidth,
        2,
        "accounts"
    )

    local action = waitButton()

    if action == "create_user" then
        return sendCreateAccount(
            username,
            password,
            "user"
        )
    end

    if action == "create_admin" then
        return sendCreateAccount(
            username,
            password,
            "admin"
        )
    end

    if action == "create_root" then
        return sendCreateAccount(
            username,
            password,
            "root"
        )
    end

    return action
end

-- =========================================================
-- CREER UN COMPTE
-- =========================================================

local function createAccountScreen()
    -- Saisie sur le Computer
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    term.clear()
    term.setCursorPos(1, 1)

    print("================================")
    print("       CREATION DE COMPTE")
    print("================================")
    print("")
    write("Nom du compte : ")

    local username = read()

    print("")
    write("Mot de passe : ")

    local password = read("*")

    if username == "" then
        message(
            "ERREUR",
            "Nom de compte vide"
        )

        return "accounts"
    end

    if password == "" then
        message(
            "ERREUR",
            "Mot de passe vide"
        )

        return "accounts"
    end

    if monitor then
        return roleMenu(
            username,
            password
        )
    end

    -- Sans moniteur
    clear()

    print("Choisir le role :")
    print("")
    print("1 - USER")
    print("2 - ADMIN")

    if currentRole == "root" then
        print("3 - ROOT")
    end

    print("")
    write("> ")

    local choice = read()

    if choice == "1" then
        return sendCreateAccount(
            username,
            password,
            "user"
        )
    end

    if choice == "2" then
        return sendCreateAccount(
            username,
            password,
            "admin"
        )
    end

    if choice == "3"
        and currentRole == "root" then

        return sendCreateAccount(
            username,
            password,
            "root"
        )
    end

    return "accounts"
end

-- =========================================================
-- LISTE COMPTES
-- =========================================================

local function showAccounts()
    rednet.send(
        serverID,
        {
            action = "list_accounts",
            requester = currentUser
        },
        "borealis"
    )

    local sender, response =
        rednet.receive(
            "borealis",
            5
        )

    buttons = {}
    clear()

    center("BOREALIS OS", 2)
    center("COMPTES", 4)

    if sender == serverID
        and type(response) == "table"
        and response.success then

        local y = 6

        for _, account in
            ipairs(response.accounts) do

            if y < height - 4 then
                writeAt(
                    tostring(account.username)
                    .. " : "
                    .. tostring(account.role),
                    2,
                    y
                )

                y = y + 1
            end
        end

        if y == 6 then
            center(
                "Aucun compte",
                7
            )
        end
    else
        center(
            "ACCES REFUSE",
            7
        )
    end

    drawButton(
        "RETOUR",
        math.max(1, math.floor((width - 18) / 2)),
        height - 3,
        math.min(18, width),
        2,
        "accounts"
    )

    if monitor then
        return waitButton()
    end

    print("")
    print("Appuyez sur ENTREE...")
    read()

    return "accounts"
end

-- =========================================================
-- MENU COMPTES
-- =========================================================

local function accountsScreen()
    buttons = {}
    clear()

    center("BOREALIS OS", 2)
    center("GESTION DES COMPTES", 4)

    local buttonWidth = math.min(
        24,
        width - 2
    )

    local x = math.floor(
        (width - buttonWidth) / 2
    ) + 1

    drawButton(
        "CREER COMPTE",
        x,
        7,
        buttonWidth,
        2,
        "create_account"
    )

    drawButton(
        "LISTE DES COMPTES",
        x,
        11,
        buttonWidth,
        2,
        "list_accounts"
    )

    drawButton(
        "RETOUR",
        x,
        height - 3,
        buttonWidth,
        2,
        "home"
    )

    if monitor then
        return waitButton()
    end

    print("")
    print("1 - Creer compte")
    print("2 - Liste comptes")
    print("3 - Retour")
    print("")
    write("> ")

    local choice = read()

    if choice == "1" then
        return "create_account"
    end

    if choice == "2" then
        return "list_accounts"
    end

    return "home"
end

-- =========================================================
-- ACCUEIL
-- =========================================================

local function homeScreen()
    buttons = {}
    clear()

    center(
        "BOREALIS OS",
        2
    )

    center(
        "Bienvenue " .. tostring(currentUser),
        4
    )

    center(
        "Role : " .. tostring(currentRole),
        6
    )

    local buttonWidth = math.min(
        24,
        width - 2
    )

    local x = math.floor(
        (width - buttonWidth) / 2
    ) + 1

    drawButton(
        "TACHES",
        x,
        8,
        buttonWidth,
        2,
        "tasks"
    )

    drawButton(
        "RAPPORTS",
        x,
        11,
        buttonWidth,
        2,
        "reports"
    )

    local y = 14

    if currentRole == "admin"
        or currentRole == "root" then

        drawButton(
            "COMPTES",
            x,
            y,
            buttonWidth,
            2,
            "accounts"
        )

        y = y + 3
    end

    drawButton(
        "DECONNEXION",
        x,
        y,
        buttonWidth,
        2,
        "logout"
    )

    if monitor then
        return waitButton()
    end

    print("")
    print("T - Taches")
    print("R - Rapports")

    if currentRole == "admin"
        or currentRole == "root" then

        print("A - Comptes")
    end

    print("Q - Deconnexion")
    print("")
    write("> ")

    local choice = read()

    if choice == "t" then
        return "tasks"
    end

    if choice == "r" then
        return "reports"
    end

    if choice == "a"
        and (
            currentRole == "admin"
            or currentRole == "root"
        ) then

        return "accounts"
    end

    if choice == "q" then
        return "logout"
    end

    return "home"
end

-- =========================================================
-- BOUCLE PRINCIPALE
-- =========================================================

if login() then
    local page = "home"

    while true do

        if page == "home" then
            page = homeScreen()

        elseif page == "tasks" then
            page = showTasks()

        elseif page == "reports" then
            page = showReports()

        elseif page == "accounts" then
            page = accountsScreen()

        elseif page == "create_account" then
            page = createAccountScreen()

        elseif page == "list_accounts" then
            page = showAccounts()

        elseif page == "logout" then
            currentUser = nil
            currentRole = nil
            serverID = nil

            login()

            page = "home"

        else
            page = "home"
        end
    end
end
