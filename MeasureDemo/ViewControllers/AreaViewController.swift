//
//  AreaViewController.swift
//  MeasureDemo
//
//  Created by Bhavik on 28/02/23.
//

import UIKit
import ARKit

class AreaViewController: MeasureViewController {
    
    lazy var vectorZero = SCNVector3()
    lazy var startValue = SCNVector3()
    lazy var endValue = SCNVector3()
    var currentLine: Line?
    lazy var lines: [Line] = []
    var planes = [ARPlaneAnchor: Plane]()
    var isMeasuring: Bool = false
    var statusLabel = UILabel()
    var trackingState: ARCamera.TrackingState!
    let coachingOverlay = ARCoachingOverlayView()
    let virtualObjectLoader = VirtualObjectLoader()
    var focusSquare = FocusSquare()
    let updateQueue = DispatchQueue(label: "com.mobiuso.VisionDem1.serialSceneKitQueue")
    var session: ARSession {
        return sceneView.session
    }
    var intialSurfaceDetected : Bool = false
    
    
    //angle measurement code
    var angleNodes = [SCNVector3]()
    var noOfLine = 0
    var noOfAngleLine = 0
    var angles = [AngleNode]()
    var requiredLine = 1
    var angleLines: [Line] = []
    var angleTextodes: [TextNode] = []
    
    //settings
    var settingVC = SettingViewController()
    var angleMeasurement : Bool = false
    var noOfAngle: Int = 1
    var unit: DistanceUnit = .meter
    let userDefault = UserDefaults.standard
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets delegates

        sceneView.delegate = self
        session.delegate = self
        addPointBtn.isHighlighted = true
        addPointBtn.isEnabled = false
        changeBtnMode(isEnabled: false)
        setupCoachingOverlay()
        settings()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func detectObjects() {
        
        let pointLocation = view.convert(screenCenterPoint, to: sceneView)
        if let position: SCNVector3 = sceneView.hitResult(forPoint: pointLocation, planeType: .existingPlaneUsingExtent){
            self.addPointBtn.isHighlighted = false
            self.addPointBtn.isEnabled = true
            self.statusLabel.removeFromSuperview()
            if !intialSurfaceDetected {
                self.showStatusMsg(text: "Surface is detected press + to start")
                intialSurfaceDetected = true
            }
            if isMeasuring {
                if startValue == vectorZero {
                    startValue = position
                    currentLine = Line(sceneView: sceneView, startVector: startValue, unit: unit)
                }
                endValue = position
                currentLine?.update(startValue: startValue, endValue: endValue)
            }
        }
        else {
            if let position = sceneView.hitResult(forPoint: pointLocation, planeType: .featurePoint) {
                if isMeasuring {
                    if startValue == vectorZero {
                        self.statusLabel.removeFromSuperview()
                        startValue = position
                        currentLine = Line(sceneView: sceneView, startVector: startValue, unit: unit)
                    }
                    endValue = position
                    currentLine?.update(startValue: startValue, endValue: endValue)
                }
            }
            else {
                self.addPointBtn.isHighlighted = true
                self.addPointBtn.isEnabled = false
                self.showStatusMsg(text: "Surface not detected please move your phone on surface")
            }
        }}
     
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        let plane = Plane(anchor)
        planes[anchor] = plane
        print(plane.planeAnchor.alignment)
        node.addChildNode(plane)
        DispatchQueue.main.async {
            self.statusLabel.removeFromSuperview()
            self.addPointBtn.isHighlighted = false
            self.addPointBtn.isEnabled = true
        }
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
    
    func settings() {
        let units = userDefault.value(forKey: userSettings.unit.rawValue)
        guard let isAngleMeasurement = userDefault.value(forKey: userSettings.isAngleMeasurement.rawValue) else { return }
        let noOfAngles = userDefault.value(forKey: userSettings.noOfAngle.rawValue)
        
        self.angleMeasurement = isAngleMeasurement as! Bool
        self.noOfAngle = noOfAngles as! Int
        let unitData: [DistanceUnit] = [.centimeter, .meter,.inch,.foot]
        for unit in unitData {
            if unit.unit == units as! String {
                self.unit = unit
             
            }
        }
    }
    
}
extension ARSCNView {
    /**
     Type conversion wrapper for original `unprojectPoint(_:)` method.
     Used in contexts where sticking to SIMD3<Float> type is helpful.
     */
    func unprojectPoint(_ point: SIMD3<Float>) -> SIMD3<Float> {
        return SIMD3<Float>(unprojectPoint(SCNVector3(point)))
    }
    
    // - Tag: CastRayForFocusSquarePosition
    func castRay(for query: ARRaycastQuery) -> [ARRaycastResult] {
        return session.raycast(query)
    }

    // - Tag: GetRaycastQuery
    func getRaycastQuery(for alignment: ARRaycastQuery.TargetAlignment = .any) -> ARRaycastQuery? {
        return raycastQuery(from: screenCenter, allowing: .estimatedPlane, alignment: alignment)
    }
    
    var screenCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
