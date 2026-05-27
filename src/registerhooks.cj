package columns

import dgengine.*

func registerHooks(): Unit {
    Hooks.parseDocumentElem = parseDocumentElem
    Hooks.parseActionElem = parseActionElem

    Defaults.GAME_SIZE_X = 320
    Defaults.GAME_SIZE_Y = 224

    Defaults.GAME_MIN_SIZE_X = 320
    Defaults.GAME_MIN_SIZE_Y = 224

    Defaults.GAME_REF_SIZE_X = 320
    Defaults.GAME_REF_SIZE_Y = 224
}
