# crop_tileset.lua

Lua script that crops a tileset into individual tiles.

Please click the ☆ button on GitHub if this repository is useful. Thank you!

## Installation

Install LuaJIT. Magick, another dependency, requires LuaJIT over interpretted Lua:  
https://luajit.org/install.html

Install Magick via LuaRocks. It offers Lua bindings to a popular C library called ImageMagick, which performs image-related operations:  
https://github.com/leafo/magick

Finally, download or clone this repository.

## Usage

```
$ luajit crop_tileset.lua <tileset_path> <format_path> [<destination_path>]
```

Three parameters are available:

1. `tileset_path` Relative path to the tileset image.
2. `format_path` Relative path to the format file, which defines how to crop the tileset.
3. `[destination_path]` Relative path to the destination directory where the cropped tiles are placed. If omitted, then `./` is used.

Only `.png` images are supported.

## Example

The example project can be tested with the following command:

```
$ luajit crop_tileset.lua example/tileset.png example/tileset.fmt
```

* The tileset `example/tileset.png` is 48 x 32 pixels, where the smallest tile is 8 x 8 pixels. It contains three large trees, three tall trees, two flowers, and one sign.
* The format file `example/tileset.fmt` defines how the script should crop each tile.
* The resulting images are placed into the current working directory `./` because a destination directory was omitted as a third argument.

<img width="240" height="160" alt="tileset-1 png (2)" src="https://github.com/user-attachments/assets/545097a9-36ad-4c00-806e-3be993ba7b15" />

```
base 8

select 1 1 2 2
cropx tree_large_red tree_large_green tree_large_blue

select 1 3 1 2
cropx tree_tall_red tree_tall_green tree_tall_blue

select 4 3 1 1
cropy flower_small_red flower_small_blue

select 5 3 1 1
cropx sign
```

Format files are kept as simple as possible with minimal commands:

* `base <size>` Defines the width and height of the smallest tile. The first line must contain this command.
* `select <x> <y> <width> <height>` Selects the starting tile of the next crop operation. Arguments are relative to the `base` tile size. Coordinates `x = 1` and `y = 1` correspond to the top-left of the tileset.
* `cropx <tile_name> ...` Crops sequential tiles horizontally. The amount of crops is determined by how many `tile_name` arguments are passed.
* `cropy <tile_name> ...` Crops sequential tiles vertically. The amount of crops is determined by how many `tile_name` arguments are passed.

Faulty arguments to these commands are not protected against and will result in undefined behavior.

Executing the above example would result in the following output:

```
$ luajit crop_tileset.lua example/tileset.png example/tileset.fmt
Cropping tree_large_red (x = 0, y = 0, width = 16, height = 16)...
Cropping tree_large_green (x = 16, y = 0, width = 16, height = 16)...
Cropping tree_large_blue (x = 32, y = 0, width = 16, height = 16)...
Cropping tree_tall_red (x = 0, y = 16, width = 8, height = 16)...
Cropping tree_tall_green (x = 8, y = 16, width = 8, height = 16)...
Cropping tree_tall_blue (x = 16, y = 16, width = 8, height = 16)...
Cropping flower_small_red (x = 24, y = 16, width = 8, height = 8)...
Cropping flower_small_blue (x = 24, y = 24, width = 8, height = 8)...
Cropping sign (x = 32, y = 16, width = 8, height = 8)...
Successfully cropped 9 tiles.
```

```
// Cropped images under the current working directory.
./tree_large_red.png
./tree_large_green.png
./tree_large_blue.png
./tree_tall_red.png
./tree_tall_green.png
./tree_tall_blue.png
./flower_small_red.png
./flower_small_blue.png
./sign.png
```
