//
//  FirstViewController.swift
//  Show Me This
//
//  Created by Ravikiran Pathade on 6/17/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
class FirstViewController: UIViewController {
    
    // @IBOutlet weak var speechLabel: UITextField!
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask : SFSpeechRecognitionTask?

    var segueBool = true
    
    @IBOutlet weak var speechLabel: UILabel!
    @IBOutlet weak var parentStackView: UIStackView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraForObjects.isHidden = false
        speechLabel.isHidden = true
        request = SFSpeechAudioBufferRecognitionRequest()
    }
    
    @IBAction func detectSpeechPressed(_ sender: Any) {
        if !cameraForObjects.isHidden {
            speechLabel.text = "Listening..."
            detectSpeechButton.recordAnimation()
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn, animations: {
                self.cameraForObjects.isHidden = true
                self.speechLabel.isHidden = false
            }) { (success) in
                if success {
                    
                }
            }
            startRecording()
            
        }else {
            
            detectSpeechButton.removeAnimation()
            workItem?.cancel()
            stopRecording()
            
            
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn, animations: {
                
                self.cameraForObjects.isHidden = false
                self.speechLabel.isHidden = true
            }) { (success) in
                if success {
                    
                }
            }
        }
        
        
    }
    
    func doExcitingThings(){
        
    }
    var workItem : DispatchWorkItem?
    
    @IBOutlet weak var detectSpeechButton: UIButton!
    @IBOutlet weak var cameraForObjects: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.navigationBar.prefersLargeTitles = true
        self.speechLabel.numberOfLines = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startRecording(){
        SFSpeechRecognizer.requestAuthorization { (status) in
            if status == SFSpeechRecognizerAuthorizationStatus.authorized{
                var count = 0
                let node = self.audioEngine.inputNode
                let recordingFormat = node.outputFormat(forBus: 0)
                self.audioEngine.inputNode.removeTap(onBus: 0)
                node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                    self.request.append(buffer)
                }
                self.audioEngine.prepare()
                
                
                do {
                    try self.audioEngine.start()
                    self.recognitionTask = self.speechRecognizer?.recognitionTask(with: self.request, resultHandler: { (result, _) in
                        // MARK: If no voice recorded for starting time for some amount of time
                        
                        if result != nil {
                            if let _  = self.workItem {
                                self.workItem?.cancel()
                            }
                            self.workItem = DispatchWorkItem {
        
                                if count == 0 {
                                    self.query = result?.bestTranscription.formattedString
                                    self.performSegue(withIdentifier: "micSegue", sender: self.detectSpeechButton)
                                    count = 1
                                }
                                
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: self.workItem!)
                            
                        }
                        
                        
                        if let string = result?.bestTranscription{
                            self.speechLabel.text = string.formattedString
                        }
                    })
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    func stopRecording(){
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
    }
    
    // MARK: - Navigation
    var query : String?
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        workItem?.cancel()
        
        if segue.identifier == "micSegue" {
            if let resultsController = segue.destination as? WolframImagesController{
                resultsController.searchQuery = query
            }
        }
    }
    
}
extension UIButton{
    
    func recordAnimation(){
        let flash =  CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 100
        layer.add(flash, forKey: nil)
    }
    func removeAnimation(){
        layer.removeAllAnimations()
    }
}
