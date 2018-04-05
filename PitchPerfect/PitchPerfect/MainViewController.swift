//
//  MainViewController.swift
//  PitchPerfect
//
//  Created by Tristan Heal on 05/04/2018.
//  Copyright © 2018 tristanheal. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, AudioServiceDelegate {
    
    let readyToStartLabel = "Start recording when you are ready"
    let readyToStopLabel = "Tap below to stop recording"
    
    let audioService = AudioService.shared

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordStatusLabel: UILabel!
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        recordButton.isEnabled = false
        stopRecordingButton.isEnabled = true
        recordStatusLabel.text = readyToStopLabel
        
        audioService.startRecording(with: self)
    }
    
    @IBAction func stopRecordingButtonTapped(_ sender: Any) {
        recordButton.isEnabled = true
        stopRecordingButton.isEnabled = false
        recordStatusLabel.text = readyToStartLabel
        
        audioService.stopRecording()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopRecordingButton.isEnabled = false
        recordStatusLabel.text = readyToStartLabel
    }
    
    func finishedRecording(success: Bool) {
        performSegue(withIdentifier: "showPlayback", sender: self)
    }
}

