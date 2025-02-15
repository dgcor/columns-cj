package Columns

enum LevelState {
    | GameOver
    | NextRound
    | AddJewels
    | ClearJewels
    | ClearingJewels
    | ClearedJewels

    static func create(num: Int64) {
        match (num) {
            case 1 => NextRound
            case 2 => AddJewels
            case 3 => ClearJewels
            case 4 => ClearingJewels
            case 5 => ClearedJewels
            case _ => GameOver
        }
    }

    func toInt(): Int64 {
        match (this) {
            case GameOver => 0
            case NextRound => 1
            case AddJewels => 2
            case ClearJewels => 3
            case ClearingJewels => 4
            case ClearedJewels => 5
        }
    }

    prop isGameOver: Bool {
        get() {
            match (this) {
                case GameOver => true
                case _ => false
            }
        }
    }
}
