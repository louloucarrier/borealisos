local modem = peripheral.find("modem")
if not modem then error("Aucun modem") end

rednet.open(peripheral.getName(modem))

local monitor = peripheral.find("monitor")
local screen = monitor or term.native()
local width, height = screen.getSize()

local buttons = {}
local user = nil
local role = nil
local server = nil

local function clear()
    screen.setBackgroundColor(colors.black)
    screen.setTextColor(colors.white)
    screen.clear()
end

local function text(t, x, y)
    screen.setCursorPos(x, y)
    screen.write(tostring(t))
end

local function center(t, y)
    t = tostring(t)
    text(t, math.max(1, math.floor((width - #t) / 2) + 1), y)
end

local function addButton(t, x, y, w, h, fn)
    table.insert(buttons, {
        x=x,y=y,w=w,h=h,fn=fn
    })

    screen.setBackgroundColor(colors.gray)

    for yy=y,y+h-1 do
        screen.setCursorPos(x, yy)
        screen.write(string.rep(" ", w))
    end

    local tx=x+math.floor((w-#t)/2)
    local ty=y+math.floor(h/2)

    screen.setCursorPos(math.max(x,tx),ty)
    screen.write(t)

    screen.setBackgroundColor(colors.black)
end

local function waitTouch()
    while true do
        local e,side,x,y=os.pullEvent("monitor_touch")

        if monitor and side==peripheral.getName(monitor) then
            for _,b in ipairs(buttons) do
                if x>=b.x and x<b.x+b.w
                and y>=b.y and y<b.y+b.h then
                    return b.fn()
                end
            end
        end
    end
end

local function findServer()
    rednet.broadcast({action="ping"},"borealis")

    local timer=os.startTimer(3)

    while true do
        local e,a,b=os.pullEvent()

        if e=="rednet_message" then
            if type(b)=="table" and b.action=="server" then
                server=a
                os.cancelTimer(timer)
                return true
            end
        elseif e=="timer" and a==timer then
            return false
        end
    end
end

-- =========================================================
-- CLAVIER TACTILE
-- =========================================================

local keys={
    {"1","2","3","4","5","6","7","8","9","0"},
    {"Q","W","E","R","T","Y","U","I","O","P"},
    {"A","S","D","F","G","H","J","K","L"},
    {"Z","X","C","V","B","N","M"}
}

local function input(title,password)

    if not monitor then
        clear()
        center("BOREALIS OS",2)
        center(title,4)
        text("> ",2,7)
        screen.setCursorPos(4,7)

        if password then
            return read("*")
        else
            return read()
        end
    end

    local value=""

    while true do
        buttons={}
        clear()

        center("BOREALIS OS",1)
        center(title,3)

        screen.setBackgroundColor(colors.gray)
        screen.setCursorPos(2,5)

        local display=value

        if password then
            display=string.rep("*",#value)
        end

        local max=width-3

        if #display>max then
            display=string.sub(display,#display-max+1)
        end

        screen.write(string.rep(" ",width-2))
        screen.setCursorPos(2,5)
        screen.write(display)

        screen.setBackgroundColor(colors.black)

        local start=7

        for r,row in ipairs(keys) do

            local count=#row
            local gap=1

            local w=math.floor(
                (width-gap*(count+1))/count
            )

            if w<1 then w=1 end

            local y=start+(r-1)*3

            for i,k in ipairs(row) do

                local x=gap+(i-1)*(w+gap)

                addButton(
                    k,
                    x,
                    y,
                    w,
                    2,
                    function()
                        value=value..k
                    end
                )

            end
        end

        local y=height-3

        local w1=math.max(4,math.floor(width/4))
        local w2=math.max(5,math.floor(width/3))
        local w3=math.max(4,math.floor(width/4))

        addButton(
            "<",
            1,
            y,
            w1,
            2,
            function()
                if #value>0 then
                    value=string.sub(value,1,#value-1)
                end
            end
        )

        addButton(
            "ESPACE",
            w1+2,
            y,
            w2,
            2,
            function()
                value=value.." "
            end
        )

        addButton(
            "OK",
            width-w3+1,
            y,
            w3,
            2,
            function()
                return value
            end
        )

        local e,side,x,y2=
            os.pullEvent("monitor_touch")

        if side==peripheral.getName(monitor) then

            for _,b in ipairs(buttons) do

                if x>=b.x and x<b.x+b.w
                and y2>=b.y and y2<b.y+b.h then

                    local result=b.fn()

                    if result~=nil then
                        return result
                    end

                    break
                end
            end
        end
    end
end

-- =========================================================
-- LOGIN
-- =========================================================

local function login()

    while true do

        clear()

        center("BOREALIS OS",2)
        center("CONNEXION",4)

        if not server then

            center("Recherche serveur...",7)

            if not findServer() then

                clear()
                center("SERVEUR INTROUVABLE",4)

                if monitor then
                    center("TOUCHEZ L'ECRAN",8)
                    os.pullEvent("monitor_touch")
                else
                    center("APPUYEZ SUR UNE TOUCHE",8)
                    os.pullEvent("key")
                end

            end

        else

            local username=input(
                "UTILISATEUR",
                false
            )

            local password=input(
                "MOT DE PASSE",
                true
            )

            rednet.send(
                server,
                {
                    action="login",
                    username=username,
                    password=password
                },
                "borealis"
            )

            local sender,msg=
                rednet.receive(
                    "borealis",
                    5
                )

            if sender==server
            and type(msg)=="table"
            and msg.action=="login_result" then

                if msg.success then

                    user=username
                    role=msg.result

                    return true

                else

                    clear()

                    center(
                        "CONNEXION REFUSEE",
                        4
                    )

                    center(
                        msg.result,
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
                end

            else
                server=nil
            end
        end
    end
end

-- =========================================================
-- TACHES
-- =========================================================

local function tasks()

    buttons={}
    clear()

    center("TACHES",2)
    center("Aucune tache.",5)

    addButton(
        "RETOUR",
        2,
        height-3,
        math.min(20,width-2),
        2,
        home
    )
end

-- =========================================================
-- RAPPORTS
-- =========================================================

local function reports()

    buttons={}
    clear()

    center("RAPPORTS",2)
    center("Aucun rapport.",5)

    addButton(
        "RETOUR",
        2,
        height-3,
        math.min(20,width-2),
        2,
        home
    )
end

-- =========================================================
-- ENVOI CREATION COMPTE
-- =========================================================

local function createSend(
    username,
    password,
    newRole
)

    rednet.send(
        server,
        {
            action="create_account",
            requester=user,
            username=username,
            password=password,
            role=newRole
        },
        "borealis"
    )

    local sender,msg=
        rednet.receive(
            "borealis",
            5
        )

    clear()

    if sender==server
    and type(msg)=="table" then

        center(
            msg.result,
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

local function chooseRole(
    username,
    password
)

    buttons={}
    clear()

    center(
        "CHOISIR LE ROLE",
        2
    )

    local w=math.min(
        22,
        width-2
    )

    local x=math.floor(
        (width-w)/2
    )+1

    addButton(
        "USER",
        x,
        5,
        w,
        2,
        function()
            createSend(
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
        w,
        2,
        function()
            createSend(
                username,
                password,
                "admin"
            )
        end
    )

    if role=="root" then

        addButton(
            "ROOT",
            x,
            13,
            w,
            2,
            function()
                createSend(
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
        height-3,
        w,
        2,
        accounts
    )

    waitTouch()
end

-- =========================================================
-- CREATION COMPTE
-- =========================================================

local function createAccount()

    local username=input(
        "NOUVEAU NOM",
        false
    )

    local password=input(
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

        if role=="root" then
            center(
                "3 = ROOT",
                9
            )
        end

        local e,key=os.pullEvent("key")

        if key==keys.one then

            createSend(
                username,
                password,
                "user"
            )

        elseif key==keys.two then

            createSend(
                username,
                password,
                "admin"
            )

        elseif key==keys.three
        and role=="root" then

            createSend(
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
-- LISTE COMPTES
-- =========================================================

local function listAccounts()

    rednet.send(
        server,
        {
            action="list_accounts",
            requester=user
        },
        "borealis"
    )

    local sender,msg=
        rednet.receive(
            "borealis",
            5
        )

    buttons={}
    clear()

    center(
        "COMPTES",
        2
    )

    if sender==server
    and type(msg)=="table"
    and msg.success then

        local y=4

        for _,account in
            ipairs(msg.accounts) do

            if y<height-4 then

                text(
                    account.username..
                    " : ".
                    ..account.role,
                    2,
                    y
                )

                y=y+1
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
        height-3,
        math.min(20,width-2),
        2,
        accounts
    )

    waitTouch()
end

-- =========================================================
-- COMPTES
-- =========================================================

function accounts()

    buttons={}
    clear()

    center(
        "GESTION DES COMPTES",
        2
    )

    local w=math.min(
        22,
        width-2
    )

    local x=math.floor(
        (width-w)/2
    )+1

    addButton(
        "CREER COMPTE",
        x,
        6,
        w,
        2,
        createAccount
    )

    addButton(
        "LISTE COMPTES",
        x,
        10,
        w,
        2,
        listAccounts
    )

    addButton(
        "RETOUR",
        x,
        height-3,
        w,
        2,
        home
    )

    waitTouch()
end

-- =========================================================
-- ACCUEIL
-- =========================================================

function home()

    buttons={}
    clear()

    center(
        "BOREALIS OS",
        2
    )

    center(
        "Bienvenue "..user,
        4
    )

    center(
        "Role : "..role,
        6
    )

    local w=math.min(
        22,
        width-2
    )

    local x=math.floor(
        (width-w)/2
    )+1

    addButton(
        "TACHES",
        x,
        8,
        w,
        2,
        tasks
    )

    addButton(
        "RAPPORTS",
        x,
        11,
        w,
        2,
        reports
    )

    local y=14

    if role=="admin"
    or role=="root" then

        addButton(
            "COMPTES",
            x,
            y,
            w,
            2,
            accounts
        )

        y=y+3
    end

    addButton(
        "DECONNEXION",
        x,
        y,
        w,
        2,
        function()

            user=nil
            role=nil
            server=nil

            login()
            home()

        end
    )

    waitTouch()
end

-- =========================================================
-- DEMARRAGE
-- =========================================================

if login() then
    home()
end