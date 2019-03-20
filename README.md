## Letters: A mod for Minetest! ##
### Fork by GreenXenith/GreenDimond ###

#### Changes ####
* Includes number cutter
* New cutters could be added with ease (non-latin?)
* Simplified registration

> The majority of this code was taken (and altered significantly) from Calinou's [Moreblocks mod](https://forum.minetest.net/viewtopic.php?t=509). It is designed to add letters in all different materials. Code is licensed under the zlib license, textures under the CC BY-SA license.
>
>The Letter Cutter textures use parts of the default wood and tree textures made by Blockmen and Cisoun respectively.

## Allowing letters to be made from nodes: ##

Use this code to allow blocks to have letters registered from them:
```lua
letters.register_letters(nodename[, extra_def, extra_groups])
```
`nodename` is the node you wish to cut.
`extra_def` and `extra_groups` will be set in the cut characters' def/groups respectively.


