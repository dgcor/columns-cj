package Columns

import dgengine.*
import encoding.json.*
import std.math.*

func parseJewelClass(game: Game, elem: JsonValue): Unit {
    if (let Some(level) <- game.resources.getLevel<Level>(getStringCharKey(elem, "level"))) {
        if (let Some(id) <- getValidString(elem, "id")) {
            if (isValidId(id) == false || level.getJewelClass(id).isSome()) {
                return
            }
            let texturePack = game.resources.getTexturePack(getStringCharKey(elem, "texturePack"))
            let texturePackDestroy = game.resources.getTexturePack(getStringCharKey(elem, "texturePackDestroy"))
            let jewelClass = match ((texturePack, texturePackDestroy)) {
                case (Some(tp), Some(tp2)) => JewelClass(tp, tp2)
                case _ => return
            }
            jewelClass.id = id
            jewelClass.clsType = getStringCharKey(elem, "type")
            jewelClass.points = Int64(clamp(getIntKey(elem, "points"), Int32(Int16.Min), Int32(Int16.Max)))

            level.addJewelClass(id, jewelClass)
        }
    }
}
