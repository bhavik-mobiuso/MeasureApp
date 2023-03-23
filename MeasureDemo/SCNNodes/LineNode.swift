//
//  LineNode.swift
//  MeasureDemo
//
//  Created by Bhavik on 03/03/23.
//

import Foundation
import SceneKit
import ARKit

class MeasuringLine: SCNNode {
    init(startingVector vectorA: GLKVector3, endingVector vectorB: GLKVector3,width: CGFloat) {
        super.init()
        
        let height = CGFloat(GLKVector3Distance(vectorA, vectorB))
        
        self.position = SCNVector3(vectorA.x, vectorA.y, vectorA.z)
        
        let nodeVectorTwo = SCNNode()
        nodeVectorTwo.position = SCNVector3(vectorB.x, vectorB.y, vectorB.z)
        
        let nodeZAlign = SCNNode()
        nodeZAlign.eulerAngles.x = Float.pi/2
        
        let box = SCNBox(width: width, height: height, length: 0.001, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        box.materials = [material]
        
        let nodeLine = SCNNode(geometry: box)
        nodeLine.position.y = Float(-height/2)
        nodeZAlign.addChildNode(nodeLine)
        
        self.addChildNode(nodeZAlign)
        
        self.constraints = [SCNLookAtConstraint(target: nodeVectorTwo)]
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class Line {
    fileprivate var color: UIColor = .white
    
    fileprivate var startNode: SCNNode!
    fileprivate var endNode: SCNNode!
    fileprivate var text: SCNText!
    fileprivate var textNode: SCNNode!
    fileprivate var lineNode: MeasuringLine?
    
    fileprivate let sceneView: ARSCNView!
    fileprivate let startVector: SCNVector3!
    fileprivate let unit: DistanceUnit!
    
    init(sceneView: ARSCNView, startVector: SCNVector3, unit: DistanceUnit) {
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        
        let dot = SCNSphere(radius: 0.5)
        dot.firstMaterial?.diffuse.contents = UIColor.red
        dot.firstMaterial?.lightingModel = .constant
        dot.firstMaterial?.isDoubleSided = true
        startNode = SCNNode(geometry: dot)
        startNode.name = "dot"
        startNode.scale = SCNVector3(1/200.0, 1/200.0, 1/200.0)
        startNode.position = startVector
        sceneView.scene.rootNode.addChildNode(startNode)
       
        endNode = SCNNode(geometry: dot)
        startNode.name = "dot"
        endNode.scale = SCNVector3(1/200.0, 1/200.0, 1/200.0)
        
        text = SCNText(string: "", extrusionDepth: 0.1)
        text.firstMaterial?.diffuse.contents = color
        text.alignmentMode  = CATextLayerAlignmentMode.center.rawValue
        text.truncationMode = CATextLayerTruncationMode.middle.rawValue
        text.firstMaterial?.isDoubleSided = true
        
        
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func update(startValue: SCNVector3, endValue:SCNVector3) {
        lineNode?.removeFromParentNode()
        let vectorA = GLKVector3Make(startValue.x, startValue.y, startValue.z)
        let vectorB = GLKVector3Make(endValue.x, endValue.y, endValue.z)
        
        text.string = distance(to: endValue)
        textNode.position = SCNVector3((startVector.x+endValue.x)/2.0, (startVector.y+endValue.y)/2.0, (startVector.z+endValue.z)/2.0)
        
        let distance = startVector.distance(from: endValue) * unit.fator
        
        if distance > 1.00 {
            text.font = .systemFont(ofSize: 35)
            lineNode = MeasuringLine(startingVector: vectorA, endingVector: vectorB, width: 0.004)
            
        }
        else {
            text.font = .systemFont(ofSize: 12)
            lineNode = MeasuringLine(startingVector: vectorA, endingVector: vectorB, width: 0.002)
            
        }
        self.sceneView.scene.rootNode.addChildNode(lineNode!)
        endNode.position = endValue
        if endNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(endNode)
        }
    }
    
    func distance(to vector: SCNVector3) -> String {
        return String(format: "%.2f%@", startVector.distance(from: vector) * unit.fator, unit.unit)
    }
    
    func removeFromParentNode() {
        startNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
    }
}
