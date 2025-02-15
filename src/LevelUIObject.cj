package Columns

import cjsfml.graphics.*
import cjsfml.system.*
import dgengine.*
import std.convert.*

extend Level <: UIObject {
    // Resource

    public func isClosed(): Bool {
        surface.isClosed()
    }

    public func close(): Unit {
        surface.close()
    }

    // UIObject

    public mut prop anchor: Anchor {
        get() {
            surface.anchor
        }
        set(value) {
            surface.anchor = value
        }
    }

    public func updateSize(game: Game): Unit {
        surface.updateSize(game)
    }

    public prop drawPosition: Vector2f {
        get() {
            surface.position
        }
    }

    public mut prop position: Vector2f {
        get() {
            surface.position
        }
        set(value) {
            surface.position = value
        }
    }

    public mut prop size: Vector2f {
        get() {
            surface.size
        }
        set(_) {}
    }

    public mut prop visible: Bool {
        get() {
            surface.visible
        }
        set(value) {
            surface.visible = value
        }
    }

    public func draw(game: Game, target: RenderTarget): Unit {
        LevelDraw.draw(this, game, target)
    }

    public func update(game: Game): Unit {
        if (surface.visible == false || pause == true) {
            return
        }

        let rect = FloatRect(surface.position, surface.size)
        hasMouseInside = rect.contains(game.mousePositionf)

        updateTimer(game)
        inputManager.processInputEvents(this, game)

        if (sleepTime.timeout != Time.zero) {
            sleepTime.update(
                game.elapsedTime,
                {
                    => processStep(game)
                }
            )
        }

        LevelDraw.updateAnimations(this, game)
    }

    // Queryable

    public func getProperty(propName: String): ?Variable {
        if (propName.size <= 1) {
            return None
        }
        let props = splitStringIn2(propName, ".")
        return match (props[0]) {
            case "id" => VaString(id)
            case "name" => VaString(name)
            case "boardSize" => Variable.getTuple2iProp(board.size, props[1])
            case "pause" => VaBoolean(pause)
            case "timer" => GameUtils.getTime(gameState.timer, props[1])
            case "timeLimit" => GameUtils.getTime(gameState.timeLimit, props[1], roundUp: true)
            case "timeLeft" => GameUtils.getTime(gameState.timeLeft, props[1], roundUp: true)
            case "timeTrial" => VaBoolean(gameState.isTimeTrial)
            case "gameType" where gameState.flashGame => VaString("flash")
            case "gameType" => VaString("original")
            case "gameOver" => VaBoolean(gameState.state.isGameOver)
            case "level" => VaInteger(plr.getLevel())
            case "levelStart" => VaInteger(plr.levelStart)
            case "levelUp" => VaInteger(plr.levelUp)
            case "score" => VaInteger(plr.score)
            case "scoreRound" => VaInteger(plr.scoreRound)
            case "jewels" => VaInteger(plr.jewels)
            case "jewelsDestroyed" => VaInteger(plr.jewelsDestroyed)
            case "jewelsPoints" => VaInteger(plr.jewelsPoints)
            case "magicJewels" => VaInteger(plr.options.magicJewels)
            case "magicJewelsUsed" => VaInteger(plr.magicJewelsUsed)
            case "magicJewelDestroyed" => VaBoolean(magicJewelDestroyed)
            case "height" => VaInteger(height)
            case "chain" => VaInteger(gameState.chain)
            case "hasHighScore" =>
                let idx = Int64.tryParse(props[1]) ?? 0
                VaBoolean(idx < highScores.size)
            case "players" => VaInteger(playerManager.size)
            case "playerIdx" => VaInteger(playerManager.playerIdx)
            case "player1" => playerManager.getProperty(0, props[1])
            case "player2" => playerManager.getProperty(1, props[1])
            case "highScore" => highScores.getProperty(props[1])
            case _ => getProperty(props[0], props[1])
        }
    }

    public func getQueryable(_: String): ?QueryObject {
        ObjQueryable(this)
    }
}
