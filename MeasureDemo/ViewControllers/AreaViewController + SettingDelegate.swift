//
//  AreaViewController + SettingDelegate.swift
//  MeasureDemo
//
//  Created by Bhavik on 22/03/23.
//

import Foundation

extension AreaViewController: Setting {

    func settings(measurementUnit: DistanceUnit, isAngleMeasurement: Bool, noOfAngles noOfAngle: Int) {
        self.unit = measurementUnit
        self.angleMeasurement = isAngleMeasurement
        self.noOfAngle = noOfAngle
        self.requiredLine = noOfAngle + 1
        
        if isAngleMeasurement {
            changeBtnMode(isEnabled: true)
        } else {
            if !lines.isEmpty {
                changeBtnMode(isEnabled: true)
            }
        }
    }
    
}
