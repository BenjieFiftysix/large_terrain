 
 
--  NOISE THINGS
local bumps = nil
local heights = nil
local bump_size = nil
local height_size = nil
local land_height = nil

local function create_noise(size, seed)
    local _2d_shape = {x=size+2, y=size+2, 1}
    
    local bumps_def = {
        offset = 0,
        scale = 1,
        spread = {x = 320, y = 320, z = 320},  -- frequency - how fast it changes
        seed = 7342,
        octaves = 7,  -- higher = more details
        persist = 0.6
    }
    
    local heights_def = {
        offset = 0,
        scale = 1,
        spread = {x = 1024, y = 1024, z = 1024},  -- frequency - how fast it changes
        seed = -17265,
        octaves = 3,  -- higher = more details
        persist = 0.6
    }
    
    local bump_size_def = {
        offset = 0,
        scale = 1,
        spread = {x = 1024, y = 1024, z = 1024},  -- frequency - how fast it changes
        seed = 283740,
        octaves = 5,  -- higher = more details
        persist = 0.6
    }
    
    local hight_size_def = {
        offset = 0,
        scale = 1,
        spread = {x = 3000, y = 3000, z = 3000},  -- frequency - how fast it changes
        seed = 7342,
        octaves = 8,  -- higher = more details
        persist = 0.6
    }
    
    local land_height_def = {
        offset = 0,
        scale = 1,
        spread = {x = 10000, y = 10000, z = 10000},  -- frequency - how fast it changes
        seed = -659303,
        octaves = 1,  -- higher = more details
        persist = 0.6
    }
    
    bumps = minetest.get_perlin_map(bumps_def, _2d_shape)
    heights = minetest.get_perlin_map(heights_def, _2d_shape)
    bump_size = minetest.get_perlin_map(bump_size_def, _2d_shape)
    height_size = minetest.get_perlin_map(hight_size_def, _2d_shape)
    land_height = minetest.get_perlin_map(land_height_def, _2d_shape)
end


-- creating new mapchunk
minetest.register_on_generated(function(minp, maxp, seed)
    size = maxp.x-minp.x
    
    if heights == nil then
        create_noise(size, seed)
    end
    local area_bumps = bumps:get2dMap_flat({x=minp.x-1, y=minp.z-1})
    local area_heights = heights:get2dMap_flat({x=minp.x-1, y=minp.z-1})
    local area_bump_size = bump_size:get2dMap_flat({x=minp.x-1, y=minp.z-1})
    local area_height_size = height_size:get2dMap_flat({x=minp.x-1, y=minp.z-1})
    local area_land_height = land_height:get2dMap_flat({x=minp.x-1, y=minp.z-1})
    
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
    local data = vm:get_data()
    
    local height_pos = 1
    
    for z = minp.z-1, maxp.z do
        for y = minp.y, maxp.y do
            for x = minp.x-1, maxp.x do
                
                local pos = area:index(x, y, z)
                
                local bump_area_multiplier = area_bump_size[height_pos]
                if bump_area_multiplier < -0.5 then
                    --bump_area_multiplier = bump_area_multiplier/4
                end
                height = area_heights[height_pos]*(area_height_size[height_pos]*300)+area_bumps[height_pos]*(bump_area_multiplier*50)+((area_land_height[height_pos]+1)*1000)
                
                --height = area_heightmap[height_pos]*255
                
                --
                if y < height-1 then
                    data[pos] = minetest.get_content_id("default:dirt")
                elseif y < height then
                    data[pos] = minetest.get_content_id("default:dirt_with_grass")
                    
                else
                    data[pos] = minetest.get_content_id("air")
                end
                --
                
                height_pos = height_pos+1
            end
            height_pos = height_pos - (size+2)
        end
        height_pos = height_pos + (size+2)
    end
    
    vm:set_data(data)
    vm:calc_lighting()
    vm:write_to_map(data)
    vm:update_liquids()
    
end)
