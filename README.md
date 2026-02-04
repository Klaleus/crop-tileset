# crop_tileset.lua

Lua script that crops a tileset into individual tiles.

## Installation

Install libvips, a C library that performs image-related operations:  
https://github.com/libvips/libvips

Install lua-vips, a Lua binding to libvips:  
https://github.com/libvips/lua-vips

Finally, download or clone this repository.

## Usage

```
$ luajit crop_tileset.lua <source> <destination> <format>
```

1. `source` Relative path to the tileset image.
2. `destination` Relative path to the destination directory where the cropped tiles are placed.
3. `format` Relative path to the format file, which defines how to crop the tileset.

Only PNG images are supported.

## Example

```
$ luajit crop_tileset.lua example/tileset.png ./ example/tileset.fmt
```

<img width="240" height="160" alt="tileset.png" src="https://github.com/user-attachments/assets/545097a9-36ad-4c00-806e-3be993ba7b15" />

```
-- example/tileset.fmt

sizex 8
sizey 8

paddingx 0
paddingy 0

marginx 0
marginy 0

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

* `sizex <x>` Defines the width of subsequent `select` operations. Default is `sizex 8`.
* `sizey <y>` Defines the height of subsequent `select` operations. Default is `sizey 8`.
* `paddingx <x>` Defines the padding width between each tile. Default is `paddingx 0`.
* `paddingy <y>` Defines the padding height between each tile. Default is `paddingy 0`.
* `marginx <x>` Defines the margin width of the source tileset. Default is `marginx 0`.
* `marginy <y>` Defines the margin height of the source tileset. Default is `marginy 0`.
* `select <x> <y> <width> <height>` Selects the starting tileset position of the next crop operation. Arguments are relative to the `base` tile size. Coordinates `x = 1` and `y = 1` correspond to the top-left of the tileset.
* `cropx <tile_name> ...` Crops sequential tiles horizontally.
* `cropy <tile_name> ...` Crops sequential tiles vertically.

Faulty arguments to these commands are not protected against and will result in undefined behavior. Lines that do not start with one of the above commands are ignored.

Executing the above example would result in the following output:

```
$ luajit crop_tileset.lua example/tileset.png ./ example/tileset.fmt

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
$ ls *.png

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
