//
//  ViewController.swift
//  MeasureDemo
//
//  Created by Bhavik on 16/03/23.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var arView: ARView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        arView.automaticallyConfigureSession = true
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal,.vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
    
    @IBAction func addNode(_ sender: UIButton) {
        
        let pointLocation = view.convert(view.center, to: arView)
        let results = arView.raycast(from: pointLocation, allowing: .estimatedPlane, alignment: .any)
        
        if let result = results.first {
            let position = simd_make_float3(result.worldTransform.columns.3)
            
            let objectAnchor = AnchorEntity(world: position)
            
            let sphere = createSphere()
            objectAnchor.addChild(sphere)
            
            arView.scene.addAnchor(objectAnchor)
        }
        
    }
    
    
    
    func createSphere() -> ModelEntity {
        let sphere = MeshResource.generateSphere(radius: 0.5)
        
        let sphereMaterial = SimpleMaterial(color: .blue, isMetallic: true)
        
        let sphereEntiry = ModelEntity(mesh: sphere, materials: [sphereMaterial])
        
        return sphereEntiry
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
