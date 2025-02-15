package Columns

import dgengine.rotate as rotateArray

class Jewels <: Iterable<Jewel> {
    Jewels(var jewels!: Array<Jewel> = Array<Jewel>()) {}

    // Iterable

    public func iterator(): Iterator<Jewel> {
        jewels.iterator()
    }

    // Jewels

    operator func [](index: Int64): Jewel {
        jewels[index]
    }

    prop size: Int64 {
        get() {
            jewels.size
        }
    }

    func isEmpty(): Bool {
        jewels.isEmpty()
    }

    func rotate(reverse: Bool): Unit {
        match (reverse) {
            case true => rotateArray(jewels, -1)
            case false => rotateArray(jewels, 1)
        }
    }
}
