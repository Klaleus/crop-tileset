--------------------------------------------------------------------------------
-- License
--------------------------------------------------------------------------------

-- Copyright (c) 2025 Klaleus
--
-- This software is provided "as-is", without any express or implied warranty.
-- In no event will the authors be held liable for any damages arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose, including commercial applications,
-- and to alter it and redistribute it freely, subject to the following restrictions:
--
--     1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
--        If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
--
--     2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
--
--     3. This notice may not be removed or altered from any source distribution.

--------------------------------------------------------------------------------

-- GitHub: https://github.com/klaleus/crop-tileset

-- Usage: luajit crop_tileset.lua <source> <destination> <format>

--------------------------------------------------------------------------------

if arg[2]:sub(-1) ~= "/" then
    arg[2] = arg[2] .. "/"
end

-- Example: luajit crop_tileset.lua example/tileset.png ./ example/tileset.fmt
-- arg[1] -> "example/tileset.png"
-- arg[2] -> "./"
-- arg[3] -> "example/tileset.fmt"

-- https://github.com/libvips/lua-vips
-- lua-vips seems to throw its own errors, so no need to assert against it.
local vips = require("vips")

local tileset = vips.Image.new_from_file(arg[1])

local format, err = io.open(arg[3], "r")
assert(format, err)

local lines = {}

for line in format:lines() do
    lines[#lines + 1] = line
end

format:close()

local tile_count = 0

local tile_size_x = 8
local tile_size_y = 8
local tile_padding_x = 0
local tile_padding_y = 0
local tileset_margin_x = 0
local tileset_margin_y = 0

local tile_x = 1
local tile_y = 1
local tile_width = 1
local tile_height = 1

local function crop(axis, cmd_args)
    local current_tile_count = 0

    local pixel_x_start = tileset_margin_x + (tile_x - 1) * tile_size_x + (tile_x - 1) * tile_padding_x
    local pixel_y_start = tileset_margin_y + (tile_y - 1) * tile_size_y + (tile_y - 1) * tile_padding_y
    local pixel_width = tile_width * tile_size_x
    local pixel_height = tile_height * tile_size_y

    for tile_name in cmd_args:gmatch("%S+") do
        local pixel_x_iteration = axis == "x" and current_tile_count * tile_width * tile_size_x + current_tile_count * tile_padding_x or 0
        local pixel_y_iteration = axis == "y" and current_tile_count * tile_height * tile_size_y + current_tile_count * tile_padding_y or 0
        local pixel_x = pixel_x_start + pixel_x_iteration
        local pixel_y = pixel_y_start + pixel_y_iteration

        print("Cropping " .. tile_name .. " (x = " .. pixel_x .. ", y = " .. pixel_y .. ", width = " .. pixel_width .. ", height = " .. pixel_height .. ")...")
        local file_path = arg[2] .. tile_name .. ".png"
        local tile = tileset:crop(pixel_x, pixel_y, pixel_width, pixel_height)
        tile:write_to_file(file_path)

        current_tile_count = current_tile_count + 1
        tile_count = tile_count + 1
    end
end

for i = 1, #lines do
    local line = lines[i]
    local cmd, cmd_args = line:match("(%l+) (.+)")

    if cmd == "sizex" then
        tile_size_x = tonumber(cmd_args:match("%d+"))

    elseif cmd == "sizey" then
        tile_size_y = tonumber(cmd_args:match("%d+"))

    elseif cmd == "size" then
        print("Command `size` does not exist. Did you mean `sizex` or `sizey`?")

    elseif cmd == "paddingx" then
        tile_padding_x = tonumber(cmd_args:match("%d+"))

    elseif cmd == "paddingy" then
        tile_padding_y = tonumber(cmd_args:match("%d+"))

    elseif cmd == "padding" then
        print("Command `padding` does not exist. Did you mean `paddingx` or `paddingy`?")

    elseif cmd == "marginx" then
        tileset_margin_x = tonumber(cmd_args:match("%d+"))

    elseif cmd == "marginy" then
        tileset_margin_y = tonumber(cmd_args:match("%d+"))

    elseif cmd == "margin" then
        print("Command `margin` does not exist. Did you mean `marginx` or `marginy`?")

    elseif cmd == "select" then
        local tile_x_str, tile_y_str, tile_width_str, tile_height_str = cmd_args:match("(%d+) (%d+) (%d+) (%d+)")
        tile_x, tile_y, tile_width, tile_height = tonumber(tile_x_str), tonumber(tile_y_str), tonumber(tile_width_str), tonumber(tile_height_str)

    elseif cmd == "cropx" then
        crop("x", cmd_args)

    elseif cmd == "cropy" then
        crop("y", cmd_args)

    elseif cmd == "crop" then
        print("Command `crop` does not exist. Did you mean `cropx` or `cropy`?")
    end

    -- Lines that do not start with any of the above commands are ignored.
    -- This is useful for comments and whitespace.
end

print("Successfully cropped " .. tile_count .. " tiles.")
