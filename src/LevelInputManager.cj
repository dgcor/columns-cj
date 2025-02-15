package Columns

import cjsfml.system.*
import dgengine.*

class LevelInputManager {
    private var m_moveDownEventName = String.empty
    private var m_moveLeftEventName = String.empty
    private var m_moveRightEventName = String.empty
    private var m_rotateEventName = String.empty
    private var m_reverseRotateEventName = String.empty

    private var m_moveDownTime = ElapsedTime(timeout: Time(milliseconds: 16))
    private var m_moveLeftTime = ElapsedTime(timeout: Time(milliseconds: 100))
    private var m_moveRightTime = ElapsedTime(timeout: Time(milliseconds: 100))

    private var m_leftMoves = 0
    private var m_rightMoves = 0
    private var m_rotateWasPressed = false
    private var m_reverseRotateWasPressed = false

    private func hasActiveInputEvent(game: Game, eventName: String): Bool {
        game.hasFocus && game.resources.hasActiveInputEvents([eventName])
    }

    func initialize(eventNamePrefix: String): Unit {
        m_moveDownEventName = eventNamePrefix + ".down"
        m_moveLeftEventName = eventNamePrefix + ".left"
        m_moveRightEventName = eventNamePrefix + ".right"
        m_rotateEventName = eventNamePrefix + ".rotate"
        m_reverseRotateEventName = eventNamePrefix + ".reverseRotate"
    }

    func processInputEvents(level: Level, game: Game): Unit {
        m_moveDownTime.update(
            game.elapsedTime,
            {
                => if (hasActiveInputEvent(game, m_moveDownEventName) == true) {
                    level.moveSelectedJewels(game, (0.0, 1.0), true)
                }
            }
        )

        let moveLeftPressed = hasActiveInputEvent(game, m_moveLeftEventName)

        if (moveLeftPressed == true && m_leftMoves == 0) {
            m_moveLeftTime.currentTime = m_moveLeftTime.timeout
        }

        m_moveLeftTime.update(
            game.elapsedTime,
            {
                => if (moveLeftPressed == true) {
                    level.moveSelectedJewels(game, (-1.0, 0.0), false)
                    m_leftMoves++
                    match (m_leftMoves) {
                        case 0 | 1 => m_moveLeftTime.timeout = Time(milliseconds: 100)
                        case 2 => m_moveLeftTime.timeout = Time(milliseconds: 50)
                        case 3 => m_moveLeftTime.timeout = Time(milliseconds: 20)
                        case _ => ()
                    }
                    m_moveLeftTime.currentTime = Time(milliseconds: 0)
                } else {
                    m_leftMoves = 0
                }
            }
        )

        let moveRightPressed = hasActiveInputEvent(game, m_moveRightEventName)

        if (moveRightPressed == true && m_rightMoves == 0) {
            m_moveRightTime.currentTime = m_moveRightTime.timeout
        }

        m_moveRightTime.update(
            game.elapsedTime,
            {
                => if (moveRightPressed == true) {
                    level.moveSelectedJewels(game, (1.0, 0.0), false)
                    m_rightMoves++
                    match (m_rightMoves) {
                        case 0 | 1 => m_moveRightTime.timeout = Time(milliseconds: 100)
                        case 2 => m_moveRightTime.timeout = Time(milliseconds: 50)
                        case 3 => m_moveRightTime.timeout = Time(milliseconds: 20)
                        case _ => ()
                    }
                } else {
                    m_moveRightTime.timeout = Time(milliseconds: 100)
                    m_rightMoves = 0
                }
            }
        )

        if (hasActiveInputEvent(game, m_rotateEventName) == true) {
            if (m_rotateWasPressed == false) {
                level.rotateSelectedJewels(game, reverse: false)
                m_rotateWasPressed = true
            }
        } else {
            m_rotateWasPressed = false
        }

        if (hasActiveInputEvent(game, m_reverseRotateEventName) == true) {
            if (m_reverseRotateWasPressed == false) {
                level.rotateSelectedJewels(game, reverse: true)
                m_reverseRotateWasPressed = true
            }
        } else {
            m_reverseRotateWasPressed = false
        }
    }
}
