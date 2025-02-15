package Columns

import cjsfml.system.*

struct LevelOptions {
    var level = 0
    var levelMax = 199
    var scoreMin = 0
    var scoreMax = 99999999
    var jewelsMax = 9999
    var dropSteps = 2
    var dropPoints = 1
    var magicJewels = 0
    var magicHeight = 0
    var hints = false
    var dropSpeed = Time(milliseconds: 250)
    var timeoutSpeed = Time(milliseconds: 320)
    var updateScoreSpeed = Time(milliseconds: 400)
    var jewels: Array<String> = []
}
