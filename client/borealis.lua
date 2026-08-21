local basalt = dofile("basalt.lua")

local monitor = peripheral.find("monitor")

if not monitor then
    error("Aucun monitor détecté !")
end

local width, height = monitor.getSize()

local function newFrame()
    local frame = basalt.createFrame()
    frame:setTerm(monitor)
    frame:setBackground(colors.black)
    return frame
end

local frame = newFrame()

local function button(text, x, y, w, h, action)

    local b = frame:addButton()

    b:setText(text)
    b:setPosition(x, y)
    b:setSize(w, h)

    b:onClick(action)

    return b
end

local function home()

    frame = newFrame()

    local title = frame:addLabel()
    title:setText("BOREALIS OS")
    title:setPosition(2, 1)

    local status = frame:addLabel()
    status:setText("SERVEUR : ONLINE")
    status:setPosition(2, 3)
    status:setForeground(colors.lime)

    local w = math.floor((width - 6) / 2)

    button("TACHES", 2, 6, w, 3, function()
        tasks()
    end)

    button("EMPLOYES", w + 4, 6, w, 3, function()
        employees()
    end)

    button("RAPPORTS", 2, 11, w, 3, function()
        reports()
    end)

    button("MUSIQUE", w + 4, 11, w, 3, function()
        music()
    end)

    button("ADMIN", 2, 16, w, 3, function()
        admin()
    end)

end

function tasks()

    frame = newFrame()

    local title = frame:addLabel()
    title:setText("TACHES")
    title:setPosition(2, 1)

    local text = frame:addLabel()
    text:setText("Aucune tache pour le moment.")
    text:setPosition(2, 4)

    button("RETOUR", 2, height - 3, 12, 2, home)

end

function employees()

    frame = newFrame()

    local title = frame:addLabel()
    title:setText("EMPLOYES")
    title:setPosition(2, 1)

    local text = frame:addLabel()
    text:setText("Aucun employe connecte.")
    text:setPosition(2, 4)

    button("RETOUR", 2, height - 3, 12, 2, home)

end

function reports()

    frame = newFrame()

    local title = frame:addLabel()
    title:setText("RAPPORTS")
    title:setPosition(2, 1)

    local text = frame:addLabel()
    text:setText("Aucun rapport.")
    text:setPosition(2, 4)

    button("RETOUR", 2, height - 3, 12, 2, home)

end

function music()

    frame = newFrame()

    local title = frame:addLabel()
    title:setText("MUSIQUE")
    title:setPosition(2, 1)

    local text = frame:addLabel()
    text:setText("Aucune musique.")
    text:setPosition(2, 4)

    button("LECTURE", 2, 7, 12, 3, function()
        print("Lecture")
    end)

    button("STOP", 16, 7, 12, 3, function()
        print("Stop")
    end)

    button("RETOUR", 2, height - 3, 12, 2, home)

end

function admin()

    frame = newFrame()

    local title = frame:addLabel()
    title:setText("ADMINISTRATION")
    title:setPosition(2, 1)
    title:setForeground(colors.red)

    button("CREER TACHE", 2, 5, 20, 3, function()
        print("Creation d'une tache")
    end)

    button("EMPLOYES", 2, 10, 20, 3, function()
        print("Gestion des employes")
    end)

    button("RETOUR", 2, height - 3, 12, 2, home)

end

home()

basalt.run()