package Columns

import dgengine.*
import stdx.encoding.json.*
import std.collection.*

func parseLevelOptions(optionsManager: LevelOptionsManager, elem: JsonArray): Unit {
    var options = LevelOptions()
    let allOptions = ArrayList<LevelOptions>()
    for (val in elem.getItems()) {
        options.level = getInt64Key(val, "level", default: options.level + 1)
        options.levelMax = getInt64Key(val, "levelMax", default: options.levelMax)
        options.scoreMin = getInt64Key(val, "scoreMin", default: options.scoreMin)
        options.scoreMax = getInt64Key(val, "scoreMax", default: options.scoreMax)
        options.jewelsMax = getInt64Key(val, "jewelsMax", default: options.jewelsMax)
        options.dropSteps = Int64(getUIntKey(val, "dropSteps", default: UInt32(options.dropSteps)))
        options.dropPoints = getInt64Key(val, "dropPoints", default: options.dropPoints)
        options.magicJewels += getInt64Key(val, "magicJewels")
        options.magicHeight = getInt64Key(val, "magicHeight", default: options.magicHeight)
        options.hints = getBoolKey(val, "hints", default: options.hints)
        options.dropSpeed = getTimeUKey(val, "dropSpeed", default: options.dropSpeed)
        options.timeoutSpeed = getTimeUKey(val, "timeoutSpeed", default: options.timeoutSpeed)
        options.updateScoreSpeed = getTimeUKey(val, "updateScoreSpeed", default: options.updateScoreSpeed)

        if (let Some(elem) <- getValidArray(val, "jewels")) {
            let jewels = ArrayList<String>()
            for (val in elem.getItems()) {
                if (let Some(id) <- getValidString(val)) {
                    jewels.add(id)
                }
            }
            options.jewels = jewels.toArray()
        }
        allOptions.add(options)
    }
    optionsManager.set(allOptions)
}
