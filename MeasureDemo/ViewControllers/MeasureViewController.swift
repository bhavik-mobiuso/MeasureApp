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
    @IBOutlet weak var undoBtn: UIButton!
    @IBOutlet weak var addPointBtn: UIButton!
    
    lazy var screenCenterPoint: CGPoint = {
        return centerPointImageView.center
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearBtn.layer.cornerRadius = 10
        undoBtn.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.run()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkCameraAccess()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sceneView.pause()
        super.viewWillDisappear(animated)
    }
}
extension float4x4 {
    var translation: SIMD3<Float> {
        get {
            let translation = columns.3
            return [translation.x, translation.y, translation.z]
        }
        set(newValue) {
            columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
        }
    }
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}

// MARK: - CGPoint extensions

extension CGPoint {
   
    init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
    
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
}
extension MeasureViewController {
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            showAlert(title: "Unable to access the Camera", message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.")
        case .restricted:
            print("Restricted, device owner must approve")
        case .authorized:
            print("Authorized, proceed")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    print("Permission granted, proceed")
                } else {
                    print("Permission denied")
                }
            }
        }
    }

    func showAlert(title:String, message:String) {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
                // Take the user to Settings app to possibly change permission.
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            // Finished opening URL
                        })
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(settingsUrl)
                    }
                }
            })
            alert.addAction(settingsAction)
            
            self.present(alert, animated: true, completion: nil)
        }
}

