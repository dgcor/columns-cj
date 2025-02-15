package Columns

import dgengine.*

class JewelClass <: Equatable<JewelClass> {
    var texturePack: TexturePack
    var texturePackDestroy: TexturePack
    var id = String.empty
    var clsType = String.empty
    var points = 0

    init(texturePack: TexturePack, texturePackDestroy: TexturePack) {
        this.texturePack = texturePack
        this.texturePackDestroy = texturePackDestroy
    }

    // Equatable

    public operator func ==(right: JewelClass): Bool {
        isObjEq(this, right)
    }

    public operator func !=(right: JewelClass): Bool {
        !(this == right)
    }
}
