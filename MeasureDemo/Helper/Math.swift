//
//  Math.swift
//  MeasureDemo
//
//  Created by Bhavik on 22/03/23.
//

import Foundation
import ARKit

enum DistanceUnit {
    case centimeter
    case inch
    case meter
    case foot
    
    var fator: Float {
        switch self {
        case .centimeter:
            return 100.0
        case .inch:
            return 39.3700787
        case .meter:
            return 1.0
        case .foot:
            return 3.2808399
        }
    }
    
    var unit: String {
        switch self {
        case .centimeter:
            return "cm"
        case .inch:
            return "inch"
        case .meter:
            return "m"
        case .foot:
            return "ft"

        }
    }
    
    var title: String {
        switch self {
        case .centimeter:
            return "Centimeter"
        case .inch:
            return "Inch"
        case .meter:
            return "Meter"
        case .foot:
            return "Foot"
        }
    }
}

func angleFromVectors(start: SCNVector3, mid: SCNVector3, end: SCNVector3) -> Double {
    
    let start = GLKVector3Make(start.x, start.y, start.z)
    let mid = GLKVector3Make(mid.x, mid.y, mid.z)
    let end = GLKVector3Make(end.x, end.y, end.z)
    
    let vector1 = GLKVector3Subtract(start, mid)
    let vector2 = GLKVector3Subtract(end, mid)
    
    let vector1Normalized = GLKVector3Normalize(vector1)
    let vector2Normalized = GLKVector3Normalize(vector2)
    
    let result = vector1Normalized.x * vector2Normalized.x + vector1Normalized.y * vector2Normalized.y + vector1Normalized.z * vector2Normalized.z
    let angle: Double = Double(GLKMathRadiansToDegrees(acos(result)))
    
    return angle
}
