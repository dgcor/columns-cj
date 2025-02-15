package Columns

import dgengine.*
import std.collection.*

class LevelBoardUtils {
    private static func checkAndAddHintPosition(level: Level, boardPosA: (Float32, Float32),
        boardPosB: (Float32, Float32), cls: JewelClass, hintPositions: ArrayList<(Float32, Float32)>): Unit {
        if (level.board.isCoordValid(boardPosA) == true && level.board.isCoordValid(boardPosB) == true) {
            let cellA = level.board[boardPosA]
            let cellB = level.board[boardPosB]
            match ((cellA.jewel, cellB.jewel)) {
                case (Some(j1), Some(j2)) where j1.cls == cls && j2.cls == cls =>
                    hintPositions.append(boardPosA)
                    hintPositions.append(boardPosB)
                case _ => ()
            }
        }
    }

    static func getHintPositions(level: Level): ArrayList<(Float32, Float32)> {
        let hintPositions = ArrayList<(Float32, Float32)>()

        let checkClasses = ArrayList<JewelClass>()
        for (jewel in level.currentJewels) {
            let cls = jewel.cls
            if (checkClasses.contains(cls) == false) {
                checkClasses.append(cls)
            }
        }
        for (x in 0..level.board.size[0]) {
            var height = level.currentJewels.size - 1
            for (y in level.board.size[1] - 1..=0 : -1) {
                if (height < 0) {
                    break
                }
                let boardPos = (Float32(x), Float32(y))
                if (level.board[boardPos].jewel.isSome()) {
                    continue
                }
                height--
                for (cls in checkClasses) {
                    // horizontal 1
                    var boardPosA = (boardPos[0] - 1.0, boardPos[1])
                    var boardPosB = (boardPos[0] + 1.0, boardPos[1])
                    checkAndAddHintPosition(level, boardPosA, boardPosB, cls, hintPositions)

                    // horizontal 2
                    boardPosA = (boardPos[0] - 1.0, boardPos[1])
                    boardPosB = (boardPos[0] - 2.0, boardPos[1])
                    checkAndAddHintPosition(level, boardPosA, boardPosB, cls, hintPositions)

                    // horizontal 3
                    boardPosA = (boardPos[0] + 1.0, boardPos[1])
                    boardPosB = (boardPos[0] + 2.0, boardPos[1])
                    checkAndAddHintPosition(level, boardPosA, boardPosB, cls, hintPositions)

                    // vertical
                    boardPosA = (boardPos[0], boardPos[1] + 1.0)
                    boardPosB = (boardPos[0], boardPos[1] + 2.0)
                    checkAndAddHintPosition(level, boardPosA, boardPosB, cls, hintPositions)

                    // diagonal 1
                    boardPosA = (boardPos[0] - 1.0, boardPos[1] - 1.0)
                    boardPosB = (boardPos[0] + 1.0, boardPos[1] + 1.0)
                    checkAndAddHintPosition(level, boardPosA, boardPosB, cls, hintPositions)

                    // diagonal 1 - 2
                    boardPosA = (boardPos[0] - 1.0, boardPos[1] - 1.0)
                    boardPosB = (boardPos[0] - 2.0, boardPos[1] - 2.0)
                    checkAndAddHintPosition(level, boardPosA, boardPosB, cls, hintPositions)

                    // diagonal 1 - 3
                    boardPosA = (boardPos[0] + 1.0, boardPos[1] + 1.0)
                    boardPosB = (boardPos[0] + 2.0, boardPos[1] + 2.0)
                    checkAndAddHintPosition(level, boardPosA, boardPosB, cls, hintPositions)

                    // diagonal 2 - 1
                    boardPosA = (boardPos[0] - 1.0, boardPos[1] + 1.0)
                    boardPosB = (boardPos[0] + 1.0, boardPos[1] - 1.0)
                    checkAndAddHintPosition(level, boardPosA, boardPosB, cls, hintPositions)

                    // diagonal 2 - 2
                    boardPosA = (boardPos[0] - 1.0, boardPos[1] + 1.0)
                    boardPosB = (boardPos[0] - 2.0, boardPos[1] + 2.0)
                    checkAndAddHintPosition(level, boardPosA, boardPosB, cls, hintPositions)

                    // diagonal 2 - 3
                    boardPosA = (boardPos[0] + 1.0, boardPos[1] - 1.0)
                    boardPosB = (boardPos[0] + 2.0, boardPos[1] - 2.0)
                    checkAndAddHintPosition(level, boardPosA, boardPosB, cls, hintPositions)
                }
            }
        }
        return hintPositions
    }

    static func checkBoard(level: Level, startX: Int64, startY: Int64, stopX: Int64, stopY: Int64,
        function: (Jewel) -> Bool): Unit {
        for (y in stopY - 1..=startY : -1) {
            for (x in startX..stopX) {
                let boardPos = (Float32(x), Float32(y))
                let cell = level.board[boardPos]
                if (let Some(cellJewel) <- cell.jewel) {
                    // magic
                    let cellClass = cellJewel.cls
                    match (level.magicJewelClass) {
                        case Some(magicJewelClass) where cellClass == magicJewelClass =>
                            let boardPosA = (boardPos[0], boardPos[1] + 1.0)
                            if (level.board.isCoordValid(boardPosA) == true) {
                                let cellA = level.board[boardPosA]
                                if (let Some(jewelA) <- cellA.jewel) {
                                    let cellAClass = jewelA.cls
                                    if (cellAClass != magicJewelClass) {
                                        for (y2 in startY..stopY) {
                                            for (x2 in startX..stopX) {
                                                let boardPosB = (Float32(x2), Float32(y2))
                                                let cellB = level.board[boardPosB]
                                                if (let Some(jewelB) <- cellB.jewel) {
                                                    let cellBClass = jewelB.cls
                                                    if (cellBClass != cellClass && cellBClass != cellAClass) {
                                                        continue
                                                    }
                                                    if (function(jewelB) == false) {
                                                        return
                                                    }
                                                }
                                            }
                                        }
                                        return
                                    }
                                }
                            }
                        case _ => ()
                    }

                    // horizontal
                    var boardPosA = (boardPos[0] - 1.0, boardPos[1])
                    var boardPosB = (boardPos[0] + 1.0, boardPos[1])
                    if (level.board.isCoordValid(boardPosA) == true && level.board.isCoordValid(boardPosB) == true) {
                        let cellA = level.board[boardPosA]
                        let cellB = level.board[boardPosB]
                        match ((cellA.jewel, cellB.jewel)) {
                            case (Some(j1), Some(j2)) where j1.cls == cellClass && j2.cls == cellClass =>
                                if (function(cell.jewel.getOrThrow()) == false || function(j1) == false ||
                                    function(j2) == false) {
                                    return
                                }
                            case _ => ()
                        }
                    }

                    // vertical
                    boardPosA = (boardPos[0], boardPos[1] - 1.0)
                    boardPosB = (boardPos[0], boardPos[1] + 1.0)
                    if (level.board.isCoordValid(boardPosA) == true && level.board.isCoordValid(boardPosB) == true) {
                        let cellA = level.board[boardPosA]
                        let cellB = level.board[boardPosB]
                        match ((cellA.jewel, cellB.jewel)) {
                            case (Some(j1), Some(j2)) where j1.cls == cellClass && j2.cls == cellClass =>
                                if (function(cell.jewel.getOrThrow()) == false || function(j1) == false ||
                                    function(j2) == false) {
                                    return
                                }
                            case _ => ()
                        }
                    }

                    // diagonal 1
                    boardPosA = (boardPos[0] - 1.0, boardPos[1] - 1.0)
                    boardPosB = (boardPos[0] + 1.0, boardPos[1] + 1.0)
                    if (level.board.isCoordValid(boardPosA) == true && level.board.isCoordValid(boardPosB) == true) {
                        let cellA = level.board[boardPosA]
                        let cellB = level.board[boardPosB]
                        match ((cellA.jewel, cellB.jewel)) {
                            case (Some(j1), Some(j2)) where j1.cls == cellClass && j2.cls == cellClass =>
                                if (function(cell.jewel.getOrThrow()) == false || function(j1) == false ||
                                    function(j2) == false) {
                                    return
                                }
                            case _ => ()
                        }
                    }

                    // diagonal 2
                    boardPosA = (boardPos[0] - 1.0, boardPos[1] + 1.0)
                    boardPosB = (boardPos[0] + 1.0, boardPos[1] - 1.0)
                    if (level.board.isCoordValid(boardPosA) == true && level.board.isCoordValid(boardPosB) == true) {
                        let cellA = level.board[boardPosA]
                        let cellB = level.board[boardPosB]
                        match ((cellA.jewel, cellB.jewel)) {
                            case (Some(j1), Some(j2)) where j1.cls == cellClass && j2.cls == cellClass =>
                                if (function(cell.jewel.getOrThrow()) == false || function(j1) == false ||
                                    function(j2) == false) {
                                    return
                                }
                            case _ => ()
                        }
                    }
                }
            }
        }
    }
}
