local modem = peripheral.find("modem")

if not modem then
    error("Aucun modem détecté !")
end

rednet.open(peripheral.getName(modem))

print("================================")
print("       BOREALIS SERVER")
print("================================")
print("")
print("Status : ONLINE")
print("Serveur prêt.")
print("")
print("En attente de clients...")
print("================================")

while true do
    local id, message, protocol = rednet.receive("borealis")

    print("")
    print("Client : " .. id)
    print("Message : " .. tostring(message))
    print("Protocol : " .. tostring(protocol))

    if message == "ping" then
        rednet.send(id, "pong", "borealis")
        print("Réponse envoyée.")
    end
end