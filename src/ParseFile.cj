package Columns

import dgengine.*
import stdx.encoding.json.*

func parseDocumentElem(game: Game, name: String, elem: JsonValue, replaceVars: Box<ReplaceVars>): Bool {
    match (name) {
        case "jewel" => parseDocumentElemArray(parseJewel, game, name, elem, replaceVars)
        case "jewelClass" => parseDocumentElemArray(parseJewelClass, game, name, elem, replaceVars)
        case "level" => parseDocumentElemArray(parseLevel, game, name, elem, replaceVars)
        case _ => return false
    }
    return true
}
