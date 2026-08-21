-- =========================================================
-- BOREALIS OS - CLIENT V4
-- Clavier tactile + gestion des roles
-- =========================================================

local modem = peripheral.find("modem")

if not modem then
    error("Aucun modem detecte")
end

local modemSide = peripheral.getName(modem)

rednet.open(modemSide)

local monitor = peripheral.find("monitor")

local screen

if monitor then
    screen = monitor
else
    screen = term.native()
end

local width, height = screen.getSize()

local buttons = {}

local currentUser = nil
local currentRole = nil
local SERVER_ID = nil

local running = true

-- =========================================================
-- AFFICHAGE
-- =========================================================

local function clear()

    screen.setBackgroundColor(colors.black)
    screen.setTextColor(colors.white)

    screen.clear()
    screen.setCursorPos(1, 1)

end

local function write(text, x, y)

    if y < 1 or y > height then
        return
    end

    if x < 1 then
        x = 1
    end

    screen.setCursorPos(x, y)
    screen.write(tostring(text))

end

local function center(text, y)

    text = tostring(text)

    local x =
        math.floor((width - #text) / 2) + 1

    if x < 1 then
        x = 1
    end

    write(text, x, y)

end

-- =========================================================
-- BOUTONS
-- =========================================================

local function addButton(
    text,
    x,
    y,
    w,
    h,
    action
)

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

    table.insert(
        buttons,
        {
            x = x,
            y = y,
            w = w,
            h = h,
            action = action
        }
    )

    screen.setBackgroundColor(colors.gray)
    screen.setTextColor(colors.white)

    for yy = y, y + h - 1 do

        screen.setCursorPos(x, yy)

        screen.write(
            string.rep(" ", w)
        )

    end

    local textX =
        x + math.floor((w - #text) / 2)

    if textX < x then
        textX = x
    end

    local textY =
        y + math.floor(h / 2)

    if textY >= y
    and textY <= y + h - 1 then

        screen.setCursorPos(
            textX,
            textY
        )

        screen.write(text)

    end

    screen.setBackgroundColor(colors.black)

end

-- =========================================================
-- ATTENDRE UN CLIC
-- =========================================================

local function waitTouch()

    while true do

        local event,
              side,
              x,
              y =
            os.pullEvent("monitor_touch")

        if monitor
        and side ==
            peripheral.getName(monitor) then

            for _, b in ipairs(buttons) do

                if x >= b.x
                and x < b.x + b.w
                and y >= b.y
                and y < b.y + b.h then

                    return b.action()

                end

            end

        end

    end

end

-- =========================================================
-- CLAVIER VIRTUEL
-- =========================================================

local keyboardRows = {

    {
        "1","2","3","4","5",
        "6","7","8","9","0"
    },

    {
        "Q","W","E","R","T",
        "Y","U","I","O","P"
    },

    {
        "A","S","D","F","G",
        "H","J","K","L"
    },

    {
        "Z","X","C","V","B",
        "N","M"
    }

}

local function virtualInput(title, secret)

    -- -----------------------------------------------------
    -- SANS MONITEUR
    -- -----------------------------------------------------

    if not monitor then

        clear()

        center(
            "BOREALIS OS",
            2
        )

        center(
            title,
            4
        )

        write(
            "> ",
            2,
            7
        )

        screen.setCursorPos(4, 7)

        if secret then
            return read("*")
        else
            return read()
        end

    end

    -- -----------------------------------------------------
    -- AVEC MONITEUR
    -- -----------------------------------------------------

    local value = ""

    while true do

        buttons = {}

        clear()

        center(
            "BOREALIS OS",
            1
        )

        center(
            title,
            3
        )

        -- Champ de saisie
        local fieldX = 2
        local fieldY = 5
        local fieldW = width - 2

        if fieldW < 4 then
            fieldW = 4
        end

        screen.setBackgroundColor(
            colors.gray
        )

        screen.setCursorPos(
            fieldX,
            fieldY
        )

        screen.write(
            string.rep(
                " ",
                fieldW
            )
        )

        local display = value

        if secret then

            display =
                string.rep(
                    "*",
                    #value
                )

        end

        local maxText =
            fieldW - 1

        if #display > maxText then

            display =
                string.sub(
                    display,
                    #display - maxText + 1
                )

        end

        screen.setCursorPos(
            fieldX,
            fieldY
        )

        screen.write(display)

        screen.setBackgroundColor(
            colors.black
        )

        -- -------------------------------------------------
        -- CLAVIER
        -- -------------------------------------------------

        local keyboardStartY = 7

        local availableHeight =
            height - keyboardStartY - 5

        local rowHeight = 2

        local rowGap = 1

        local rowsCount =
            #keyboardRows

        -- Si l'écran est petit, on réduit l'espacement
        if availableHeight < 12 then
            rowGap = 0
        end

        for rowIndex, row in
            ipairs(keyboardRows) do

            local y =
                keyboardStartY +
                (rowIndex - 1) *
                (rowHeight + rowGap)

            local count = #row

            local gap = 1

            local keyWidth =
                math.floor(
                    (
                        width -
                        gap * (count + 1)
                    ) / count
                )

            if keyWidth < 1 then
                keyWidth = 1
            end

            for index, key in
                ipairs(row) do

                local x =
                    gap +
                    (index - 1) *
                    (keyWidth + gap)

                addButton(
                    key,
                    x,
                    y,
                    keyWidth,
                    rowHeight,
                    function()

                        value =
                            value .. key

                    end
                )

            end

        end

        -- -------------------------------------------------
        -- COMMANDES
        -- -------------------------------------------------

        local commandY =
            height - 4

        if commandY < 1 then
            commandY = 1
        end

        local commandGap = 1

        local backWidth =
            math.max(
                5,
                math.floor(width * 0.25)
            )

        local spaceWidth =
            math.max(
                5,
                math.floor(width * 0.25)
            )

        local okWidth =
            math.max(
                5,
                math.floor(width * 0.25)
            )

        -- RETOUR ARRIERE
        addButton(
            "<-",
            1,
            commandY,
            backWidth,
            2,
            function()

                if #value > 0 then

                    value =
                        string.sub(
                            value,
                            1,
                            #value - 1
                        )

                end

            end
        )

        -- ESPACE
        local spaceX =
            backWidth + commandGap + 1

        if spaceX + spaceWidth - 1 <= width then

            addButton(
                "ESPACE",
                spaceX,
                commandY,
                spaceWidth,
                2,
                function()

                    value =
                        value .. " "

                end
            )

        end

        -- OK
        local okX =
            width - okWidth + 1

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

        -- -------------------------------------------------
        -- ATTENTE DU TACTILE
        -- -------------------------------------------------

        local event,
              side,
              x,
              y =
            os.pullEvent(
                "monitor_touch"
            )

        if side ==
            peripheral.getName(monitor) then

            for _, b in
                ipairs(buttons) do

                if x >= b.x
                and x < b.x + b.w
                and y >= b.y
                and y < b.y + b.h then

                    local result =
                        b.action()

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
-- RECHERCHE SERVEUR
-- =========================================================

local function findServer()

    rednet.broadcast(
        {
            action = "ping"
        },
        "borealis"
    )

    local timer =
        os.startTimer(3)

    while true do

        local event,
              p1,
              p2 =
            os.pullEvent()

        if event ==
            "rednet_message" then

            local sender = p1
            local message = p2

            if type(message) == "table"
            and message.action ==
                "server" then

                SERVER_ID = sender

                os.cancelTimer(timer)

                return true

            end

        elseif event == "timer"
        and p1 == timer then

            return false

        end

    end

end

-- =========================================================
-- LOGIN
-- =========================================================

local function login()

    while true do

        clear()

        center(
            "BOREALIS OS",
            2
        )

        center(
            "CONNEXION",
            4
        )

        if not SERVER_ID then

            center(
                "Recherche serveur...",
                7
            )

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

                    os.pullEvent(
                        "monitor_touch"
                    )

                else

                    center(
                        "ENTREE POUR REESSAYER",
                        8
                    )

                    os.pullEvent("key")

                end

            end

        else

            local username =
                virtualInput(
                    "UTILISATEUR",
                    false
                )

            local password =
                virtualInput(
                    "MOT DE PASSE",
                    true
                )

            rednet.send(
                SERVER_ID,
                {
                    action = "login",

                    username =
                        username,

                    password =
                        password
                },
                "borealis"
            )

            local sender,
                  message =
                rednet.receive(
                    "borealis",
                    5
                )

            if sender == SERVER_ID
            and type(message) == "table"
            and message.action ==
                "login_result" then

                if message.success then

                    currentUser =
                        username

                    currentRole =
                        message.result

                    return true

                else

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

                        center(
                            "ENTREE POUR CONTINUER",
                            9
                        )

                        os.pullEvent("key")

                    end

                end

            else

                SERVER_ID = nil

            end

        end

    end

end

-- =========================================================
-- TACHES
-- =========================================================

function tasks()

    buttons = {}

    clear()

    center(
        "TACHES",
        2
    )

    center(
        "Aucune tache pour le moment.",
        5
    )

    addButton(
        "RETOUR",
        2,
        height - 3,
        math.min(18, width - 2),
        2,
        home
    )

end

-- =========================================================
-- RAPPORTS
-- =========================================================

function reports()

    buttons = {}

    clear()

    center(
        "RAPPORTS",
        2
    )

    center(
        "Aucun rapport.",
        5
    )

    addButton(
        "RETOUR",
        2,
        height - 3,
        math.min(18, width - 2),
        2,
        home
    )

end

-- =========================================================
-- CREATION DE COMPTE
-- =========================================================

function createAccount()

    local username =
        virtualInput(
            "NOUVEAU NOM",
            false
        )

    local password =
        virtualInput(
            "NOUVEAU MOT DE PASSE",
            true
        )

    -- -----------------------------------------------------
    -- CHOIX DU ROLE
    -- -----------------------------------------------------

    while true do

        buttons = {}

        clear()

        center(
            "CHOISIR LE ROLE",
            2
        )

        local bw =
            math.min(
                22,
                width - 2
            )

        local bx =
            math.floor(
                (width - bw) / 2
            ) + 1

        -- USER
        addButton(
            "USER",
            bx,
            5,
            bw,
            2,
            function()

                sendCreateAccount(
                    username,
                    password,
                    "user"
                )

            end
        )

        -- ADMIN
        addButton(
            "ADMIN",
            bx,
            9,
            bw,
            2,
            function()

                sendCreateAccount(
                    username,
                    password,
                    "admin"
                )

            end
        )

        -- ROOT
        if currentRole == "root" then

            addButton(
                "ROOT",
                bx,
                13,
                bw,
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

        -- ANNULER
        addButton(
            "ANNULER",
            bx,
            height - 3,
            bw,
            2,
            accounts
        )

        local event,
              side,
              x,
              y =
            os.pullEvent(
                "monitor_touch"
            )

        if side ==
            peripheral.getName(monitor) then

            for _, b in
                ipairs(buttons) do

                if x >= b.x
                and x < b.x + b.w
                and y >= b.y
                and y < b.y + b.h then

                    b.action()

                    return

                end

            end

        end

    end

end

-- =========================================================
-- ENVOI CREATION COMPTE
-- =========================================================

function sendCreateAccount(
    username,
    password,
    role
)

    rednet.send(
        SERVER_ID,
        {
            action =
                "create_account",

            requester =
                currentUser,

            username =
                username,

            password =
                password,

            role =
                role
        },
        "borealis"
    )

    local sender,
          message =
        rednet.receive(
            "borealis",
            5
        )

    buttons = {}

    clear()

    if sender == SERVER_ID
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

        os.pullEvent(
            "monitor_touch"
        )

    else

        center(
            "ENTREE POUR CONTINUER",
            8
        )

        os.pullEvent("key")

    end

    accounts()

end

-- =========================================================
-- LISTE DES COMPTES
-- =========================================================

function listAccounts()

    rednet.send(
        SERVER_ID,
        {
            action =
                "list_accounts",

            requester =
                currentUser
        },
        "borealis"
    )

    local sender,
          message =
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

    if sender == SERVER_ID
    and type(message) == "table"
    and message.success then

        local y = 4

        for _, account in
            ipairs(message.accounts) do

            if y < height - 4 then

                write(
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
        math.min(18, width - 2),
        2,
        accounts
    )

end

-- =========================================================
-- GESTION DES COMPTES
-- =========================================================

function accounts()

    buttons = {}

    clear()

    center(
        "GESTION DES COMPTES",
        2
    )

    local bw =
        math.min(
            22,
            width - 2
        )

    local bx =
        math.floor(
            (width - bw) / 2
        ) + 1

    addButton(
        "CREER COMPTE",
        bx,
        6,
        bw,
        2,
        createAccount
    )

    addButton(
        "LISTE COMPTES",
        bx,
        10,
        bw,
        2,
        listAccounts
    )

    addButton(
        "RETOUR",
        bx,
        height - 3,
        bw,
        2,
        home
    )

end

-- =========================================================
-- ACCUEIL
-- =========================================================

function home()

    buttons = {}

    clear()

    center(
        "BOREALIS OS",
        2
    )

    center(
        "Bienvenue " ..
        currentUser,
        4
    )

    center(
        "Role : " ..
        currentRole,
        6
    )

    local bw =
        math.min(
            22,
            width - 2
        )

    local bx =
        math.floor(
            (width - bw) / 2
        ) + 1

    addButton(
        "TACHES",
        bx,
        8,
        bw,
        2,
        tasks
    )

    addButton(
        "RAPPORTS",
        bx,
        11,
        bw,
        2,
        reports
    )

    local nextY = 14

    if currentRole == "admin"
    or currentRole == "root" then

        addButton(
            "COMPTES",
            bx,
            nextY,
            bw,
            2,
            accounts
        )

        nextY = nextY + 3

    end

    addButton(
        "DECONNEXION",
        bx,
        nextY,
        bw,
        2,
        function()

            currentUser = nil
            currentRole = nil
            SERVER_ID = nil

            login()

            home()

        end
    )

end

-- =========================================================
-- DEMARRAGE
-- =========================================================

if login() then

    home()

    if monitor then

        while running do

            local event,
                  side,
                  x,
                  y =
                os.pullEvent(
                    "monitor_touch"
                )

            if side ==
                peripheral.getName(monitor) then

                for _, b in
                    ipairs(buttons) do

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

    else

        while running do

            local event,
                  key =
                os.pullEvent("key")

            if key == keys.t then

                tasks()

            elseif key == keys.r then

                reports()

            elseif key == keys.a
            and (
                currentRole == "admin"
                or currentRole == "root"
            ) then

                accounts()

            elseif key == keys.q then

                running = false

            end

        end

    end

end
```
