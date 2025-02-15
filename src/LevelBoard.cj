package Columns

import cjsfml.system.*
import dgengine.*
import std.collection.*
import std.math.*

class LevelBoard <: Iterable<LevelCell> {
    private var m_cells = ArrayList<LevelCell>()

    // size of cells. height = board height + columnHeight
    private var m_size = (0, 0)

    // visible board height
    private var m_visibleSize = (0, 0)

    // height of jewel column
    private var m_columnHeight = 3

    // size of single jewel width/height
    var tileSize: Float32 = 0.0

    // Iterable

    public func iterator(): Iterator<LevelCell> {
        m_cells.iterator()
    }

    // LevelBoard

    func initialize(): Unit {
        m_cells.clear()
        m_cells = ArrayList<LevelCell>(m_size[0] * m_size[1], {_ => LevelCell()})
    }

    func initialize(size: (Int64, Int64), columnHeight: Int64): Unit {
        if (size[0] < 4 || size[0] > 100 || size[1] < 4 || size[1] > 100) {
            m_size = (6, 13)
        } else {
            m_size = size
        }
        if (columnHeight < 2 || columnHeight > m_size[1] / 2) {
            m_columnHeight = m_size[1] / 2
        } else {
            m_columnHeight = columnHeight
        }
        m_visibleSize = m_size
        m_size = (m_size[0], m_size[1] + m_columnHeight)
        initialize()
    }

    // board height + jewelSize
    prop size: (Int64, Int64) {
        get() {
            m_size
        }
    }

    prop visibleSize: (Int64, Int64) {
        get() {
            m_visibleSize
        }
    }

    // size of jewel column
    prop columnHeight: Int64 {
        get() {
            m_columnHeight
        }
    }

    func toDrawCoord(boardPos: (Int64, Int64)): Vector2f {
        Vector2f(tileSize * Float32(boardPos[0]), tileSize * Float32(boardPos[1]))
    }

    func toDrawCoord(boardPos: (Float32, Float32)): Vector2f {
        Vector2f(round(tileSize * boardPos[0]), round(tileSize * boardPos[1]))
    }

    operator func [](x: Int64, y: Int64): LevelCell {
        m_cells[x + y * m_size[0]]
    }

    operator func [](boardPos: (Float32, Float32)): LevelCell {
        m_cells[Int64(ceil(boardPos[0])) + Int64(ceil(boardPos[1])) * m_size[0]]
    }

    operator func [](x: Int64, y: Int64, value!: LevelCell): Unit {
        m_cells[x + y * m_size[0]] = value
    }

    operator func [](boardPos: (Float32, Float32), value!: LevelCell): Unit {
        m_cells[Int64(ceil(boardPos[0])) + Int64(ceil(boardPos[1])) * m_size[0]] = value
    }

    func isCoordValid(boardPos: (Float32, Float32)): Bool {
        (boardPos[0] >= 0.0 && ceil(boardPos[0]) < Float32(m_size[0]) && boardPos[1] >= 0.0 && ceil(boardPos[1]) <
            Float32(m_size[1]))
    }

    func hasJewel(boardPos: (Float32, Float32)): Bool {
        if (isCoordValid(boardPos) == true) {
            return this[boardPos].jewel.isSome()
        }
        return false
    }

    func addJewel(jewel: ?Jewel, boardPos: (Float32, Float32)): Bool {
        if (isCoordValid(boardPos) == true) {
            var cell = this[boardPos]
            deleteJewel(cell.jewel)
            cell.jewel = jewel
            this[boardPos] = cell
            if (let Some(jewel) <- jewel) {
                jewel.boardPosition = boardPos
                return true
            }
        }
        return false
    }

    func deleteJewel(jewel: ?Jewel): Bool {
        if (let Some(jewel) <- jewel) {
            return deleteJewel(jewel.boardPosition)
        }
        return false
    }

    func deleteJewel(boardPos: (Float32, Float32)): Bool {
        if (isCoordValid(boardPos) == true) {
            var cell = this[boardPos]
            if (cell.jewel.isSome()) {
                cell.jewel = None
                this[boardPos] = cell
                return true
            }
        }
        return false
    }

    func moveJewel(oldPos: (Float32, Float32), newPos: (Float32, Float32)): ?Jewel {
        if (isCoordValid(oldPos) == true && isCoordValid(newPos) == true) {
            var oldCell = this[oldPos]
            var newCell = this[newPos]
            if (oldCell.jewel.isSome() && newCell.jewel.isNone()) {
                newCell.jewel = oldCell.jewel
                newCell.jewel?.boardPosition = newPos
                oldCell.jewel = None
                this[oldPos] = oldCell
                this[newPos] = newCell
                return newCell.jewel
            }
        }
        return None
    }

    // true if there are jewels above visible area
    func isGameOver(): Bool {
        for (x in 0..m_size[0]) {
            if (hasJewel((Float32(x), Float32(m_columnHeight - 1))) == true) {
                return true
            }
        }
        return false
    }
}
