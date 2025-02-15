package Columns

import dgengine.*

extend Level <: ActionQueryable {
    public func getAction(name: String): ?Action {
        match (name) {
            case "levelUp" => levelUpAction
            case "rotate" => rotateAction
            case "touchBase" => touchBaseAction
            case "destroy" => destroyAction
            case "gameOver" => gameOverAction
            case _ => None
        }
    }

    public func setAction(name: String, action: ?Action): Bool {
        match (name) {
            case "levelUp" => levelUpAction = action
            case "rotate" => rotateAction = action
            case "touchBase" => touchBaseAction = action
            case "destroy" => destroyAction = action
            case "gameOver" => gameOverAction = action
            case _ => return false
        }
        return true
    }
}
