package Columns

import cjsfml.graphics.*
import dgengine.*
import std.collection.*

class LevelDraw {
    static func setAnimationPosition(level: Level, anim: Animation, boardPos: (Float32, Float32)): Unit {
        let boardPos2 = (boardPos[0], boardPos[1] - Float32(level.board.columnHeight))
        let animSize = anim.size
        var drawCoord = level.board.toDrawCoord(boardPos2)
        drawCoord.x = drawCoord.x - animSize.x + level.board.tileSize
        drawCoord.y = drawCoord.y - animSize.y + level.board.tileSize
        anim.position = drawCoord
    }

    private static func updateCurrentJewelsAnimation(level: Level, game: Game): Unit {
        for (jewel in level.gameState.currentJewels) {
            jewel.update(game)
        }
    }

    static func updateAnimations(level: Level, game: Game): Unit {
        updateCurrentJewelsAnimation(level, game)
        level.selectionAnim.update(game)
        level.highlightAnim.update(game)
        for (y in 0..level.board.size[1]) {
            for (x in 0..level.board.size[0]) {
                let cell = level.board[x, y]
                if (let Some(jewel) <- cell.jewel) {
                    jewel.update(game)
                    if (jewel.hasPlayOnceAnimationFinished) {
                        level.clearedJewels = true
                    }
                }
            }
        }
    }

    static func draw(level: Level, game: Game, target: RenderTarget): Unit {
        if (level.visible == false) {
            return
        }

        let origView = target.view

        level.surface.clear(Color.transparent)

        for (y in level.board.columnHeight..level.board.size[1]) {
            for (x in 0..level.board.size[0]) {
                let cell = level.board[x, y]
                level.surface.draw(game, cell.tile)
            }
        }
        for (y in level.board.columnHeight..level.board.size[1]) {
            for (x in 0..level.board.size[0]) {
                if (let Some(jewel) <- level.board[x, y].jewel) {
                    level.surface.draw(game, jewel)
                }
            }
        }
        for (jewel in level.gameState.currentJewels) {
            level.surface.draw(game, jewel)
        }

        level.surface.draw(game, level.selectionAnim)
        if (level.plr.options.hints == true) {
            for (boardPos in level.highlightPositions) {
                setAnimationPosition(level, level.highlightAnim, boardPos)
                level.surface.draw(game, level.highlightAnim)
            }
        }

        var surfaceStates = RenderStates.default
        if (let Some(gameShader) <- level.gameShader) {
            let shader = gameShader.shader
            surfaceStates.shader = shader
            for (uniform in gameShader.uniforms) {
                match (uniform) {
                    case "elapsedTime" => shader.setUniform("elapsedTime", game.totalElapsedTime.seconds)
                    case "mousePosition" =>
                        if (level.hasMouseInside == true) {
                            let surfacePos = level.surface.position
                            let surfaceSize = level.surface.size
                            shader.setUniform(
                                "mousePosition",
                                GlslVec2(
                                    (game.mousePositionf.x - surfacePos.x) / surfaceSize.x,
                                    (game.mousePositionf.y - surfacePos.y) / surfaceSize.y
                                )
                            )
                        }
                    case "textureSize" => shader.setUniform("textureSize", level.surface.size)
                    case "visibleRect" =>
                        let rect = level.surface.visibleRect
                        shader.setUniform(
                            "visibleRect",
                            GlslVec4(
                                rect.left,
                                rect.top,
                                rect.width,
                                rect.height
                            )
                        )
                    case _ => ()
                }
            }
        }
        level.surface.draw(target, states: surfaceStates)

        target.view = origView
    }
}
