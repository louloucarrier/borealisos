local modem = peripheral.find("modem")

if not modem then
    error("Aucun modem detecte")
end

local modemSide =
    peripheral.getName(modem)

rednet.open(modemSide)

local monitor =
    peripheral.find("monitor")

local screen

if monitor then
    screen = monitor
else
    screen = term.native()
end

local width, height =
    screen.getSize()

local buttons = {}

local currentUser = nil
local currentRole = nil

local SERVER_ID = nil

--------------------------------------------------
-- SERVEUR
--------------------------------------------------

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

--------------------------------------------------
-- AFFICHAGE
--------------------------------------------------

local function clear()

    screen.setBackgroundColor(
        colors.black
    )

    screen.setTextColor(
        colors.white
    )

    screen.clear()

    screen.setCursorPos(1, 1)

end

local function write(text, x, y)

    screen.setCursorPos(x, y)

    screen.write(text)

end

local function center(text, y)

    local x =
        math.floor(
            (width - #text) / 2
        ) + 1

    if x < 1 then
        x = 1
    end

    write(text, x, y)

end

--------------------------------------------------
-- BOUTONS
--------------------------------------------------

local function addButton(
    name,
    x,
    y,
    w,
    h,
    action
)

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

    screen.setBackgroundColor(
        colors.gray
    )

    for yy = y, y + h - 1 do

        screen.setCursorPos(
            x,
            yy
        )

        screen.write(
            string.rep(" ", w)
        )

    end

    local tx =
        x +
        math.floor(
            (w - #name) / 2
        )

    if tx < x then
        tx = x
    end

    screen.setCursorPos(
        tx,
        y + math.floor(h / 2)
    )

    screen.write(name)

    screen.setBackgroundColor(
        colors.black
    )

end

--------------------------------------------------
-- SAISIE
--------------------------------------------------

local function input(
    prompt,
    password
)

    clear()

    center(
        "BOREALIS OS",
        2
    )

    write(
        prompt,
        2,
        5
    )

    screen.setCursorPos(
        2,
        7
    )

    if password then

        return read("*")

    else

        return read()

    end

end

--------------------------------------------------
-- LOGIN
--------------------------------------------------

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

            write(
                "Recherche serveur...",
                2,
                7
            )

            if not findServer() then

                clear()

                center(
                    "SERVEUR INTROUVABLE",
                    3
                )

                center(
                    "R = REESSAYER",
                    6
                )

                while true do

                    local event,
                          key =
                        os.pullEvent(
                            "key"
                        )

                    if key == keys.r then
                        break
                    end

                end

            end

        else

            local username =
                input(
                    "Utilisateur :",
                    false
                )

            local password =
                input(
                    "Mot de passe :",
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
            and message
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
                        3
                    )

                    center(
                        message.result,
                        5
                    )

                    center(
                        "ENTREE = RETOUR",
                        8
                    )

                    os.pullEvent("key")

                end

            else

                SERVER_ID = nil

            end

        end

    end

end

--------------------------------------------------
-- ACCUEIL
--------------------------------------------------

local function home()

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

    local y = 8

    addButton(
        "TACHES",
        2,
        y,
        math.min(
            20,
            width - 4
        ),
        3,
        tasks
    )

    y = y + 5

    addButton(
        "RAPPORTS",
        2,
        y,
        math.min(
            20,
            width - 4
        ),
        3,
        reports
    )

    y = y + 5

    if currentRole == "admin"
    or currentRole == "root" then

        addButton(
            "COMPTES",
            2,
            y,
            math.min(
                20,
                width - 4
            ),
            3,
            accounts
        )

        y = y + 5

    end

    addButton(
        "DECONNEXION",
        2,
        y,
        math.min(
            20,
            width - 4
        ),
        3,
        function()

            currentUser = nil
            currentRole = nil
            SERVER_ID = nil

            login()

            home()

        end
    )

end

--------------------------------------------------
-- TACHES
--------------------------------------------------

function tasks()

    buttons = {}

    clear()

    center(
        "TACHES",
        2
    )

    write(
        "Aucune tache.",
        2,
        5
    )

    addButton(
        "RETOUR",
        2,
        height - 3,
        14,
        2,
        home
    )

end

--------------------------------------------------
-- RAPPORTS
--------------------------------------------------

function reports()

    buttons = {}

    clear()

    center(
        "RAPPORTS",
        2
    )

    write(
        "Aucun rapport.",
        2,
        5
    )

    addButton(
        "RETOUR",
        2,
        height - 3,
        14,
        2,
        home
    )

end

--------------------------------------------------
-- COMPTES
--------------------------------------------------

function accounts()

    buttons = {}

    clear()

    center(
        "COMPTES",
        2
    )

    addButton(
        "CREER COMPTE",
        2,
        6,
        math.min(
            20,
            width - 4
        ),
        3,
        createAccount
    )

    addButton(
        "LISTE COMPTES",
        2,
        11,
        math.min(
            20,
            width - 4
        ),
        3,
        listAccounts
    )

    addButton(
        "RETOUR",
        2,
        height - 3,
        14,
        2,
        home
    )

end

--------------------------------------------------
-- CREATION
--------------------------------------------------

function createAccount()

    local username =
        input(
            "Nouveau nom :",
            false
        )

    local password =
        input(
            "Mot de passe :",
            true
        )

    clear()

    center(
        "CHOISIR LE ROLE",
        2
    )

    write(
        "1 = USER",
        2,
        5
    )

    write(
        "2 = ADMIN",
        2,
        6
    )

    if currentRole == "root" then

        write(
            "3 = ROOT",
            2,
            7
        )

    end

    local event,
          key =
        os.pullEvent("key")

    local role

    if key == keys.one then

        role = "user"

    elseif key == keys.two then

        role = "admin"

    elseif key == keys.three
    and currentRole == "root" then

        role = "root"

    else

        accounts()

        return

    end

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

    clear()

    if sender == SERVER_ID
    and message then

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

    center(
        "ENTREE = CONTINUER",
        8
    )

    os.pullEvent("key")

    accounts()

end

--------------------------------------------------
-- LISTE
--------------------------------------------------

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

    clear()

    center(
        "COMPTES",
        2
    )

    if sender == SERVER_ID
    and message
    and message.success then

        local y = 4

        for _, account in
            ipairs(message.accounts) do

            write(
                account.username ..
                " : " ..
                account.role,
                2,
                y
            )

            y = y + 1

            if y >= height - 3 then
                break
            end

        end

    else

        write(
            "Acces refuse",
            2,
            5
        )

    end

    addButton(
        "RETOUR",
        2,
        height - 2,
        14,
        2,
        accounts
    )

end

--------------------------------------------------
-- TACTILE
--------------------------------------------------

local function monitorLoop()

    while true do

        local event,
              side,
              x,
              y =
            os.pullEvent(
                "monitor_touch"
            )

        if monitor
        and side ==
            peripheral.getName(monitor)
        then

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

end

--------------------------------------------------
-- CLAVIER
--------------------------------------------------

local function keyboardLoop()

    while true do

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

            return

        end

    end

end

--------------------------------------------------
-- DEMARRAGE
--------------------------------------------------

if not login() then
    return
end

home()

if monitor then

    monitorLoop()

else

    keyboardLoop()

end