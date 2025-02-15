package Columns

import cjsfml.system.*
import customiterators.*
import dgengine.*
import std.collection.*
import std.math.*

class LevelOptionsManager {
    private var m_options = ArrayList<LevelOptions>()

    func get(level: Int64): LevelOptions {
        for (opt in m_options |> reverse) {
            if (level >= opt.level) {
                return opt
            }
        }
        return LevelOptions()
    }

    func set(options: ArrayList<LevelOptions>): Unit {
        m_options = options
        m_options.sortBy(
            comparator: {
                a, b =>
                if (a.level < b.level) {
                    return Ordering.LT
                } else if (a.level > b.level) {
                    return Ordering.GT
                }
                return Ordering.EQ
            }
        )
        for (index in 0..options.size) {
            var opt = options[index]

            opt.levelMax = min(opt.levelMax, 0xFFFF)
            if (opt.levelMax <= 0) {
                opt.levelMax = 0xFFFF
            }
            opt.level = clamp(opt.level, 0, opt.levelMax)
            opt.jewelsMax = min(opt.jewelsMax, Int64(Int32.Max))
            if (opt.scoreMax <= 0) {
                opt.scoreMax = Int64.Max
            }
            if (opt.scoreMin >= opt.scoreMax) {
                opt.scoreMin = Int64.Min
            }
            opt.jewelsMax = min(opt.jewelsMax, Int64(Int32.Max))
            if (opt.jewelsMax <= 0) {
                opt.jewelsMax = Int64(Int32.Max)
            }
            opt.dropSteps = clamp(opt.dropSteps, 1, 24)
            opt.dropSpeed = Time(
                milliseconds: clamp(
                    opt.dropSpeed.milliseconds,
                    Time(milliseconds: 1).milliseconds,
                    Time(milliseconds: 2000).milliseconds
                )
            )
            opt.timeoutSpeed = Time(
                milliseconds: clamp(
                    opt.timeoutSpeed.milliseconds,
                    Time(milliseconds: 1).milliseconds,
                    Time(milliseconds: 2000).milliseconds
                )
            )
            opt.updateScoreSpeed = Time(
                milliseconds: clamp(
                    opt.updateScoreSpeed.milliseconds,
                    Time(milliseconds: 1).milliseconds,
                    Time(milliseconds: 2000).milliseconds
                )
            )

            options[index] = opt
        }
    }
}
