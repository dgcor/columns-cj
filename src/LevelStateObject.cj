package Columns

import cjsfml.system.*

struct LevelStateObject {
    var state = GameOver
    var flashGame = false
    var timer = Time.zero
    var timeLimit = Time.zero
    var chain = 0
    var currentJewels = Jewels()
    var nextJewels = Jewels()

    prop isTimeTrial: Bool {
        get() {
            timeLimit > Time.zero
        }
    }

    prop isTimeOver: Bool {
        get() {
            isTimeTrial && timer >= timeLimit
        }
    }

    prop timeLeft: Time {
        get() {
            if (isTimeTrial == true && timer < timeLimit) {
                return timeLimit - timer
            }
            return Time.zero
        }
    }
}
