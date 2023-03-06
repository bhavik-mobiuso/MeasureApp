//
//  AreaViewController.swift
//  MeasureDemo
//
//  Created by Bhavik on 28/02/23.
//

import UIKit
import ARKit

class AreaViewController: MeasureViewController {
    
    fileprivate lazy var vectorZero = SCNVector3()
    fileprivate lazy var startValue = SCNVector3()
    fileprivate lazy var endValue = SCNVector3()
    fileprivate var currentLine: Line?
    fileprivate lazy var unit: DistanceUnit = .meter
    fileprivate lazy var lines: [Line] = []
    fileprivate lazy var startPoints : [SCNVector3] = []
    fileprivate lazy var endPoints : [SCNVector3] = []
    
    var isMeasuring: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        clearBtn.isHighlighted = false
        clearBtn.isEnabled = false
        captureBtn.isEnabled = false
        captureBtn.isHighlighted = false
    }
    
    //MARK: - IBActions
    
    @IBAction func addPoint(_ sender: UIButton) {
        print("Add Button Tapped")
        let pointLocation = view.convert(screenCenterPoint, to: sceneView)
        if let position: SCNVector3 = sceneView.hitResult(forPoint: pointLocation)  {
            let node = self.nodeWithPosition(position)
            sceneView.scene.rootNode.addChildNode(node)
                
            if !isMeasuring {
                isMeasuring = true
            }
            else {
                if let line = currentLine {
                    lines.append(line)
                    currentLine = nil
                }
                isMeasuring = false
                clearBtn.isEnabled = true
                captureBtn.isHighlighted = true
                captureBtn.isEnabled = true
                startValue = SCNVector3()
            }
        }
        
    }
    @IBAction func clearBtnTap(_ sender: UIButton) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
        node.removeFromParentNode() }
        self.currentLine?.removeFromParentNode()
        clearBtn.isHighlighted = false
        clearBtn.isEnabled = false
        captureBtn.isEnabled = false
        captureBtn.isHighlighted = false
    }
    
    
    @IBAction func capturePhotoBtnTap(_ sender: UIButton) {
        
        print("CapturePhotoBtnTap")
        let renderedImg = self.sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(renderedImg, nil, nil, nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.showToast(message: "Photo saved to cameraroll")
        })
        
    }
    
    @IBAction func unitBtnTap(_ sender: UIButton) {
        
        let alertVC = UIAlertController(title: "Settings", message: "Please select distance unit options", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: DistanceUnit.centimeter.title, style: .default) { [weak self] _ in
            self?.unit = .centimeter
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.inch.title, style: .default) { [weak self] _ in
            self?.unit = .inch
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.meter.title, style: .default) { [weak self] _ in
            self?.unit = .meter
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
        
    }
    
    
    
    
    fileprivate func detectObjects() {
        
        let pointLocation = view.convert(screenCenterPoint, to: sceneView)
        
        if let position: SCNVector3 = sceneView.hitResult(forPoint: pointLocation){
            if isMeasuring {
                if startValue == vectorZero {
                    startValue = position
                    currentLine = Line(sceneView: sceneView, startVector: startValue, unit: unit)
                }
                endValue = position
                currentLine?.update(to: endValue)
                //messageLabel.text = currentLine?.distance(to: endValue) ?? "Calculating…"
            }
        }
        
    }
    
}
extension AreaViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.detectObjects()
        }
    }
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
            case .normal:
                break
            default:
                break
        }
    }
}
extension UIViewController {

    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/4, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
