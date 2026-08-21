local modem = peripheral.find("modem")

if not modem then
    error("Aucun modem detecte")
end

local modemSide = peripheral.getName(modem)
rednet.open(modemSide)

local monitor = peripheral.find("monitor")

local screen = monitor or term.current()

local currentUser = nil
local currentRole = nil
local serverID = nil

local buttons = {}

-- =========================================================
-- ECRAN
-- =========================================================

local function updateSize()
    screen = monitor or term.current()
    return screen.getSize()
end

local function clear()
    updateSize()

    screen.setBackgroundColor(colors.black)
    screen.setTextColor(colors.white)
    screen.clear()
    screen.setCursorPos(1, 1)
end

local function center(text, y)
    local width, height = updateSize()

    if y < 1 or y > height then
        return
    end

    text = tostring(text)

    local x = math.floor((width - #text) / 2) + 1

    if x < 1 then
        x = 1
    end

    screen.setCursorPos(x, y)
    screen.write(text)
end

-- =========================================================
-- BOUTONS
-- =========================================================

local function button(text, x, y, w, h, action)
    local width, height = updateSize()

    if x < 1 then
        x = 1
    end

    if y < 1 then
        y = 1
    end

    if x > width or y > height then
        return
    end

    w = math.min(w, width - x + 1)
    h = math.min(h, height - y + 1)

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

local function waitButton()
    if not monitor then
        return nil
    end

    while true do
        local event, side, x, y =
            os.pullEvent("monitor_touch")

        if side == peripheral.getName(monitor) then

            for _, b in ipairs(buttons) do

                if x >= b.x
                and x < b.x + b.w
                and y >= b.y
                and y < b.y + b.h then

                    return b.action
                end
            end
        end
    end
end

-- =========================================================
-- MESSAGE
-- =========================================================

local function showMessage(title, text)
    clear()

    center(title, 3)

    if text then
        center(text, 5)
    end

    if monitor then

        local width, height = updateSize()

        local w = math.min(16, width - 2)
        local x = math.floor((width - w) / 2) + 1
        local y = math.max(1, height - 2)

        buttons = {}

        button(
            "OK",
            x,
            y,
            w,
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

        local event, a, b =
            os.pullEvent()

        if event == "rednet_message" then

            local sender = a
            local message = b

            if type(message) == "table"
            and message.action == "server" then

                os.cancelTimer(timer)

                return sender
            end

        elseif event == "timer"
        and a == timer then

            return nil
        end
    end
end

-- =========================================================
-- SAISIE SUR COMPUTER
-- =========================================================

local function computerInput(title, hidden)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    term.clear()
    term.setCursorPos(1, 1)

    print("==============================")
    print("        BOREALIS OS")
    print("==============================")
    print("")
    print(title)
    print("")

    if hidden then
        return read("*")
    else
        return read()
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

            center(
                "Recherche du serveur...",
                7
            )

            serverID = findServer()

            if not serverID then

                showMessage(
                    "SERVEUR INTROUVABLE",
                    "Serveur non trouve"
                )
            end

        else

            local username =
                computerInput(
                    "Utilisateur :",
                    false
                )

            local password =
                computerInput(
                    "Mot de passe :",
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

                showMessage(
                    "CONNEXION REFUSEE",
                    tostring(response.result)
                )

            else

                serverID = nil

                showMessage(
                    "ERREUR",
                    "Serveur inaccessible"
                )
            end
        end
    end
end

-- =========================================================
-- MENU GENERIQUE
-- =========================================================

local function menu(title, items)
    clear()

    local width, height = updateSize()

    center(
        "BOREALIS OS",
        1
    )

    center(
        title,
        2
    )

    buttons = {}

    local count = #items

    if count == 0 then
        return nil
    end

    -- On calcule automatiquement l'espace disponible.
    local availableHeight = height - 5

    if availableHeight < count * 2 then

        -- Très petit écran :
        -- boutons empilés avec hauteur minimale.
        local y = 4

        for _, item in ipairs(items) do

            if y <= height then

                local w = math.min(
                    18,
                    width - 2
                )

                local x =
                    math.floor((width - w) / 2) + 1

                button(
                    item.label,
                    x,
                    y,
                    w,
                    1,
                    item.action
                )

                y = y + 2
            end
        end

    else

        local buttonHeight = 2
        local gap = 1

        local totalHeight =
            count * buttonHeight
            + (count - 1) * gap

        local startY =
            math.floor(
                (height - totalHeight) / 2
            ) + 1

        if startY < 4 then
            startY = 4
        end

        local w = math.min(
            22,
            width - 2
        )

        local x =
            math.floor((width - w) / 2) + 1

        for i, item in ipairs(items) do

            local y =
                startY
                + (i - 1)
                * (buttonHeight + gap)

            button(
                item.label,
                x,
                y,
                w,
                buttonHeight,
                item.action
            )
        end
    end

    if monitor then
        return waitButton()
    end

    -- =====================================================
    -- MODE COMPUTER
    -- =====================================================

    term.clear()
    term.setCursorPos(1, 1)

    print("==============================")
    print("        BOREALIS OS")
    print(title)
    print("==============================")
    print("")

    for i, item in ipairs(items) do
        print(
            tostring(i) ..
            " - " ..
            item.label
        )
    end

    print("")
    write("> ")

    local choice = tonumber(read())

    if choice
    and items[choice] then

        return items[choice].action
    end

    return "home"
end

-- =========================================================
-- TACHES
-- =========================================================

local function tasks()
    showMessage(
        "TACHES",
        "Aucune tache pour le moment"
    )

    return "home"
end

-- =========================================================
-- RAPPORTS
-- =========================================================

local function reports()
    showMessage(
        "RAPPORTS",
        "Aucun rapport pour le moment"
    )

    return "home"
end

-- =========================================================
-- CREATION COMPTE
-- =========================================================

local function sendCreate(
    username,
    password,
    role
)

    rednet.send(
        serverID,
        {
            action = "create_account",
            requester = currentUser,
            username = username,
            password = password,
            role = role
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

        showMessage(
            "CREATION",
            tostring(response.result)
        )

    else

        showMessage(
            "ERREUR",
            "Serveur inaccessible"
        )
    end

    return "accounts"
end

local function chooseRole()
    local username =
        computerInput(
            "Nom du nouveau compte :",
            false
        )

    local password =
        computerInput(
            "Mot de passe du nouveau compte :",
            true
        )

    local items = {
        {
            label = "USER",
            action = "create_user"
        },
        {
            label = "ADMIN",
            action = "create_admin"
        }
    }

    if currentRole == "root" then

        table.insert(
            items,
            {
                label = "ROOT",
                action = "create_root"
            }
        )
    end

    table.insert(
        items,
        {
            label = "ANNULER",
            action = "accounts"
        }
    )

    local action =
        menu(
            "CHOISIR LE ROLE",
            items
        )

    if action == "create_user" then

        return sendCreate(
            username,
            password,
            "user"
        )
    end

    if action == "create_admin" then

        return sendCreate(
            username,
            password,
            "admin"
        )
    end

    if action == "create_root" then

        return sendCreate(
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

local function accountList()
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

    clear()

    center(
        "BOREALIS OS",
        1
    )

    center(
        "COMPTES",
        2
    )

    if sender == serverID
    and type(response) == "table"
    and response.success then

        local width, height =
            updateSize()

        local y = 4

        for _, account in
            ipairs(response.accounts) do

            if y < height - 3 then

                local line =
                    tostring(account.username)
                    .. " : "
                    .. tostring(account.role)

                if #line > width then
                    line =
                        string.sub(
                            line,
                            1,
                            width
                        )
                end

                screen.setCursorPos(1, y)
                screen.write(line)

                y = y + 1
            end
        end

    else

        center(
            "ACCES REFUSE",
            6
        )
    end

    buttons = {}

    local width, height =
        updateSize()

    local w = math.min(
        18,
        width - 2
    )

    local x =
        math.floor((width - w) / 2) + 1

    button(
        "RETOUR",
        x,
        math.max(1, height - 2),
        w,
        2,
        "accounts"
    )

    if monitor then

        return waitButton()

    else

        print("")
        print("Appuyez sur ENTREE...")
        read()

        return "accounts"
    end
end

-- =========================================================
-- COMPTES
-- =========================================================

local function accounts()
    local items = {
        {
            label = "CREER COMPTE",
            action = "create"
        },
        {
            label = "LISTE COMPTES",
            action = "list"
        },
        {
            label = "RETOUR",
            action = "home"
        }
    }

    local action =
        menu(
            "GESTION DES COMPTES",
            items
        )

    if action == "create" then
        return chooseRole()
    end

    if action == "list" then
        return accountList()
    end

    return "home"
end

-- =========================================================
-- ACCUEIL
-- =========================================================

local function home()
    local items = {
        {
            label = "TACHES",
            action = "tasks"
        },
        {
            label = "RAPPORTS",
            action = "reports"
        }
    }

    -- IMPORTANT :
    -- ADMIN et ROOT ont acces aux comptes.
    if currentRole == "admin"
    or currentRole == "root" then

        table.insert(
            items,
            {
                label = "COMPTES",
                action = "accounts"
            }
        )
    end

    table.insert(
        items,
        {
            label = "DECONNEXION",
            action = "logout"
        }
    )

    return menu(
        "Bienvenue "
        .. tostring(currentUser)
        .. " ["
        .. tostring(currentRole)
        .. "]",
        items
    )
end

-- =========================================================
-- DEMARRAGE
-- =========================================================

if login() then

    local page = "home"

    while true do

        if page == "home" then

            page = home()

        elseif page == "tasks" then

            page = tasks()

        elseif page == "reports" then

            page = reports()

        elseif page == "accounts" then

            page = accounts()

        elseif page == "list" then

            page = accountList()

        elseif page == "create" then

            page = chooseRole()

        elseif page == "logout" then

            currentUser = nil
            currentRole = nil
            serverID = nil

            if login() then
                page = "home"
            else
                page = "home"
            end

        else

            page = "home"
        end
    end
end