//
//  ViewController.swift
//  Bookreader
//
//  Created by Marie Brayer on 09/04/2024.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraPreview()
        // Do any additional setup after loading the view.
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait // Or .landscape, .portraitUpsideDown, etc., depending on your needs
    }
    
    // SPEACH TO TEXT
    let synthesizer = AVSpeechSynthesizer()
    func speak(text: String) {
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        utterance.rate = 0.5

        
        synthesizer.speak(utterance)
    }
    
    
    // SHOW CAMERA FEED
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
        
    @IBOutlet weak var cameraView: UIView! // Connect this to your blue UIView in storyboard
        
        func setupCameraPreview() {
            // Step 3: Set up the capture session
            captureSession = AVCaptureSession()
            captureSession?.sessionPreset = .high
            
            // Step 4: Configure the capture input
            guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video),
                  let input = try? AVCaptureDeviceInput(device: backCamera) else {
                print("Unable to access back camera!")
                return
            }
            
            if (captureSession?.canAddInput(input) ?? false) {
                captureSession?.addInput(input)
            } else {
                print("Could not add input to capture session")
                return
            }
            
            // Step 5: Configure the capture output
            //NEW  If you plan to take photos, record videos, or process frames
            // Initialize photoOutput and add it to the session
               photoOutput = AVCapturePhotoOutput()
               if let photoOutput = photoOutput, captureSession?.canAddOutput(photoOutput) ?? false {
                   captureSession?.addOutput(photoOutput)
               }
            
            // Step 6: Create a preview layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = cameraView.layer.bounds
            
            // Step 7: Add the preview layer to your UIView
            cameraView.layer.addSublayer(videoPreviewLayer!)
            
            // Start the session
            captureSession?.startRunning()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            // Update the layer's frame when the view's layout is updated
            videoPreviewLayer?.frame = cameraView?.bounds ?? .zero
        }
    
    
    //TAKING A PICTURE
    var photoOutput: AVCapturePhotoOutput?
    
    // Add this method directly within your class
       func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
           guard let imageData = photo.fileDataRepresentation(),
                 let image = UIImage(data: imageData) else {
               print("Could not get image data.")
               return
           }
           // get the text from the image
           extractTextFromImage(image)
           
           // Update UI on the main thread
           
           DispatchQueue.main.async {
               // Here, you can handle the captured image
               // For example, adding it as a subview to cameraView
               let imageView = UIImageView(image: image)
               imageView.frame = self.cameraView.bounds
               //imageView.contentMode = .scaleAspectFit // scaleToFill maybe
               self.cameraView.addSubview(imageView)
           }
       }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        let settings = AVCapturePhotoSettings()
        // Customize settings if needed
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    
    
    @IBOutlet weak var debugPanel: UILabel!
    
    // SENDING PHOTO TO THE API
    func convertImageToBase64String(_ img: UIImage, compressionQuality: CGFloat) -> String? {
        debugPanel.text = "compressing picture"
        return img.jpegData(compressionQuality: compressionQuality)?.base64EncodedString()
    }
    
    /* using Agemo
    func extractTextFromImage(_ image: UIImage) {
        guard let base64ImageString = convertImageToBase64String(image, compressionQuality: 0.3) else {
            print("Could not convert image to Base64.")
            debugPanel.text = "Could not convert image to Base64."
            return
        }
        
        let apiKey = "FjYtGwlwOF7KtFiyi8QDH7yuzPGnRXak9iucBKXV"
        let appId = "clubo1myt0001lb08u2onsheh"
        let url = URL(string: "https://api.codewords.ai/execute-sync")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let json: [String: Any] = [
            "app_id": appId,
            "inputs": [
                "input_image": base64ImageString
            ]
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        debugPanel.text = "sending request to Agemo"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    print("Error during the API request: \(error?.localizedDescription ?? "Unknown error")")
                    self.debugPanel.text = "API request failed"
                }
                return
            }
            
            if let textResponse = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            // Update your UI with the extracted text
                            print("Extracted text: \(textResponse)")
                            self.debugPanel.text = textResponse
                            
                        }
                    }
            
            /* Parse the JSON response
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let extractedText = jsonResponse["extracted_text"] as? String { // Adjust "extracted_text" based on actual response
                    DispatchQueue.main.async {
                        // Update your UI with the extracted text
                        print("Extracted text: \(extractedText)")
                        self.debugPanel.text = extractedText
                    }
                } else {
                    DispatchQueue.main.async {
                        print("Failed to decode response")
                        self.debugPanel.text = "Failed to decode response"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error parsing response: \(error.localizedDescription)")
                    self.debugPanel.text = "Error parsing response"
                }
            }*/
        }
        task.resume()
    }*/
    
    // with Google Vision
    func extractTextFromImage(_ image: UIImage) {
        guard let base64ImageString = convertImageToBase64String(image, compressionQuality: 0.5)?.replacingOccurrences(of: "\n", with: "") else {
            DispatchQueue.main.async {
                print("Could not convert image to Base64.")
                self.debugPanel.text = "Could not convert image to Base64."
            }
            return
        }
        
        let apiKey = ProcessInfo.processInfo.environment["GOOGLE_API_KEY"] ?? ""
        print("API KEY HERE 888888888 : "+apiKey)
        let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = [
            "requests": [
                [
                    "image": ["content": base64ImageString],
                    "features": [["type": "TEXT_DETECTION"]]
                ]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        debugPanel.text = "Sending request to Google Vision API"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    print("Error during the API request: \(error?.localizedDescription ?? "Unknown error")")
                    self.debugPanel.text = "API request failed"
                }
                return
            }
            
            // Parse the JSON response
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let responses = jsonResponse["responses"] as? [[String: Any]],
                   let textAnnotations = responses.first?["textAnnotations"] as? [[String: Any]],
                   let firstAnnotation = textAnnotations.first,
                   let description = firstAnnotation["description"] as? String {
                    DispatchQueue.main.async {
                        print("Extracted text: \(description)")
                        self.debugPanel.text = description
                    }
                } else {
                    DispatchQueue.main.async {
                        print("Failed to decode response or no text found")
                        self.debugPanel.text = "No text found or failed to decode response"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error parsing response: \(error.localizedDescription)")
                    self.debugPanel.text = "Error parsing response"
                }
            }
        }
        task.resume()
    }

    
   
    @IBAction func buttonTapped(_ sender: UIButton) {
            // Use the button's tag or title to differentiate between buttons, if needed.
            switch sender.tag {
            case 0: // Assuming you've set the button's tag to 0 in the storyboard
                debugPanel.text = "Clique sur Lire pour entendre le text"
                capturePhoto()
            case 1: // Tag set to 1 for the second button
                if let messageForVoice = debugPanel.text {
                    // Use unwrappedString here
                    speak(text:messageForVoice)
                    setupCameraPreview()
                }
                else { speak(text:"Quelque chose ne marche pas")}
                
                
            case 2: // Tag set to 1 for the second button
                debugPanel.text = "Prends une photo"
                setupCameraPreview()
            // ... handle other cases
            default:
                break
            }
        }
    
}

