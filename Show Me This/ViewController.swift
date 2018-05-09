//
//  ViewController.swift
//  Show Me This
//
//  Created by Ravikiran Pathade on 5/2/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var testlabel: UILabel!
    
    @IBOutlet weak var previewView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        //captureSession.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = previewView.layer.bounds
        previewView.layer.addSublayer(previewLayer)
        
        let dataOutput = AVCaptureVideoDataOutput()
        captureSession.addOutput(dataOutput)
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "queue"))
        //
        //VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        let pBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        guard let model = try? VNCoreMLModel(for:MobileNet().model) else {return}
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {return}
            
            guard let first = results.first else {return}
            //print(first.identifier,first.confidence)
            DispatchQueue.main.async {
                self.testlabel.text = first.identifier
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pBuffer, options: [:]).perform([request])
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

