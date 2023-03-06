//
//  MeasureViewController.swift
//  MeasureDemo
//
//  Created by Bhavik on 28/02/23.
//

import UIKit
import ARKit

class MeasureViewController: UIViewController {

    @IBOutlet weak var centerPointImageView: UIImageView!
    @IBOutlet weak var sceneView: MeasureSCNView!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var captureBtn: UIButton!
    
    lazy var screenCenterPoint: CGPoint = {
        return centerPointImageView.center
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearBtn.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sceneView.pause()
        super.viewWillDisappear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /*
        Helper Methods
     */
    
    func hitResult(forPoint point: CGPoint) -> SCNVector3? {
        let hitTestResults = sceneView.hitTest(point, types: .featurePoint)
        if let result = hitTestResults.first {
            let vector = result.worldTransform.columns.3
            return SCNVector3(vector.x, vector.y, vector.z)
        } else {
            return nil
        }
    }
    
    func nodeWithPosition(_ position: SCNVector3) -> SCNNode {
        let sphere = SCNSphere(radius: 0.003)
        
        sphere.firstMaterial?.diffuse.contents = UIColor.white
        sphere.firstMaterial?.lightingModel = .constant
        sphere.firstMaterial?.isDoubleSided = true
        
        
        let node = SCNNode(geometry: sphere)
        node.position = position
        
        return node
    }
    
    
    func updateScaleFromCameraForNodes(_ nodes: [SCNNode], fromPointOfView pointOfView: SCNNode){
        
        nodes.forEach { (node) in
            
            //1. Get The Current Position Of The Node
            let positionOfNode = SCNVector3ToGLKVector3(node.worldPosition)
            
            //2. Get The Current Position Of The Camera
            let positionOfCamera = SCNVector3ToGLKVector3(pointOfView.worldPosition)
            
            //3. Calculate The Distance From The Node To The Camera
            let distanceBetweenNodeAndCamera = GLKVector3Distance(positionOfNode, positionOfCamera)
            
            //4. Animate Their Scaling & Set Their Scale Based On Their Distance From The Camera
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            switch distanceBetweenNodeAndCamera {
            case 0 ... 0.5:
                node.simdScale = simd_float3(0.25, 0.25, 0.25)
            case 0.5 ... 1.5:
                node.simdScale = simd_float3(0.5, 0.5, 0.5)
            case 1.5 ... 2.5:
                node.simdScale = simd_float3(1, 1, 1)
            case 2.5 ... 3:
                node.simdScale = simd_float3(1.5, 1.5, 1.5)
            case 3 ... 3.5:
                node.simdScale = simd_float3(2, 2, 2)
            case 3.5 ... 5:
                node.simdScale = simd_float3(2.5, 2.5, 2.5)
            default:
                node.simdScale = simd_float3(3, 3, 3)
            }
            SCNTransaction.commit()
        }
        
    }
}
