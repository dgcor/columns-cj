package Columns

import cjsfml.system.*
import dgengine.*

class Jewel <: Animation & TextureQueryable {
    let cls: JewelClass
    var boardPosition: (Float32, Float32)
    var points: Int64
    private var m_flash = false
    private var m_deleted = false

    init(cls: JewelClass, boardPosition!: (Float32, Float32) = (-1.0, -1.0)) {
        this.cls = cls
        this.boardPosition = boardPosition
        this.points = cls.points
        updateAnimation()
    }

    private func updateAnimation(): Unit {
        var (texturePack, animInfo) = match (m_deleted) {
            case true =>
                let texturePack = cls.texturePackDestroy
                var animInfo = texturePack.getAnimation(0, 0)
                animInfo.animType = AnimationType.PlayOnce
                (texturePack, animInfo)
            case false =>
                let texturePack = cls.texturePack
                let animInfo = match (m_flash) {
                    case true => texturePack.getAnimation(1, 0)
                    case false => texturePack.getAnimation(0, 0)
                }
                (texturePack, animInfo)
        }
        if (animInfo.refresh == Time.zero) {
            animInfo.refresh = Time(milliseconds: 50)
        }
        setAnimation(texturePack, animInfo)
    }

    mut prop flash: Bool {
        get() {
            m_flash
        }
        set(value) {
            if (m_flash == value) {
                return
            }
            m_flash = value
            updateAnimation()
        }
    }

    prop isDeleted: Bool {
        get() {
            m_deleted
        }
    }

    func delete(): Bool {
        if (m_deleted == false) {
            m_deleted = true
            updateAnimation()
            return true
        }
        return false
    }

    public override func getProperty(propName: String): ?Variable {
        if (propName.size <= 1) {
            return None
        }
        let props = splitStringIn2(propName, ".")
        return match (props[0]) {
            case "points" => VaInteger(points)
            case "flash" => VaBoolean(m_flash)
            case "boardPosition" => Variable.getTuple2iProp(
                (Int64(boardPosition[0]), Int64(boardPosition[1])),
                props[1]
            )
            case _ => super.getProperty(propName)
        }
    }

    public override func getTexture(textureNumber: UInt32): ?TextureInfo {
        cls.texturePack.get(textureNumber)
    }
}
