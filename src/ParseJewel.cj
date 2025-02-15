package Columns

import cjsfml.system.*
import dgengine.*
import encoding.json.*
import std.math.*

func parseJewel(game: Game, elem: JsonValue): Unit {
    if (let Some(level) <- game.resources.getLevel<Level>(getStringCharKey(elem, "level"))) {
        if (let Some(id) <- getValidString(elem, "class")) {
            if (let Some(cls) <- level.getJewelClass(id)) {
                let boardPosv2i = getVector2NumberKey(elem, "boardPosition", default: Vector2i())
                let boardPos = (Float32(boardPosv2i.x), Float32(boardPosv2i.y))
                if (level.board.isCoordValid(boardPos) == false || level.board.hasJewel(boardPos) == true) {
                    return
                }
                let jewel = Jewel(cls)
                jewel.points = clamp(
                    getInt64Key(elem, "points", default: cls.points),
                    Int64(Int16.Min),
                    Int64(Int16.Max)
                )
                level.addJewel(jewel)
            }
        }
    }
}
