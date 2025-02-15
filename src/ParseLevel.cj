package Columns

import dgengine.*
import encoding.json.*

func parseLevel(game: Game, elem: JsonValue): Unit {
    let id = getStringCharKey(elem, "id")
    var level = game.resources.getLevel<Level>(id)
    if (level.isNone()) {
        if (isValidId(id) == false) {
            return
        }

        let tiles = game.resources.getTexturePack(getStringCharKey(elem, "tilesTexturePack"))
        let initLevel = getBoolKey(elem, "init")
        if (initLevel == false && tiles.isNone()) {
            return
        }
        let select = game.resources.getTexturePack(getStringCharKey(elem, "selectTexturePack"))
        let highlight = game.resources.getTexturePack(getStringCharKey(elem, "highlightTexturePack"))
        let boardSizev2i = getVector2iKey(elem, "boardSize")
        let boardSize = (Int64(boardSizev2i.x), Int64(boardSizev2i.y))
        let tileSize = Float32(getUIntKey(elem, "tileSize"))

        let lvl = Level(game, tiles, select, highlight, boardSize, tileSize)

        game.resources.addDrawable(id, lvl, manageObjDrawing: true, resourceId: getStringCharKey(elem, "resource"))
        game.resources.setCurrentLevel(lvl)
        lvl.id = id
        lvl.gameShader = game.shaders.level

        parseDrawableProperties(game, elem, lvl)
        level = lvl
    }

    if (let Some(level) <- level) {
        if (let Some(elem) <- getValidObject(elem)) {
            if (let Some(elem) <- elem.get("name")) {
                level.name = getStringChar(elem)
            }
            if (let Some(elem) <- elem.get("pause")) {
                level.pause = getBoolVal(elem)
            }
            if (let Some(elem) <- elem.get("visible")) {
                level.visible = getBoolVal(elem)
            }
            if (let Some(elem) <- elem.get("startPosition")) {
                level.setPlayer1StartPosition(getInt64Val(elem))
            }
            if (let Some(elem) <- elem.get("startPosition2")) {
                level.setPlayer2StartPosition(getInt64Val(elem))
            }
            if (let Some(elem) <- elem.get("flashPosition")) {
                level.setFlashPosition(getInt64Val(elem))
            }
            if (let Some(elem) <- elem.get("scoreFormula")) {
                level.setScoreFormula(getStringChar(elem))
            }
            if (let Some(elem) <- elem.get("levelUpFormula")) {
                level.setLevelUpFormula(getStringChar(elem))
            }
            if (let Some(elem) <- elem.get("magicJewel")) {
                level.setMagicJewel(getStringChar(elem))
            }
            if (let Some(elem) <- getValidArray(elem, "levels")) {
                parseLevelOptions(level.options, elem)
            }
            if (let Some(elem) <- getValidArray(elem, "highScores")) {
                parseLevelScores(level.highScores, elem)
            }

            if (let Some(elem) <- elem.get("onLevelUp")) {
                level.setAction(
                    "levelUp",
                    getActionVal(game, elem)
                )
            }
            if (let Some(elem) <- elem.get("onRotate")) {
                level.setAction(
                    "rotate",
                    getActionVal(game, elem)
                )
            }
            if (let Some(elem) <- elem.get("onTouchBase")) {
                level.setAction(
                    "touchBase",
                    getActionVal(game, elem)
                )
            }
            if (let Some(elem) <- elem.get("onDestroy")) {
                level.setAction(
                    "destroy",
                    getActionVal(game, elem)
                )
            }
            if (let Some(elem) <- elem.get("onGameOver")) {
                level.setAction(
                    "gameOver",
                    getActionVal(game, elem)
                )
            }
        }
    }
}
