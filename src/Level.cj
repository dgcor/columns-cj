package Columns

import cjsfml.system.*
import dgengine.*
import std.collection.*
import std.math.*

class Level {
    let surface = Surface()
    var gameShader: ?GameShader = None

    let board = LevelBoard()

    let selectionAnim: Animation
    let highlightAnim: Animation
    let highlightPositions = ArrayList<(Float32, Float32)>()

    private let m_tilesTexturePack: ?TexturePack
    private let m_selectTexturePack: ?TexturePack
    private let m_highlightTexturePack: ?TexturePack

    private var m_id = String.empty
    var name = String.empty

    var pause = false
    var hasMouseInside = false

    var gameState = LevelStateObject()

    let playerManager = LevelPlayerManager()

    var clearedJewels = false
    private var m_flashDestroyed = false
    private var m_magicJewelDestroyed = false
    private var m_boardPosDropOffset: Float32 = 0.0

    private var m_flashPosition = 0
    private var m_height = 0
    private var m_scoreFormula = Formula()
    private var m_levelUpFormula = Formula()
    private var m_magicJewel = String.empty
    private var m_magicJewelClass: ?JewelClass = None

    var sleepTime = ElapsedTime()

    let inputManager = LevelInputManager()
    let options = LevelOptionsManager()

    var levelUpAction: ?Action = None
    var rotateAction: ?Action = None
    var touchBaseAction: ?Action = None
    var destroyAction: ?Action = None
    var gameOverAction: ?Action = None

    private let m_jewelsClasses = HashMap<String, JewelClass>()

    let highScores = LevelScoreManager()

    // Level

    init(game: Game, tilesTexturePack: ?TexturePack, selectTexturePack: ?TexturePack,
        highlightTexturePack: ?TexturePack, boardSize: (Int64, Int64), tileSize: Float32) {
        m_tilesTexturePack = tilesTexturePack
        m_selectTexturePack = selectTexturePack
        m_highlightTexturePack = highlightTexturePack

        board.initialize(boardSize, 3)

        playerManager.setStartPosition(0, board.size[0] / 2 - 1)
        playerManager.setStartPosition(1, board.size[0] / 2)

        m_flashPosition = playerManager.getStartPosition(1)

        if (tileSize > 0.0) {
            board.tileSize = tileSize
        } else if (let Some(tilesTexturePack) <- tilesTexturePack) {
            board.tileSize = Float32(tilesTexturePack.getTextureSize(0).x)
        }
        if (board.tileSize <= 0.0) {
            board.tileSize = 32.0
        }

        selectionAnim = match (selectTexturePack) {
            case Some(texturePack) => Animation(texturePack)
            case None => Animation()
        }
        selectionAnim.setAnimation(0, 0)
        selectionAnim.visible = false

        highlightAnim = match (highlightTexturePack) {
            case Some(texturePack) => Animation(texturePack)
            case None => Animation()
        }
        highlightAnim.setAnimation(0, 0)
        highlightAnim.visible = false

        surface.size = Vector2f(
            Float32(board.visibleSize[0]) * board.tileSize,
            Float32(board.visibleSize[1]) * board.tileSize
        )
        surface.setCenter()
        surface.initialize(game)
        surface.updateView(game)
    }

    mut prop id: String {
        get() {
            m_id
        }
        set(value) {
            m_id = value
            inputManager.initialize(value)
        }
    }

    // game related

    prop plr: LevelPlayer {
        get() {
            playerManager.plr
        }
    }

    prop magicJewelDestroyed: Bool {
        get() {
            m_magicJewelDestroyed
        }
    }

    prop height: Int64 {
        get() {
            m_height
        }
    }

    prop magicJewelClass: ?JewelClass {
        get() {
            m_magicJewelClass
        }
    }

    prop currentJewels: Jewels {
        get() {
            gameState.currentJewels
        }
    }

    private func setPlayerStartPosition(index: Int64, startPos: Int64): Unit {
        playerManager.setStartPosition(index, clamp(startPos, 0, board.size[0] - 1))
    }

    public func setPlayer1StartPosition(startPos: Int64): Unit {
        setPlayerStartPosition(0, startPos)
    }

    public func setPlayer2StartPosition(startPos: Int64): Unit {
        setPlayerStartPosition(1, startPos)
    }

    func setFlashPosition(flashPos: Int64): Unit {
        m_flashPosition = flashPos
    }

    func addJewelClass(key: String, obj: JewelClass): Unit {
        m_jewelsClasses.add(key, obj)
    }

    func getJewelClass(key: String): ?JewelClass {
        m_jewelsClasses.get(key)
    }

    func setScoreFormula(str: String): Unit {
        m_scoreFormula = Formula(str)
    }

    func setLevelUpFormula(str: String): Unit {
        m_levelUpFormula = Formula(str)
    }

    func setMagicJewel(str: String): Unit {
        m_magicJewel = str
    }

    func addJewel(jewel: Jewel): Unit {
        addJewel(jewel, jewel.boardPosition)
    }

    func addJewel(jewel: Jewel, boardPos: (Float32, Float32)): Unit {
        if (board.addJewel(jewel, boardPos) == true) {
            LevelDraw.setAnimationPosition(this, jewel, boardPos)
        }
    }

    func moveJewel(oldPos: (Float32, Float32), newPos: (Float32, Float32)): Bool {
        if (let Some(jewel) <- board.moveJewel(oldPos, newPos)) {
            LevelDraw.setAnimationPosition(this, jewel, newPos)
            return true
        }
        return false
    }

    private func initGame(): Unit {
        board.initialize()

        let numTiles = Int32((m_tilesTexturePack?.size ?? 0)) - 1
        for (y in 0..board.size[1]) {
            for (x in 0..board.size[0]) {
                var cell = LevelCell()
                if (numTiles >= 0) {
                    let randomIdx = Random.get(UInt32(numTiles))
                    if (let Some(ti) <- (m_tilesTexturePack?.get(randomIdx) ?? None)) {
                        cell.tile.setTexture(ti)
                    }
                }
                cell.tile.position = board.toDrawCoord((x, y - board.columnHeight))
                board[x, y] = cell
            }
        }

        selectionAnim.visible = false
        highlightAnim.visible = false

        clearedJewels = false
        m_flashDestroyed = false
        m_magicJewelDestroyed = false
        m_height = 0
        m_magicJewelClass = getJewelClass(m_magicJewel)
    }

    func newGame(gameType: String, timeLimit: Time, numPlayers: Int64, height: Int64, initialLevel: Int64): Unit {
        initGame()
        gameState = LevelStateObject()
        var height2 = height
        if (gameType == "flash") {
            gameState.flashGame = true
            height2 = max(height, 2)
        } else {
            gameState.flashGame = false
        }
        height2 = clamp(height2, 0, (board.visibleSize[1] - board.columnHeight))
        gameState.timer = Time()
        gameState.timeLimit = match (timeLimit >= Time.zero) {
            case true => timeLimit
            case false => Time.zero
        }
        let numPlayers2 = clamp(numPlayers, 1, 2)

        gameState.state = AddJewels
        playerManager.initialize(numPlayers2, initialLevel, options)
        updateLevelOptions()

        addJewelRows(height2, gameState.flashGame)
    }

    func loadGame(game: Game, filePath: String): Unit {
        initGame()
        gameState = LevelStateObject()

        if (LevelSave.load(this, filePath) == true) {
            updateLevelOptions()
            updateHeight()

            for (jewel in gameState.currentJewels) {
                LevelDraw.setAnimationPosition(this, jewel, jewel.boardPosition)
            }

            match (gameState.state) {
                case AddJewels =>
                    if (plr.options.hints == true) {
                        doHints()
                    }
                case ClearedJewels | ClearingJewels =>
                    gameState.state = ClearJewels
                    onClearJewels(false)
                case GameOver => doGameOver(game)
                case _ => ()
            }
        }
    }

    func saveGame(filePath: String): Unit {
        LevelSave.save(this, filePath)
    }

    func updateTimer(game: Game): Unit {
        if (gameState.state.isGameOver == false) {
            gameState.timer += game.elapsedTime
            if (gameState.isTimeOver == true) {
                doGameOver(game)
            }
        }
    }

    private func updateLevelOptions(): Unit {
        plr.options = options.get(plr.getLevel())

        sleepTime.timeout = plr.options.timeoutSpeed
        m_boardPosDropOffset = Float32(max(1.0 / Float64(plr.options.dropSteps), 0.01))
    }

    private func addJewelRows(numRows: Int64, setFlashJewel: Bool): Unit {
        if (m_jewelsClasses.size <= 1 || plr.options.jewels.size <= 1) {
            return
        }
        m_height = numRows
        var numRows2 = numRows
        var y = board.size[1] - 1
        var numTries = 100
        while (numRows2 > 0 && numTries > 0) {
            for (x in 0..board.size[0]) {
                addJewel(makeRandomJewel(), (Float32(x), Float32(y)))
            }
            let hasMatch = Box(false)
            LevelBoardUtils.checkBoard(
                this,
                0,
                y,
                board.size[0],
                board.size[1],
                {
                    _ =>
                    hasMatch.value = true
                    return false
                }
            )
            if (hasMatch.value == false) {
                numRows2--
                y--
            } else {
                numTries--
            }
        }
        if (setFlashJewel == true) {
            let cell = board[m_flashPosition, board.size[1] - 1]
            cell.jewel?.flash = true
        }
    }

    private func updateHeight(): Unit {
        var newHeight = 0
        for (y in 0..board.size[1]) {
            if (newHeight > 0) {
                break
            }
            for (x in 0..board.size[0]) {
                if (board.hasJewel((Float32(x), Float32(y))) == true) {
                    newHeight = board.size[1] - y
                    break
                }
            }
        }
        m_height = newHeight
    }

    private func makeRandomJewel(): Jewel {
        if (plr.options.jewels.isEmpty() == false) {
            for (_ in 0..3) {
                let idx = Random.get(plr.options.jewels.size - 1)
                let classId = plr.options.jewels[idx]
                if (let Some(cls) <- getJewelClass(classId)) {
                    return Jewel(cls)
                }
            }
        }
        let it = m_jewelsClasses.values().iterator()
        var cls: ?JewelClass = None
        for (_ in 0..Random.get(m_jewelsClasses.size - 1)) {
            cls = it.next()
        }
        if (let Some(cls) <- cls) {
            return Jewel(cls)
        }
        throw IllegalStateException("No jewel class found")
    }

    private func makeRandomJewels(height: Int64): Jewels {
        if (m_jewelsClasses.isEmpty() == false) {
            let jewels = ArrayList<Jewel>()
            var height = height
            var boardPos = (Float32(playerManager.startPosition), Float32(board.columnHeight) - 1.0)
            while (height > 0) {
                let jewel = makeRandomJewel()
                jewel.boardPosition = boardPos
                LevelDraw.setAnimationPosition(this, jewel, boardPos)
                jewels.add(jewel)
                height--
                boardPos = (boardPos[0], boardPos[1] - 1.0)
            }
            return Jewels(jewels: jewels.toArray())
        }
        return Jewels()
    }

    private func makeMagicJewels(height: Int64): Jewels {
        if (let Some(magicJewelClass) <- m_magicJewelClass) {
            let jewels = ArrayList<Jewel>()
            var height = height
            var boardPos = (Float32(playerManager.startPosition), Float32(board.columnHeight) - 1.0)
            while (height > 0) {
                let jewel = Jewel(magicJewelClass)
                jewel.boardPosition = boardPos
                LevelDraw.setAnimationPosition(this, jewel, boardPos)
                jewels.add(jewel)
                height--
                boardPos = (boardPos[0], boardPos[1] - 1.0)
            }
            return Jewels(jewels: jewels.toArray())
        }
        return Jewels()
    }

    func processStep(game: Game): Unit {
        match (gameState.state) {
            case NextRound =>
                onNextRound()
                onAddJewels(game)
            case AddJewels => onAddJewels(game)
            case ClearJewels => onClearJewels(true)
            case ClearingJewels => onClearingJewels(game)
            case ClearedJewels => onClearedJewels(game)
            case GameOver => ()
        }
    }

    private func onNextRound(): Unit {
        if (playerManager.size > 0) {
            playerManager.nextPlayer()
            updateLevelOptions()
        }
        gameState.state = AddJewels
    }

    private func onAddJewels(game: Game): Unit {
        if (board.isGameOver() == true) {
            doGameOver(game)
        }
        if (gameState.chain > 0) {
            gameState.chain = 0
        }
        if (gameState.currentJewels.isEmpty() == true) {
            var addedMagicJewel = false
            if (plr.magicJewelsUsed < plr.options.magicJewels && m_height >= plr.options.magicHeight) {
                if (Random.get(4) == 0) {
                    gameState.currentJewels = makeMagicJewels(board.columnHeight)
                    plr.magicJewelsUsed++
                    addedMagicJewel = true
                }
            }
            if (addedMagicJewel == false) {
                gameState.currentJewels = makeRandomJewels(board.columnHeight)
                if (plr.options.hints == true) {
                    doHints()
                }
            }
            sleepTime.timeout = plr.options.dropSpeed
            return
        }
        var generateNew = false
        var updateSelected = false
        for (jewel in gameState.currentJewels) {
            var boardPos = jewel.boardPosition
            boardPos = (boardPos[0], boardPos[1] + m_boardPosDropOffset)
            if (ceil(boardPos[1]) < Float32(board.size[1])) {
                if (board.hasJewel(boardPos) == false) {
                    jewel.boardPosition = boardPos
                    LevelDraw.setAnimationPosition(this, jewel, boardPos)
                    if (updateSelected == false) {
                        LevelDraw.setAnimationPosition(this, selectionAnim, boardPos)
                        selectionAnim.visible = true
                        updateSelected = true
                    }
                    continue
                }
            }
            generateNew = true
            break
        }
        if (generateNew == true) {
            for (jewel in gameState.currentJewels) {
                let boardPos = jewel.boardPosition
                if (board.isCoordValid(boardPos) == true) {
                    var cell = board[boardPos]
                    cell.jewel = jewel
                    board[boardPos] = cell
                }
            }
            gameState.currentJewels = Jewels()
            updateHeight()
            gameState.state = ClearJewels
        } else {
            checkIfTouchedBase(game)
        }
    }

    private func onClearJewels(updateStats: Bool): Unit {
        selectionAnim.visible = false
        highlightAnim.visible = false
        highlightPositions.clear()

        let function = match (updateStats) {
            case true => setDeleteAndUpdatePoints
            case false => setDelete
        }
        LevelBoardUtils.checkBoard(this, 0, 0, board.size[0], board.size[1], function)

        if (plr.jewelsDestroyed > 0) {
            clearedJewels = false
            gameState.state = ClearingJewels
            if (updateStats == true) {
                gameState.chain++
                plr.scoreRound = Int64(m_scoreFormula.eval(this))
            }
            sleepTime.timeout = plr.options.updateScoreSpeed
        } else {
            gameState.state = NextRound
            sleepTime.timeout = plr.options.timeoutSpeed
        }
    }

    private func onClearingJewels(game: Game): Unit {
        gameState.state = ClearedJewels
        sleepTime.timeout = Time(milliseconds: 1)
        game.events.addBack(destroyAction)
        updateScore(game)
    }

    private func onClearedJewels(game: Game): Unit {
        if (clearedJewels == false) {
            return
        }
        m_magicJewelDestroyed = false
        if (m_flashDestroyed == true) {
            doGameOver(game)
        } else {
            gameState.state = ClearJewels
        }
        sleepTime.timeout = plr.options.timeoutSpeed
        plr.scoreRound = 0
        plr.jewelsDestroyed = 0
        plr.jewelsPoints = 0
        for (y in 0..board.size[1]) {
            for (x in 0..board.size[0]) {
                deleteJewelAndShift((Float32(x), Float32(y)))
            }
        }
        updateHeight()
    }

    private func doGameOver(game: Game): Unit {
        gameState.state = GameOver
        game.events.addBack(gameOverAction)
    }

    private func doHints(): Unit {
        highlightPositions.clear()
        highlightPositions.add(all: LevelBoardUtils.getHintPositions(this))
        highlightAnim.reset()
        highlightAnim.visible = true
    }

    private func setDelete(jewel: Jewel): Bool {
        // don't remove jewels outside visible area
        if (jewel.boardPosition[1] < Float32(board.columnHeight)) {
            return true
        }
        jewel.delete()
        updateLogic(jewel)
        return true
    }

    private func setDeleteAndUpdatePoints(jewel: Jewel): Bool {
        // don't remove jewels outside visible area
        if (jewel.boardPosition[1] < Float32(board.columnHeight)) {
            return true
        }
        if (jewel.delete() == true) {
            plr.jewelsDestroyed++
            plr.jewelsPoints += jewel.points
        }
        updateLogic(jewel)
        return true
    }

    private func updateLogic(jewel: Jewel): Unit {
        if (gameState.flashGame == true && jewel.flash == true) {
            m_flashDestroyed = true
        }
        match (m_magicJewelClass) {
            case Some(cls) where cls == jewel.cls => m_magicJewelDestroyed = true
            case _ => ()
        }
    }

    private func checkIfTouchedBase(): Bool {
        if (gameState.currentJewels.isEmpty() == true) {
            return false
        }
        sleepTime.timeout = plr.options.dropSpeed
        var boardPos = gameState.currentJewels[0].boardPosition
        boardPos = (boardPos[0], boardPos[1] + m_boardPosDropOffset)
        return (ceil(boardPos[1]) >= Float32(board.size[1]) || board.hasJewel(boardPos) == true)
    }

    private func checkIfTouchedBase(game: Game): Bool {
        if (checkIfTouchedBase() == true) {
            sleepTime.timeout = plr.options.timeoutSpeed
            game.events.addBack(touchBaseAction)
            return true
        }
        return false
    }

    private func deleteJewelAndShift(boardPos: (Float32, Float32)): Unit {
        if (board.hasJewel(boardPos) == false) {
            return
        }
        let cell = board[boardPos]
        if (cell.jewel.isNone() || (cell.jewel?.isDeleted ?? false) == false) {
            return
        }
        if (board.deleteJewel(boardPos) == true) {
            var boardPosA = (0.0f32, 0.0f32)
            var boardPosB = boardPos
            do {
                boardPosA = boardPosB
                boardPosB = (boardPosB[0], boardPosB[1] - 1.0)
            } while (moveJewel(boardPosB, boardPosA) == true)
        }
    }

    func rotateSelectedJewels(game: Game, reverse!: Bool): Unit {
        if (gameState.currentJewels.isEmpty() || gameState.state.isGameOver || pause == true) {
            return
        }
        var boardPos = gameState.currentJewels[0].boardPosition

        gameState.currentJewels.rotate(reverse)

        for (jewel in gameState.currentJewels) {
            jewel.boardPosition = boardPos
            LevelDraw.setAnimationPosition(this, jewel, boardPos)
            boardPos = (boardPos[0], boardPos[1] - 1.0)
        }
        game.events.addBack(rotateAction)
    }

    func moveSelectedJewels(game: Game, boardPosOffset: (Float32, Float32), addDropPoints: Bool): Unit {
        if (gameState.currentJewels.isEmpty() || gameState.state.isGameOver || pause == true) {
            return
        }
        let boardPos = gameState.currentJewels[0].boardPosition
        var newBoardPos = (boardPos[0] + boardPosOffset[0], boardPos[1] + (boardPosOffset[1] * m_boardPosDropOffset))
        let checkboardPos = newBoardPos
        if (checkboardPos[0] < 0.0 || ceil(checkboardPos[0]) >= Float32(board.size[0]) || checkboardPos[1] < -1.0 ||
            ceil(checkboardPos[1]) >= Float32(board.size[1]) || board.hasJewel(checkboardPos) == true) {
            return
        }
        if (addDropPoints == true && boardPosOffset[1] > 0.0) {
            plr.score += (plr.options.dropPoints * Int64(boardPosOffset[1]))
        }
        LevelDraw.setAnimationPosition(this, selectionAnim, newBoardPos)
        selectionAnim.visible = true
        for (jewel in gameState.currentJewels) {
            jewel.boardPosition = newBoardPos
            LevelDraw.setAnimationPosition(this, jewel, newBoardPos)
            newBoardPos = (newBoardPos[0], newBoardPos[1] - 1.0)
        }
        if (checkIfTouchedBase(game) == true) {
            for (jewel in gameState.currentJewels) {
                LevelDraw.setAnimationPosition(this, jewel, jewel.boardPosition)
            }
        }
    }

    private func updateScore(game: Game): Unit {
        plr.score = clamp(plr.score + plr.scoreRound, plr.options.scoreMin, plr.options.scoreMax)
        plr.jewels = clamp(plr.jewels + plr.jewelsDestroyed, 0, plr.options.jewelsMax)
        let levelUp = Int64(m_levelUpFormula.eval(this))
        if (levelUp > plr.levelUp && (plr.levelStart + levelUp) <= plr.options.levelMax) {
            plr.levelUp = levelUp
            updateLevelOptions()
            game.events.addBack(levelUpAction)
        }
    }
}
