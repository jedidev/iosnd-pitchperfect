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
        audioService.startRecording(with: self)
        updateControls()
    }
    
    @IBAction func stopRecordingButtonTapped(_ sender: Any) {
        audioService.stopRecording()
        updateControls()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        audioService.reset()
        updateControls()
    }
    
    func finishedRecording(success: Bool) {
        performSegue(withIdentifier: "showPlayback", sender: self)
    }
    
    private func updateControls() {
        recordButton.isEnabled = audioService.isAvailable
        stopRecordingButton.isEnabled = audioService.isRecording
        recordStatusLabel.text = audioService.isRecording ? readyToStopLabel : readyToStartLabel
    }
}

