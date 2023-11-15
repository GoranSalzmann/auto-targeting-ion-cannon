local function get_current_surface()
    local surfaces = game.surfaces
    return surfaces[(game.tick % #surfaces) + 1]
end

local function find_target(surface)
    local chunk_position = surface.get_random_chunk()
    if chunk_position ~= nil then
        local nearest_enemy = surface.find_nearest_enemy({
            position = { x = chunk_position.x * 32, y = chunk_position.y * 32 },
            max_distance = settings.global["auto-targeting-ion-cannon-range"].value,
            force = game.forces["player"]
        })
        return nearest_enemy
    else
        return nil
    end
end

local function shoot(surface)
    local nearest_enemy = find_target(surface)
    if nearest_enemy ~= nil then
        remote.call("orbital_ion_cannon", "target_ion_cannon",
            game.forces["player"], nearest_enemy.position, surface, nil)
    end
end

local function shoot_many(surface)
    for _ = 1, settings.global["auto-targeting-ion-cannon-count"].value, 1 do
        shoot(surface)
    end
end

local function do_tick()
    local surface = get_current_surface()
    shoot_many(surface)
end

script.on_nth_tick(settings.startup["auto-targeting-ion-cannon-interval"].value,
    function()
        if settings.global["auto-targeting-ion-cannon-enabled"].value then
            do_tick()
        end
    end
)
