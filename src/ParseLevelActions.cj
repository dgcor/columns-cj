package Columns

import dgengine.*
import stdx.encoding.json.*

func parseLevelAddHighScore(elem: JsonValue): ?Action {
    ActLevelAddHighScore(
        getStringCharKey(elem, "level"),
        getStringCharKey(elem, "scoreName"),
        Int64(getIntKey(elem, "scoreLevel")),
        getInt64Key(elem, "score"),
        Int64(getIntKey(elem, "jewels")),
        getTimeUKey(elem, "time")
    )
}

func parseLevelLoadGame(elem: JsonValue): ?Action {
    ActLevelLoadGame(
        getStringCharKey(elem, "level"),
        getStringCharKey(elem, "file")
    )
}

func parseLevelMoveJewels(elem: JsonValue): ?Action {
    let offset = getVector2iKey(elem, "offset")
    return ActLevelMoveJewels(
        getStringCharKey(elem, "level"),
        (Float32(offset.x), Float32(offset.y)),
        getBoolKey(elem, "addDropPoints", default: true)
    )
}

func parseLevelNewGame(elem: JsonValue): ?Action {
    ActLevelNewGame(
        getStringCharKey(elem, "level"),
        getStringCharKey(elem, "type"),
        getTimeUKey(elem, "timeLimit"),
        Int64(getIntKey(elem, "players")),
        Int64(getIntKey(elem, "height")),
        Int64(getIntKey(elem, "initialLevel"))
    )
}

func parseLevelPause(elem: JsonValue): ?Action {
    ActLevelPause(
        getStringCharKey(elem, "level"),
        getBoolKey(elem, "pause", default: true)
    )
}

func parseLevelRotateJewels(elem: JsonValue): ?Action {
    ActLevelRotateJewels(
        getStringCharKey(elem, "level"),
        getBoolKey(elem, "reverse")
    )
}

func parseLevelSaveGame(elem: JsonValue): ?Action {
    ActLevelSaveGame(
        getStringCharKey(elem, "level"),
        getStringCharKey(elem, "file")
    )
}

func parseLevelSetShader(elem: JsonValue): ?Action {
    ActLevelSetShader(
        getStringCharKey(elem, "level"),
        getStringCharKey(elem, "shader")
    )
}
