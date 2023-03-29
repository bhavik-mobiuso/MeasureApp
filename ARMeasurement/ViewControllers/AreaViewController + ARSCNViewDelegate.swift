//
//  AreaViewController + ARSCNViewDelegate.swift
//  MeasureDemo
//
//  Created by Bhavik on 15/03/23.
//

import Foundation
import ARKit

extension AreaViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.detectObjects()
        }
//        let isAnyObjectInView = virtualObjectLoader.loadedObjects.contains { object in
//            return sceneView.isNode(object, insideFrustumOf: sceneView.pointOfView!)
//        }
//        DispatchQueue.main.async {
//            self.updateFocusSquare(isObjectVisible: isAnyObjectInView)
//        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        trackingState = camera.trackingState
        self.describeStates()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planAnchor = anchor as? ARPlaneAnchor {
            addPlane(node: node, anchor: planAnchor)
        }
    }
}
