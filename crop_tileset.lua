--------------------------------------------------------------------------------
-- Header
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

-- https://github.com/klaleus/script-crop-tileset

-- luajit crop_tileset.lua <image_path> <format_path> [<destination_path>]

--------------------------------------------------------------------------------

if not arg[3] then
    arg[3] = "./"
elseif arg[3]:sub(-1) ~= "/" then
    arg[3] = arg[3] .. "/"
end

-- arg[1] -> "example/tileset.png"
-- arg[2] -> "example/tileset.fmt"
-- arg[3] -> "./"

local magick = require("magick")

local format, err = io.open(arg[2], "r")
assert(format, err)

local lines = {}

for line in format:lines() do
    lines[#lines + 1] = line
end

format:close()

local tile_count = 0

local tile_scaling_factor = tonumber(lines[1]:match("base (%d+)"))

local tile_x = 0
local tile_y = 0
local tile_width = 1
local tile_height = 1

local function crop(axis, cmd_args)
    local current_tile_count = 0
    for tile_name in cmd_args:gmatch("%S+") do
        local pixel_x_start = (tile_x - 1) * tile_scaling_factor
        local pixel_y_start = (tile_y - 1) * tile_scaling_factor
        local pixel_x_iteration = axis == "x" and current_tile_count * tile_width * tile_scaling_factor or 0
        local pixel_y_iteration = axis == "y" and current_tile_count * tile_height * tile_scaling_factor or 0
        local pixel_x = pixel_x_start + pixel_x_iteration
        local pixel_y = pixel_y_start + pixel_y_iteration
        local pixel_width = tile_width * tile_scaling_factor
        local pixel_height = tile_height * tile_scaling_factor

        local thumb_str = pixel_width .. "x" .. pixel_height .. "+" .. pixel_x .. "+" .. pixel_y
        print("Cropping " .. tile_name .. " (x = " .. pixel_x .. ", y = " .. pixel_y .. ", width = " .. pixel_width .. ", height = " .. pixel_height .. ")...")
        local file_path = arg[3] .. tile_name .. ".png"
        local success = magick.thumb(arg[1], thumb_str, file_path)
        assert(success, "Failed to crop to '" .. file_path .. "'")

        current_tile_count = current_tile_count + 1
        tile_count = tile_count + 1
    end
end

for i = 2, #lines do
    local line = lines[i]
    local cmd, cmd_args = line:match("(%l+) (.+)")

    if cmd == "select" then
        local tile_x_str, tile_y_str, tile_width_str, tile_height_str = cmd_args:match("(%d+) (%d+) (%d+) (%d+)")
        tile_x, tile_y, tile_width, tile_height = tonumber(tile_x_str), tonumber(tile_y_str), tonumber(tile_width_str), tonumber(tile_height_str)

    elseif cmd == "cropx" then
        crop("x", cmd_args)

    elseif cmd == "cropy" then
        crop("y", cmd_args)
    end
end

print("Successfully cropped " .. tile_count .. " tiles.")
