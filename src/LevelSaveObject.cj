package Columns

import std.collection.*

struct LevelSaveObject {
    var state = LevelStateObject()
    var boardJewels = ArrayList<Jewel>()
    var players = ArrayList<LevelPlayer>()
    var playerIdx = 0
    var hasFlash = false
}
