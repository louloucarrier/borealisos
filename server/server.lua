-- =========================================================
-- BOREALIS OS - SERVEUR
-- =========================================================

local modem = peripheral.find("modem")

if not modem then
    error("Aucun modem detecte !")
end

local modemSide = peripheral.getName(modem)

rednet.open(modemSide)

local DATABASE = "accounts.db"

local accounts = {}

-- =========================================================
-- HASH
-- =========================================================

local function hashPassword(password)
    return textutils.sha256(password)
end

-- =========================================================
-- SAUVEGARDE
-- =========================================================

local function saveAccounts()

    local file = fs.open(DATABASE, "w")

    if not file then
        error("Impossible d'ouvrir la base de donnees")
    end

    file.write(
        textutils.serialize(accounts)
    )

    file.close()

end

-- =========================================================
-- CHARGEMENT
-- =========================================================

local function loadAccounts()

    if not fs.exists(DATABASE) then

        accounts = {

            root = {

                password =
                    hashPassword("CHANGE-MOI"),

                role = "root"

            }

        }

        saveAccounts()

        print("")
        print("================================")
        print("       BOREALIS SERVER")
        print("================================")
        print("")
        print("COMPTE ROOT CREE")
        print("")
        print("Utilisateur : root")
        print("Mot de passe : CHANGE-MOI")
        print("")
        print("CHANGE CE MOT DE PASSE !")
        print("")
        print("================================")
        print("")

        return

    end

    local file =
        fs.open(DATABASE, "r")

    if not file then
        error("Impossible de lire accounts.db")
    end

    local data =
        file.readAll()

    file.close()

    accounts =
        textutils.unserialize(data)

    if not accounts then
        error("Base de comptes corrompue !")
    end

end

-- =========================================================
-- LOGIN
-- =========================================================

local function login(
    username,
    password
)

    local account =
        accounts[username]

    if not account then

        return false,
            "Compte inexistant"

    end

    if account.password ~= password then

        return false,
            "Mot de passe incorrect"

    end

    return true,
        account.role

end

-- =========================================================
-- CREATION COMPTE
-- =========================================================

local function createAccount(
    username,
    password,
    role
)

    if not username
    or username == "" then

        return false,
            "Nom invalide"

    end

    if not password
    or password == "" then

        return false,
            "Mot de passe invalide"

    end

    if accounts[username] then

        return false,
            "Ce compte existe deja"

    end

    if role ~= "user"
    and role ~= "admin"
    and role ~= "root" then

        return false,
            "Role invalide"

    end

    accounts[username] = {

        password =
            hashPassword(password),

        role = role

    }

    saveAccounts()

    return true,
        "Compte cree"

end

-- =========================================================
-- DEMARRAGE
-- =========================================================

loadAccounts()

print("================================")
print("       BOREALIS SERVER")
print("================================")
print("")
print("Modem : " .. modemSide)
print("ID du serveur : " .. os.getComputerID())
print("")
print("Serveur pret.")
print("")

-- =========================================================
-- BOUCLE SERVEUR
-- =========================================================

while true do

    local sender,
          message,
          protocol =
        rednet.receive("borealis")

    if type(message) == "table" then

        -- =================================================
        -- PING
        -- =================================================

        if message.action == "ping" then

            rednet.send(
                sender,
                {
                    action = "server"
                },
                "borealis"
            )

        -- =================================================
        -- LOGIN
        -- =================================================

        elseif message.action == "login" then

            local success,
                  result =
                login(
                    message.username,
                    message.password
                )

            rednet.send(
                sender,
                {
                    action =
                        "login_result",

                    success =
                        success,

                    result =
                        result
                },
                "borealis"
            )

        -- =================================================
        -- CREER COMPTE
        -- =================================================

        elseif message.action ==
            "create_account" then

            local requester =
                accounts[
                    message.requester
                ]

            if not requester then

                rednet.send(
                    sender,
                    {
                        action =
                            "create_result",

                        success =
                            false,

                        result =
                            "Compte demandeur inconnu"
                    },
                    "borealis"
                )

            elseif requester.role ~= "root"
            and requester.role ~= "admin" then

                rednet.send(
                    sender,
                    {
                        action =
                            "create_result",

                        success =
                            false,

                        result =
                            "Acces refuse"
                    },
                    "borealis"
                )

            else

                -- =========================================
                -- SEUL ROOT PEUT CREER ROOT
                -- =========================================

                if message.role == "root"
                and requester.role ~= "root" then

                    rednet.send(
                        sender,
                        {
                            action =
                                "create_result",

                            success =
                                false,

                            result =
                                "Seul root peut creer un root"
                        },
                        "borealis"
                    )

                else

                    local success,
                          result =
                        createAccount(
                            message.username,
                            message.password,
                            message.role
                        )

                    rednet.send(
                        sender,
                        {
                            action =
                                "create_result",

                            success =
                                success,

                            result =
                                result
                        },
                        "borealis"
                    )

                end

            end

        -- =================================================
        -- LISTE DES COMPTES
        -- =================================================

        elseif message.action ==
            "list_accounts" then

            local requester =
                accounts[
                    message.requester
                ]

            if requester
            and (
                requester.role == "root"
                or requester.role == "admin"
            ) then

                local list = {}

                for username,
                    account in pairs(accounts) do

                    table.insert(
                        list,
                        {
                            username =
                                username,

                            role =
                                account.role
                        }
                    )

                end

                rednet.send(
                    sender,
                    {
                        action =
                            "accounts_result",

                        success =
                            true,

                        accounts =
                            list
                    },
                    "borealis"
                )

            else

                rednet.send(
                    sender,
                    {
                        action =
                            "accounts_result",

                        success =
                            false,

                        result =
                            "Acces refuse"
                    },
                    "borealis"
                )

            end

        end

    end

end