package Columns

import dgengine.*
import encoding.json.*
import std.collection.*

private func parseLevelSavePlayer(elem: JsonObject): LevelPlayer {
    var plr = LevelPlayer()

    plr.levelStart = getInt64Key(elem, "levelStart")
    plr.levelUp = getInt64Key(elem, "levelUp")
    plr.score = getInt64Key(elem, "score")
    plr.scoreRound = getInt64Key(elem, "scoreRound")
    plr.jewels = getInt64Key(elem, "jewels")
    plr.jewelsDestroyed = getInt64Key(elem, "jewelsDestroyed")
    plr.jewelsPoints = getInt64Key(elem, "jewelsPoints")
    plr.magicJewelsUsed = getInt64Key(elem, "magicJewelsUsed")

    return plr
}

private func parseLevelSaveJewel(level: Level, elem: JsonObject): ?Jewel {
    let jewelClass = level.getJewelClass(getStringKey(elem, "jewel"))
    if (let Some(jewelClass) <- jewelClass) {
        let pos = getVector2fKey(elem, "position")
        return Jewel(
            jewelClass,
            boardPosition: (pos.x, pos.y)
        )
    }
    return None
}

func parseLevelSaveObj(level: Level, elem: JsonValue): LevelSaveObject {
    var levelSave = LevelSaveObject()

    levelSave.state.state = LevelState.create(getInt64Key(elem, "state"))
    levelSave.state.flashGame = getBoolKey(elem, "flash")
    levelSave.state.timer = getTimeUKey(elem, "timer")
    levelSave.state.timeLimit = getTimeUKey(elem, "timeLimit")
    levelSave.state.chain = Int64(getUIntKey(elem, "chain"))

    levelSave.playerIdx = Int64(getUIntKey(elem, "playerIndex"))

    if (let Some(elem) <- getValidArray(elem, "players")) {
        for (val in elem.getItems()) {
            if (let Some(val) <- getValidObject(val)) {
                levelSave.players.append(parseLevelSavePlayer(val))
            }
        }
    }

    if (let Some(elem) <- getValidArray(elem, "board")) {
        for (val in elem.getItems()) {
            if (let Some(val) <- getValidObject(val)) {
                if (let Some(jewel) <- parseLevelSaveJewel(level, val)) {
                    if (getBoolKey(val, "flash") == true) {
                        jewel.flash = true
                        levelSave.hasFlash = true
                    }
                    levelSave.boardJewels.append(jewel)
                }
            }
        }
    }

    if (let Some(elem) <- getValidArray(elem, "jewels")) {
        let jewels = ArrayList<Jewel>()
        for (val in elem.getItems()) {
            if (let Some(val) <- getValidObject(val)) {
                if (let Some(jewel) <- parseLevelSaveJewel(level, val)) {
                    jewels.append(jewel)
                }
            }
        }
        levelSave.state.currentJewels.jewels = jewels.toArray()
    }

    return levelSave
}
