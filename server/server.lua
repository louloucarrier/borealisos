```lua
local modem = peripheral.find("modem")

if not modem then
    error("Aucun modem detecte")
end

local modemSide = peripheral.getName(modem)

rednet.open(modemSide)

local DATABASE = "accounts.db"

local accounts = {}

-- =========================================================
-- SAUVEGARDE
-- =========================================================

local function saveAccounts()
    local file = fs.open(DATABASE, "w")

    if not file then
        error("Impossible d'ouvrir accounts.db")
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
                password = "1234",
                role = "root"
            }
        }

        saveAccounts()

        print("")
        print("==============================")
        print("      BOREALIS SERVER")
        print("==============================")
        print("")
        print("Compte root cree")
        print("")
        print("Utilisateur : root")
        print("Mot de passe : 1234")
        print("")
        print("==============================")
        print("")

        return
    end

    local file = fs.open(DATABASE, "r")

    if not file then
        error("Impossible de lire accounts.db")
    end

    local data = file.readAll()

    file.close()

    accounts = textutils.unserialize(data)

    if not accounts then
        error("accounts.db est corrompu")
    end

    -- Protection : s'assurer que root existe
    if not accounts.root then
        accounts.root = {
            password = "1234",
            role = "root"
        }

        saveAccounts()

        print("Compte root recree.")
    end
end

-- =========================================================
-- CONNEXION
-- =========================================================

local function login(username, password)

    if type(username) ~= "string"
    or type(password) ~= "string" then

        return false, "Donnees invalides"
    end

    local account = accounts[username]

    if not account then
        return false, "Compte inexistant"
    end

    if account.password ~= password then
        return false, "Mot de passe incorrect"
    end

    return true, account.role
end

-- =========================================================
-- CREATION DE COMPTE
-- =========================================================

local function createAccount(
    username,
    password,
    role
)

    if type(username) ~= "string"
    or username == "" then

        return false, "Nom invalide"
    end

    if type(password) ~= "string"
    or password == "" then

        return false, "Mot de passe invalide"
    end

    if accounts[username] then
        return false, "Compte deja existant"
    end

    if role ~= "user"
    and role ~= "admin"
    and role ~= "root" then

        return false, "Role invalide"
    end

    accounts[username] = {
        password = password,
        role = role
    }

    saveAccounts()

    return true, "Compte cree"
end

-- =========================================================
-- CHARGEMENT DATABASE
-- =========================================================

loadAccounts()

-- =========================================================
-- DEMARRAGE SERVEUR
-- =========================================================

print("==============================")
print("      BOREALIS SERVER")
print("==============================")
print("")
print("Modem : " .. modemSide)
print("ID : " .. os.getComputerID())
print("")
print("Serveur pret")
print("")
print("Permissions :")
print("USER  -> aucune creation")
print("ADMIN -> USER + ADMIN")
print("ROOT  -> USER + ADMIN + ROOT")
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
                    action = "login_result",
                    success = success,
                    result = result
                },
                "borealis"
            )

        -- =================================================
        -- CREATION COMPTE
        -- =================================================

        elseif message.action ==
            "create_account" then

            local requester =
                accounts[
                    message.requester
                ]

            -- Demandeur inconnu
            if not requester then

                rednet.send(
                    sender,
                    {
                        action = "create_result",
                        success = false,
                        result = "Demandeur inconnu"
                    },
                    "borealis"
                )

            -- USER interdit
            elseif requester.role == "user" then

                rednet.send(
                    sender,
                    {
                        action = "create_result",
                        success = false,
                        result = "Acces refuse"
                    },
                    "borealis"
                )

            -- Role demande invalide
            elseif message.role ~= "user"
            and message.role ~= "admin"
            and message.role ~= "root" then

                rednet.send(
                    sender,
                    {
                        action = "create_result",
                        success = false,
                        result = "Role invalide"
                    },
                    "borealis"
                )

            -- ADMIN ne peut pas creer ROOT
            elseif message.role == "root"
            and requester.role ~= "root" then

                rednet.send(
                    sender,
                    {
                        action = "create_result",
                        success = false,
                        result =
                            "Seul root peut creer root"
                    },
                    "borealis"
                )

            -- ADMIN ou ROOT autorise
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
                        action = "create_result",
                        success = success,
                        result = result
                    },
                    "borealis"
                )
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
                            username = username,
                            role = account.role
                        }
                    )
                end

                rednet.send(
                    sender,
                    {
                        action =
                            "accounts_result",

                        success = true,

                        accounts = list
                    },
                    "borealis"
                )

            else

                rednet.send(
                    sender,
                    {
                        action =
                            "accounts_result",

                        success = false,

                        result = "Acces refuse"
                    },
                    "borealis"
                )
            end
        end
    end
end
```
