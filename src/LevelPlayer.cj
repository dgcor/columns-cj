package Columns

import dgengine.*

class LevelPlayer {
    var levelStart = 0
    var levelUp = 0
    var score = 0
    var scoreRound = 0
    var jewels = 0
    var jewelsDestroyed = 0
    var jewelsPoints = 0
    var magicJewelsUsed = 0
    var options = LevelOptions()

    func getLevel() {
        levelStart + levelUp
    }

    func getProperty(propName: String): ?Variable {
        if (propName.size <= 1) {
            return None
        }
        return match (propName) {
            case "level" => VaInteger(getLevel())
            case "levelStart" => VaInteger(levelStart)
            case "levelUp" => VaInteger(levelUp)
            case "score" => VaInteger(score)
            case "scoreRound" => VaInteger(scoreRound)
            case "jewels" => VaInteger(jewels)
            case "jewelsDestroyed" => VaInteger(jewelsDestroyed)
            case "jewelsPoints" => VaInteger(jewelsPoints)
            case "magicJewels" => VaInteger(options.magicJewels)
            case "magicJewelsUsed" => VaInteger(magicJewelsUsed)
            case _ => None
        }
    }
}
