package Columns

import dgengine.*

class LevelPlayerManager <: Iterable<LevelPlayer> {
    private static const MaxPlayers = 2
    private var m_players = Array<LevelPlayer>(MaxPlayers, {_ => LevelPlayer()})
    private var m_playerIdx: Int64 = 0
    private var m_startPositions = Array<Int64>(MaxPlayers, item: 0)

    // Iterable

    public func iterator(): Iterator<LevelPlayer> {
        m_players.iterator()
    }

    // LevelPlayerManager

    func initialize(numPlayers: Int64, initialLevel: Int64, optionsManager: LevelOptionsManager): Unit {
        m_players = Array<LevelPlayer>(
            numPlayers,
            {
                _ =>
                var player = LevelPlayer()
                player.levelStart = initialLevel
                player.options = optionsManager.get(player.getLevel())
                return player
            }
        )
        m_playerIdx = 0
    }

    func initialize(players: Array<LevelPlayer>, playerIdx: Int64, optionsManager: LevelOptionsManager): Unit {
        if (players.isEmpty() == true) {
            initialize(1, 0, optionsManager)
            return
        }
        let numPlayers = clamp(players.size, 1, MaxPlayers)
        m_players = Array<LevelPlayer>(
            numPlayers,
            {
                index =>
                var player = players[index]
                player.options = optionsManager.get(player.getLevel())
                return player
            }
        )
        m_playerIdx = match (playerIdx >= 0 && playerIdx < numPlayers) {
            case true => playerIdx
            case false => 0
        }
    }

    prop plr: LevelPlayer {
        get() {
            m_players[m_playerIdx]
        }
    }

    func getStartPosition(playerIdx: Int64): Int64 {
        m_startPositions[playerIdx]
    }

    prop startPosition: Int64 {
        get() {
            m_startPositions[m_playerIdx]
        }
    }

    prop playerIdx: Int64 {
        get() {
            m_playerIdx
        }
    }

    prop size: Int64 {
        get() {
            m_players.size
        }
    }

    func nextPlayer(): Unit {
        m_playerIdx = (m_playerIdx + 1) % m_players.size
    }

    func setStartPosition(playerIdx: Int64, startPos: Int64): Unit {
        m_startPositions[playerIdx] = startPos
    }

    func getProperty(playerIdx: Int64, propName: String): ?Variable {
        if (playerIdx < m_players.size) {
            return m_players[playerIdx].getProperty(propName)
        }
        return None
    }
}
