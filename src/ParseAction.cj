package Columns

import dgengine.*
import encoding.json.*

func parseActionElem(_: Game, name: String, elem: JsonValue): ?Action {
    match (name) {
        case "level.addHighScore" => parseLevelAddHighScore(elem)
        case "level.loadGame" => parseLevelLoadGame(elem)
        case "level.moveJewels" => parseLevelMoveJewels(elem)
        case "level.newGame" => parseLevelNewGame(elem)
        case "level.pause" => parseLevelPause(elem)
        case "level.rotateJewels" => parseLevelRotateJewels(elem)
        case "level.saveGame" => parseLevelSaveGame(elem)
        case "level.setShader" => parseLevelSetShader(elem)
        case _ => None
    }
}
