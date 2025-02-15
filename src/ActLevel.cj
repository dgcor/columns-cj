package Columns

import cjsfml.system.*
import dgengine.*

class ActLevelAddHighScore <: Action {
    private let id: String
    private var levelScore: LevelScore

    init(id: String, name: String, level: Int64, score: Int64, jewels: Int64, time: Time) {
        this.id = id
        levelScore = LevelScore()
        levelScore.name = name
        levelScore.level = level
        levelScore.score = score
        levelScore.jewels = jewels
        levelScore.time = time
    }

    public operator func ()(game: Game): Bool {
        if (let Some(level) <- game.resources.getLevel<Level>(id)) {
            level.highScores.add(levelScore)
        }
        return true
    }
}

class ActLevelLoadGame <: Action {
    ActLevelLoadGame(
        private let id: String,
        private let file: String
    ) {}

    public operator func ()(game: Game): Bool {
        if (let Some(level) <- game.resources.getLevel<Level>(id)) {
            level.loadGame(game, GameUtils.replaceStringWithVarOrProp(file, game))
        }
        return true
    }
}

class ActLevelMoveJewels <: Action {
    ActLevelMoveJewels(
        private let id: String,
        private let offset: (Float32, Float32),
        private let addDropPoints: Bool
    ) {}

    public operator func ()(game: Game): Bool {
        if (let Some(level) <- game.resources.getLevel<Level>(id)) {
            level.moveSelectedJewels(game, offset, addDropPoints)
        }
        return true
    }
}

class ActLevelNewGame <: Action {
    ActLevelNewGame(
        private let id: String,
        private let gameType: String,
        private let timeLimit: Time,
        private let numPlayers: Int64,
        private let height: Int64,
        private let initialLevel: Int64
    ) {}

    public operator func ()(game: Game): Bool {
        if (let Some(level) <- game.resources.getLevel<Level>(id)) {
            level.newGame(gameType, timeLimit, numPlayers, height, initialLevel)
        }
        return true
    }
}

class ActLevelPause <: Action {
    ActLevelPause(
        private let id: String,
        private let pause: Bool
    ) {}

    public operator func ()(game: Game): Bool {
        if (let Some(level) <- game.resources.getLevel<Level>(id)) {
            level.pause = pause
        }
        return true
    }
}

class ActLevelRotateJewels <: Action {
    ActLevelRotateJewels(
        private let id: String,
        private let reverse: Bool
    ) {}

    public operator func ()(game: Game): Bool {
        if (let Some(level) <- game.resources.getLevel<Level>(id)) {
            level.rotateSelectedJewels(game, reverse: reverse)
        }
        return true
    }
}

class ActLevelSaveGame <: Action {
    ActLevelSaveGame(
        private let id: String,
        private let file: String
    ) {}

    public operator func ()(game: Game): Bool {
        if (let Some(level) <- game.resources.getLevel<Level>(id)) {
            level.saveGame(GameUtils.replaceStringWithVarOrProp(file, game))
        }
        return true
    }
}

class ActLevelSetShader <: Action {
    ActLevelSetShader(
        private let id: String,
        private let idShader: String
    ) {}

    public operator func ()(game: Game): Bool {
        if (let Some(level) <- game.resources.getLevel<Level>(id)) {
            let shader = game.resources.shaders.get(idShader)
            level.gameShader = shader
        }
        return true
    }
}
