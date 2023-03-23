//
//  AreaViewController + Actionns.swift
//  MeasureDemo
//
//  Created by Bhavik on 15/03/23.
//

import Foundation
import UIKit
import ARKit

//MARK: Actions
extension AreaViewController {
    
    @IBAction func addPoint(_ sender: UIButton) {
            statusLabel.removeFromSuperview()
        
            if !isMeasuring {
                isMeasuring = true
            }
            else {
                if let line = currentLine {
                    if angleMeasurement {
                        
                        // append line into angleLines array
                        angleLines.append(line)
                        
                        // append angle vectors in angleNodes array
                        angleNodes.append(startValue)
                        
                        // check requiredLine (Number of angle + 1) is less then current number of line or not
                        
                        
                        if noOfLine == 1 {
                            angleNodes.append(endValue)
                            for i in angleNodes {
                                print("\n",i)
                            }
                        }
                        noOfLine = noOfLine + 1
                    }
                    else {
                        lines.append(line)
                    }
                    currentLine = nil
                }
                
                changeBtnMode(isEnabled: true)
                startValue = SCNVector3()
                
                if angleMeasurement {
                    if noOfLine > 1 {
                        createAngleDistace()
                        
                    }else {
                        isMeasuring = true
                    }
                }
                else {
                    isMeasuring = false
                }
            }
    }
    
    @IBAction func undoBtnTap(_ sender: UIButton){
        
        if angleMeasurement {
            
            if !angles.isEmpty {
                changeBtnMode(isEnabled: true)
                if let lastAngle: AngleNode = angles.last,
                   let lines: [Line] = lastAngle.lines,
                   let angleText: TextNode = lastAngle.angleText {
                    
                        for line in lines {
                            line.removeFromParentNode()
                        }
                        angleText.removeFromParentNode()
                }
                angles.removeLast()
                if angles.isEmpty {
                    changeBtnMode(isEnabled: false)
                }
            }
        }
        else {
            if !lines.isEmpty {
                let lastLine = lines.last
                lines.removeLast()
                if lines.isEmpty {
                    changeBtnMode(isEnabled: false)
                }
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    if let lastLine = lastLine {
                        lastLine.removeFromParentNode()
                    }
                }
            }
            else {
                changeBtnMode(isEnabled: true)
            }
        }
    }
    
    @IBAction func clearBtnTap(_ sender: UIButton) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            for line in lines {
                line.removeFromParentNode()
            }
            for textNode in angleTextodes {
                textNode.removeFromParentNode()
            }
        }
        
        self.currentLine?.removeFromParentNode()
        changeBtnMode(isEnabled: false)
    }
    
    @IBAction func capturePhotoBtnTap(_ sender: UIButton) {
        
        print("CapturePhotoBtnTap")
        if lines.count > 0 {
            let renderedImg = self.sceneView.snapshot()
            UIImageWriteToSavedPhotosAlbum(renderedImg, nil, nil, nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.showToast(message: "Photo saved to cameraroll")
            })
        }
    }
    
    @IBAction func unitBtnTap(_ sender: UIButton) {
        
        let alertVC = UIAlertController(title: "Settings", message: "Please select distance unit options", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: DistanceUnit.centimeter.title, style: .default) { [weak self] _ in
            self?.unit = .centimeter
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.meter.title, style: .default) { [weak self] _ in
            self?.unit = .meter
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.inch.title, style: .default) { [weak self] _ in
            self?.unit = .inch
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.foot.title, style: .default) { [weak self] _ in
            self?.unit = .foot
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func settingBtnTap(_ sender: UIButton) {
       
        let settingVC = self.storyboard?.instantiateViewController(withIdentifier: "settingVC") as! SettingViewController
        //settingVC.modalPresentationStyle = .fullScreen
        settingVC.modalPresentationStyle = .overCurrentContext
        settingVC.modalTransitionStyle = .coverVertical
        settingVC.settigDelegate = self
        settingVC.measureInUnit = unit
        settingVC.enableAngle = angleMeasurement
        settingVC.noOfAngle = noOfAngle
        self.present(settingVC, animated: true)
        
    }
    
    // status message
    
    func showStatusMsg(text: String) {
        statusLabel.removeFromSuperview()
        statusLabel.text = text
        statusLabel.numberOfLines = 5
        statusLabel.clipsToBounds = true
        statusLabel.layer.cornerRadius = 10
        statusLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        statusLabel.textColor = .lightGray
        statusLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        statusLabel.textAlignment = .center
        self.view.addSubview(statusLabel)
        let maxSize = CGSize(width: 150, height: 300)
        var size = statusLabel.sizeThatFits(maxSize)
        size.width = size.width + 15.0
        size.height = size.height + 10.0
        statusLabel.frame = CGRect(origin: CGPoint(x: 10, y: view.bounds.minY + 200), size: size)
        statusLabel.center.x = view.center.x
    }
    
    
    // camera states
    
    func describeStates() {
        if let tState = trackingState {
            switch tState {
                case .normal:
                    print("Noraml scenario")
                case .notAvailable:
                    print("Tracking unavailable")
                    showStatusMsg(text: "Tracking is unavailable")
                case .limited(let reason):
                    
                    switch reason {
                    case .excessiveMotion:
                        print("To much camera movement")
                        showStatusMsg(text: "Please stable your camera")
                    case .insufficientFeatures:
                        print("Not enough surface detail")
                        showStatusMsg(text: "Not Enough surface detaill")
                    case .initializing:
                        print("Intializing")
                        statusLabel.removeFromSuperview()
                        
                    default :
                        break
                }
            }
        }
    }
    
    func changeBtnMode(isEnabled: Bool) {
        DispatchQueue.main.async {
            self.clearBtn.isHighlighted = !isEnabled
            self.clearBtn.isEnabled = isEnabled
            self.captureBtn.isHighlighted = !isEnabled
            self.captureBtn.isEnabled = isEnabled
            self.undoBtn.isHidden = !isEnabled
            self.undoBtn.isEnabled = isEnabled
        }
    }
    
    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible || coachingOverlay.isActive {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
        }
        
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
            let query = sceneView.getRaycastQuery(),
            let result = sceneView.castRay(for: query).first {
            
            updateQueue.async {
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(raycastResult: result, camera: camera)
            }
            if !coachingOverlay.isActive {
                addPointBtn.isEnabled = true
                addPointBtn.isHighlighted = false
            }
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            addPointBtn.isEnabled = false
            addPointBtn.isHighlighted = true
        }
    }
    
    func createAngleDistace() {
        let startNode = angleNodes[0]
        let midNode = angleNodes[1]
        let endNode = angleNodes[2]
        
        let angleDistance = angleFromVectors(start: startNode, mid: midNode, end: endNode)
        print(angleDistance)
        let formattedAngle = String(format: "%.2f°", angleDistance)
        
        addAngleMeasurement(position: midNode, angle: formattedAngle)
        
        angles.append(AngleNode(lines: angleLines,angleText: angleTextodes.last,angleNodeValue: angleNodes))
        
        isMeasuring = false
        angleNodes.removeAll()
        angleLines.removeAll()
        noOfLine = 0
    }
    
    func addAngleMeasurement(position: SCNVector3, angle: String) {
        
        let angleText = TextNode(text: angle, colour: .white)
        angleText.position = SCNVector3(x: position.x + 0.025, y: position.y + 0.002, z: position.z)
        angleTextodes.append(angleText)
        sceneView.scene.rootNode.addChildNode(angleText)
        
    }
}
