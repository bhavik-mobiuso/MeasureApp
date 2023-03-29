//
//  ImageMeasureViewController.swift
//  MeasureDemo
//
//  Created by Bhavik on 03/03/23.
//

import UIKit

class ImageMeasureViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var importBtn: UIButton!
    private  lazy var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageMeasureScreen()
    }
    
    @IBAction func importBtnTap(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                    print("Button capture")

                    imagePicker.delegate = self
                    imagePicker.sourceType = .savedPhotosAlbum
                    imagePicker.allowsEditing = false

                    present(imagePicker, animated: true, completion: nil)
                }
    }
    
}
extension ImageMeasureViewController {
    
    private func setupImageMeasureScreen() {
        
        importBtn.layer.cornerRadius = 10
    }
}
extension ImageMeasureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
            self.dismiss(animated: true, completion: { () -> Void in
                self.imageView.image = image
            })
            
        }
}
