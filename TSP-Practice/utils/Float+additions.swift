//
//  Float+additions.swift
//  TSP-Practice
//
//  Created by Benson Lin on 2022/9/18.
//

import Foundation

extension Float {
    var toCGFloat: CGFloat {
        return CGFloat(self)
    }
}

extension CGFloat {
    var toFloat: Float {
        return Float(self)
    }
}
