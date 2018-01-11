//
//  ViewController.swift
//  CoreMl Example
//
//  Created by Gokce123 on 21/12/2017.
//  Copyright © 2017 gokcesarsilmaz. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    @IBOutlet var btnPick: UIButton!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblPredict: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let image = #imageLiteral(resourceName: "car2")
        
        self.imgView.image = image;
        
        guard let ciImage = CIImage.init(image: image) else {
            fatalError("couldn't convert UIImage to CIImage");
        }
        detectImage(ciImage: ciImage)
    }
    
    func detectImage(ciImage:CIImage){
        lblPredict.text = "Tahmin Ediliyor..."
        
        guard let model = try? VNCoreMLModel(for: CarRecognition().model) else {
            fatalError("can't load Places ML model")
        }
        
        // Create a Vision request with completion handler
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            // Update UI on main queue
            DispatchQueue.main.async { [weak self] in
                self?.lblPredict.text = "%\(Int(topResult.confidence * 100))  - \(topResult.identifier)"
            }
        }
        
        // Run the Core ML GoogLeNetPlaces classifier on global dispatch queue
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
        

    }

    @IBAction func pickImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .savedPhotosAlbum
        present(pickerController, animated: true)
    }

}

// MARK: - UIImagePickerControllerDelegate
extension ViewController {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
        }
        
        self.imgView.image = image
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        detectImage(ciImage: ciImage)
    }
}

