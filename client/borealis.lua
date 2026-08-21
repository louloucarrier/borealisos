```lua
-- =========================================================
-- BOREALIS OS - CLIENT V3
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

    screen.setCursorPos(x, y)
    screen.write(text)

end

local function center(text, y)

    local x =
        math.floor((width - #text) / 2) + 1

    if x < 1 then
        x = 1
    end

    write(text, x, y)

end

local function button(
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

        if yy >= 1 and yy <= height then

            screen.setCursorPos(x, yy)

            screen.write(
                string.rep(" ", w)
            )

        end

    end

    local tx =
        x + math.floor((w - #text) / 2)

    if tx < x then
        tx = x
    end

    local ty =
        y + math.floor(h / 2)

    if ty >= 1 and ty <= height then

        screen.setCursorPos(tx, ty)
        screen.write(text)

    end

    screen.setBackgroundColor(colors.black)

end

-- =========================================================
-- CLAVIER VIRTUEL
-- =========================================================

local keyboardRows = {
    {
        "1","2","3","4","5","6","7","8","9","0"
    },
    {
        "Q","W","E","R","T","Y","U","I","O","P"
    },
    {
        "A","S","D","F","G","H","J","K","L"
    },
    {
        "Z","X","C","V","B","N","M"
    }
}

local function virtualInput(prompt, secret)

    -- Sans monitor : clavier physique
    if not monitor then

        clear()

        center("BOREALIS OS", 2)

        write(prompt, 2, 5)

        screen.setCursorPos(2, 7)

        if secret then
            return read("*")
        else
            return read()
        end

    end

    local value = ""

    while true do

        buttons = {}

        clear()

        center("BOREALIS OS", 1)
        center(prompt, 3)

        -- Champ de texte
        screen.setBackgroundColor(colors.gray)
        screen.setTextColor(colors.white)

        screen.setCursorPos(2, 5)

        local display = value

        if secret then
            display = string.rep("*", #value)
        end

        local fieldWidth = width - 4

        if fieldWidth < 1 then
            fieldWidth = 1
        end

        if #display > fieldWidth then
            display =
                string.sub(
                    display,
                    #display - fieldWidth + 1
                )
        end

        screen.write(
            string.rep(" ", fieldWidth)
        )

        screen.setCursorPos(2, 5)
        screen.write(display)

        screen.setBackgroundColor(colors.black)

        local startY = 7

        -- Touches lettres/chiffres
        for rowIndex, row in ipairs(keyboardRows) do

            local rowY =
                startY + (rowIndex - 1) * 3

            local count = #row

            local gap = 1

            local keyWidth =
                math.floor(
                    (width - gap * (count + 1))
                    / count
                )

            if keyWidth < 2 then
                keyWidth = 2
            end

            for i, key in ipairs(row) do

                local x =
                    gap +
                    (i - 1) *
                    (keyWidth + gap)

                button(
                    key,
                    x,
                    rowY,
                    keyWidth,
                    2,
                    function()
                        value =
                            value .. key
                    end
                )

            end

        end

        local bottomY =
            startY + #keyboardRows * 3

        -- ESPACE
        button(
            "ESPACE",
            2,
            bottomY,
            math.max(5, math.floor(width * 0.35)),
            2,
            function()
                value = value .. " "
            end
        )

        -- EFFACER
        button(
            "EFF",
            math.floor(width * 0.4),
            bottomY,
            math.max(4, math.floor(width * 0.2)),
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

        -- OK
        button(
            "OK",
            math.floor(width * 0.63),
            bottomY,
            math.max(4, math.floor(width * 0.35)),
            2,
            function()
                return true
            end
        )

        -- Attendre le tactile
        local event,
              side,
              x,
              y =
            os.pullEvent("monitor_touch")

        if side ==
            peripheral.getName(monitor) then

            for _, b in ipairs(buttons) do

                if x >= b.x
                and x < b.x + b.w
                and y >= b.y
                and y < b.y + b.h then

                    -- Bouton OK
                    if b.y == bottomY
                    and b.x >= math.floor(width * 0.63) then

                        return value

                    end

                    b.action()

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

        if event == "rednet_message" then

            local sender = p1
            local message = p2

            if type(message) == "table"
            and message.action == "server" then

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

        center("BOREALIS OS", 2)
        center("CONNEXION", 4)

        if not SERVER_ID then

            center(
                "Recherche du serveur...",
                7
            )

            if not findServer() then

                clear()

                center(
                    "SERVEUR INTROUVABLE",
                    4
                )

                center(
                    "Touchez l'ecran pour reessayer",
                    7
                )

                if monitor then

                    os.pullEvent(
                        "monitor_touch"
                    )

                else

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
                    username = username,
                    password = password
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
                            "Touchez pour continuer",
                            9
                        )

                        os.pullEvent(
                            "monitor_touch"
                        )

                    else

                        center(
                            "ENTREE = CONTINUER",
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

    center("TACHES", 2)

    write(
        "Aucune tache pour le moment.",
        2,
        5
    )

    button(
        "RETOUR",
        2,
        height - 3,
        math.min(18, width - 4),
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

    center("RAPPORTS", 2)

    write(
        "Aucun rapport.",
        2,
        5
    )

    button(
        "RETOUR",
        2,
        height - 3,
        math.min(18, width - 4),
        2,
        home
    )

end

-- =========================================================
-- LISTE COMPTES
-- =========================================================

function listAccounts()

    rednet.send(
        SERVER_ID,
        {
            action = "list_accounts",
            requester = currentUser
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

    center("COMPTES", 2)

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

        write(
            "Acces refuse",
            2,
            5
        )

    end

    button(
        "RETOUR",
        2,
        height - 3,
        math.min(18, width - 4),
        2,
        accounts
    )

end

-- =========================================================
-- CREER COMPTE
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

    buttons = {}

    clear()

    center(
        "CHOISIR LE ROLE",
        2
    )

    local buttonWidth =
        math.min(18, width - 4)

    button(
        "USER",
        2,
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

    button(
        "ADMIN",
        2,
        8,
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

        button(
            "ROOT",
            2,
            11,
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

    button(
        "ANNULER",
        2,
        height - 3,
        buttonWidth,
        2,
        accounts
    )

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
            action = "create_account",

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
            "Serveur indisponible",
            5
        )

    end

    if monitor then

        center(
            "Touchez pour continuer",
            8
        )

        os.pullEvent(
            "monitor_touch"
        )

    else

        center(
            "ENTREE = CONTINUER",
            8
        )

        os.pullEvent("key")

    end

    accounts()

end

-- =========================================================
-- COMPTES
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
            width - 4
        )

    button(
        "CREER COMPTE",
        2,
        6,
        bw,
        2,
        createAccount
    )

    button(
        "LISTE COMPTES",
        2,
        10,
        bw,
        2,
        listAccounts
    )

    button(
        "RETOUR",
        2,
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

    write(
        "Role : " ..
        currentRole,
        2,
        6
    )

    local bw =
        math.min(
            22,
            width - 4
        )

    button(
        "TACHES",
        2,
        8,
        bw,
        2,
        tasks
    )

    button(
        "RAPPORTS",
        2,
        11,
        bw,
        2,
        reports
    )

    local nextY = 14

    if currentRole == "admin"
    or currentRole == "root" then

        button(
            "COMPTES",
            2,
            nextY,
            bw,
            2,
            accounts
        )

        nextY = nextY + 3

    end

    button(
        "DECONNEXION",
        2,
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
-- BOUCLE TACTILE PRINCIPALE
-- =========================================================

local function monitorLoop()

    while running do

        local event,
              side,
              x,
              y =
            os.pullEvent(
                "monitor_touch"
            )

        if monitor
        and side ==
            peripheral.getName(monitor) then

            local clicked = false

            for _, b in
                ipairs(buttons) do

                if x >= b.x
                and x < b.x + b.w
                and y >= b.y
                and y < b.y + b.h then

                    clicked = true

                    b.action()

                    break

                end

            end

        end

    end

end

-- =========================================================
-- CLAVIER PC
-- =========================================================

local function keyboardLoop()

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

-- =========================================================
-- DEMARRAGE
-- =========================================================

if login() then

    home()

    if monitor then

        monitorLoop()

    else

        keyboardLoop()

    end

end
```
