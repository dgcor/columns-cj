package Columns

import dgengine.*

func registerHooks(): Unit {
    Hooks.parseDocumentElem = parseDocumentElem
    Hooks.parseActionElem = parseActionElem

    Game.DefaultSizeX = 320
    Game.DefaultSizeY = 224

    Game.MinSizeX = 320
    Game.MinSizeY = 224

    Game.RefSizeX = 320
    Game.RefSizeY = 224
}
