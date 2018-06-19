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

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UITableViewDelegate,UITableViewDataSource{
    var fetchedElements = [String : Float]()
    var tuple = [(key: String, value: Float)]()
    @IBOutlet weak var confidenceTableView: UITableView!
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tuple.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        cell.textLabel?.text = tuple[indexPath.row].key + " -> " + String(tuple[indexPath.row].value * 100) + " %"
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    @IBOutlet weak var previewView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        //captureSession.sessionPreset = .photo
        confidenceTableView.delegate = self
        confidenceTableView.dataSource = self
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        //device.videoZoomFactor = v
        if device.hasTorch {
            try? device.lockForConfiguration()
            //device.flashMode = .on
            device.unlockForConfiguration()
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        if view.frame.height > view.frame.width {
            previewLayer?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/2)
        }else {
            previewLayer?.frame = CGRect(x: 0, y: 0, width: view.frame.width/2, height: view.frame.height)
        }
        
        
        view.layer.addSublayer(previewLayer!)
        
        let dataOutput = AVCaptureVideoDataOutput()
        captureSession.addOutput(dataOutput)
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "queue"))
        //
        //VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let pBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        guard let model = try? VNCoreMLModel(for:SqueezeNet().model) else {return}
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {return}
            
            guard let first = results.first else {return}
            //print(first.identifier,first.confidence)
            if let value = self.fetchedElements[first.identifier] {
                if first.confidence > value {
                    let name = String(first.identifier.split(separator: ",").first!)
                    self.fetchedElements[name] = first.confidence
                }
            }else {
                let name = String(first.identifier.split(separator: ",").first!)
                self.fetchedElements[name] = first.confidence
            }
            self.tuple = Array(self.fetchedElements).sorted(by: {$0.value > $1.value})
            
            DispatchQueue.main.async {
                self.confidenceTableView.reloadData()
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pBuffer, options: [:]).perform([request])
        
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if view.frame.height > view.frame.width {
            previewLayer?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/2)
        }else {
            previewLayer?.frame = CGRect(x: 0, y: 0, width: view.frame.width/2, height: view.frame.height)
        }
    }
    
    
}

