package columns

import cjsfml.system.*

struct LevelStateObject {
    var state = GameOver
    var flashGame = false
    var timer = Time.ZERO
    var timeLimit = Time.ZERO
    var chain = 0
    var currentJewels = Jewels()
    var nextJewels = Jewels()

    prop isTimeTrial: Bool {
        get() {
            timeLimit > Time.ZERO
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
            return Time.ZERO
        }
    }
}
