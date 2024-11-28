local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

-- Track active movies and shows
local activeMovies = {}
local activeShows = {}

exports.vorp_inventory:registerUsableItem("cinema_ticket", function(data)
    local source = data.source
    local ticket = data.item
    
    if ticket.metadata and ticket.metadata.show and ticket.metadata.location then
        if Config.Movies[ticket.metadata.show] and Config.Projections[ticket.metadata.location] then
            -- Check if movie is already playing
            if activeMovies[ticket.metadata.location] then
                VORPcore.NotifyRightTip(source, "A movie is already playing at this location", 4000)
                return
            end
            
            -- Mark movie as active
            activeMovies[ticket.metadata.location] = {
                show = ticket.metadata.show,
                startTime = os.time(),
                displayActive = true -- Add display state tracking
            }
            
            -- Sync movie start and display state to all players
            TriggerClientEvent("jkt_cinema:startMovie", -1, ticket.metadata.show, ticket.metadata.location)
            TriggerClientEvent("jkt_cinema:syncMovieState", -1, ticket.metadata.location, ticket.metadata.show, true)
            TriggerClientEvent("jkt_cinema:syncDisplayState", -1, ticket.metadata.location, true) -- Sync display state
        elseif Config.Shows[ticket.metadata.show] then
            -- Check if show is already playing
            if activeShows[ticket.metadata.show] then
                VORPcore.NotifyRightTip(source, "This show is already playing", 4000)
                return
            end
            
            -- Mark show as active
            activeShows[ticket.metadata.show] = {
                startTime = os.time(),
                displayActive = true -- Add display state tracking
            }
            
            -- Sync show start and display state to all players
            TriggerClientEvent("jkt_cinema:startMovie", -1, ticket.metadata.show)  
            TriggerClientEvent("jkt_cinema:syncShowState", -1, ticket.metadata.show, true)
            TriggerClientEvent("jkt_cinema:syncDisplayState", -1, ticket.metadata.show, true) -- Sync display state
        end
        exports.vorp_inventory:subItem(source, "cinema_ticket", 1, ticket.metadata)
    end
end)

RegisterServerEvent('jkt_cinema:buyTicket')
AddEventHandler('jkt_cinema:buyTicket', function(show, location)
    local source = source
    local Character = VORPcore.getUser(source).getUsedCharacter
    local price = Config.Prices[show] or Config.Prices.default -- Get price from config

    if Character.money >= price then
        Character.removeCurrency(0, price)
        
        local metadata = {
            show = show,
            location = location,
            description = "Movie ticket for " .. show,
            expiry = os.time() + (24 * 60 * 60)
        }
        
        exports.vorp_inventory:addItem(source, "cinema_ticket", 1, metadata)
        VORPcore.NotifyRightTip(source, "Ticket purchased for " .. show .. " ($" .. price .. ")", 4000)
    else
        VORPcore.NotifyRightTip(source, "Not enough money", 4000)
    end
end)

-- Events to sync movie/show state between players
RegisterServerEvent("jkt_cinema:syncMovieState") 
AddEventHandler("jkt_cinema:syncMovieState", function(projection, movie, isStarting)
    if isStarting then
        activeMovies[projection] = {
            show = movie,
            startTime = os.time(),
            displayActive = true -- Add display state tracking
        }
    else
        activeMovies[projection] = nil
    end
    TriggerClientEvent("jkt_cinema:syncMovieState", -1, projection, movie, isStarting)
    TriggerClientEvent("jkt_cinema:syncDisplayState", -1, projection, isStarting) -- Sync display state
end)

RegisterServerEvent("jkt_cinema:syncShowState")
AddEventHandler("jkt_cinema:syncShowState", function(show, isStarting)
    if isStarting then
        activeShows[show] = {
            startTime = os.time(),
            displayActive = true -- Add display state tracking
        }
    else
        activeShows[show] = nil
    end
    TriggerClientEvent("jkt_cinema:syncShowState", -1, show, isStarting)
    TriggerClientEvent("jkt_cinema:syncDisplayState", -1, show, isStarting) -- Sync display state
end)