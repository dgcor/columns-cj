package Columns

import cjsfml.graphics.*
import dgengine.*
import stdx.encoding.json.stream.*
import std.collection.*
import std.io.*

class LevelSave {
    static func load(level: Level, filePath: String): Bool {
        if (let Some(doc) <- JsonUtils.loadFile(filePath)) {
            return load(level, parseLevelSaveObj(level, doc))
        }
        return false
    }

    private static func load(level: Level, levelState: LevelSaveObject): Bool {
        level.gameState = LevelStateObject()

        level.gameState.state = levelState.state.state

        if (levelState.state.flashGame == true && levelState.hasFlash == false) {
            level.gameState.state = GameOver
        }

        level.gameState.flashGame = levelState.state.flashGame
        level.gameState.timer = levelState.state.timer
        level.gameState.timeLimit = levelState.state.timeLimit

        level.gameState.chain = levelState.state.chain

        level.playerManager.initialize(levelState.players.toArray(), levelState.playerIdx, level.options)

        for (jewel in levelState.boardJewels) {
            level.addJewel(jewel)
        }

        if (levelState.state.currentJewels.size > 0) {
            level.gameState.currentJewels = Jewels()
        }

        level.gameState.currentJewels = levelState.state.currentJewels

        return true
    }

    static func save(level: Level, filePath: String): Unit {
        let stream = ByteBuffer()
        let writer = JsonWriter(stream)
        writer.writeConfig = WriteConfig.pretty
        writer.writeConfig.indent = "  "
        serialize(level, writer)
        writer.flush()
        FileUtils.saveBytes(filePath, stream.bytes())
    }

    private static func serialize(level: Level, writer: JsonWriter): Unit {
        // root
        writer.startObject()

        SaveUtils.writeValue(writer, "state", level.gameState.state.toInt())

        SaveUtils.writeValue(writer, "flash", level.gameState.flashGame)
        SaveUtils.writeValue(writer, "timer", level.gameState.timer.milliseconds)
        SaveUtils.writeValue(writer, "timeLimit", level.gameState.timeLimit.milliseconds)

        SaveUtils.writeValue(writer, "chain", level.gameState.chain)

        if (level.playerManager.size > 1) {
            SaveUtils.writeValue(writer, "playerIndex", level.playerManager.playerIdx)
        }

        // players
        writer.writeName("players")
        writer.startArray()

        for (player in level.playerManager) {
            // player
            writer.startObject()

            SaveUtils.writeValue(writer, "levelStart", player.levelStart)
            SaveUtils.writeValue(writer, "levelUp", player.levelUp)
            SaveUtils.writeValue(writer, "score", player.score)
            SaveUtils.writeValue(writer, "scoreRound", player.scoreRound)
            SaveUtils.writeValue(writer, "jewels", player.jewels)
            SaveUtils.writeValue(writer, "jewelsDestroyed", player.jewelsDestroyed)
            SaveUtils.writeValue(writer, "jewelsPoints", player.jewelsPoints)
            SaveUtils.writeValue(writer, "magicJewelsUsed", player.magicJewelsUsed)

            // player
            writer.endObject()
        }

        // players
        writer.endArray()

        // board
        writer.writeName("board")
        writer.startArray()

        for (cell in level.board) {
            if (cell.jewel.isNone()) {
                continue
            }
            // jewel
            writer.startObject()

            SaveUtils.writeValue(writer, "jewel", cell.jewel?.cls.id ?? "")
            SaveUtils.writeValue(writer, "position", cell.jewel?.boardPosition ?? (0.0, 0.0))
            if (cell.jewel?.flash ?? false == true) {
                SaveUtils.writeValue(writer, "flash", true)
            }

            // jewel
            writer.endObject()
        }

        // board
        writer.endArray()

        // jewels
        writer.writeName("jewels")
        writer.startArray()

        for (jewel in level.currentJewels) {
            // jewel
            writer.startObject()

            SaveUtils.writeValue(writer, "jewel", jewel.cls.id)
            SaveUtils.writeValue(writer, "position", jewel.boardPosition)

            // jewel
            writer.endObject()
        }

        // jewels
        writer.endArray()

        // root
        writer.endObject()
    }
}
