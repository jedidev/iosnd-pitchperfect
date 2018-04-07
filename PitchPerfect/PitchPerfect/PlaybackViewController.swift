//
//  PlaybackViewController.swift
//  PitchPerfect
//
//  Created by Tristan Heal on 05/04/2018.
//  Copyright © 2018 tristanheal. All rights reserved.
//

import UIKit

class PlaybackViewController: UIViewController, AudioServiceDelegate {
    
    @IBOutlet weak var highPitchButton: UIButton!
    @IBOutlet weak var lowPitchButton: UIButton!
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var fastButtom: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBAction func playSoundForButton(_ sender: UIButton) {
        if !audioService.isPlaying {
            switch(ButtonType(rawValue: sender.tag)!) {
            case .slow:
                AudioService.shared.playSound(rate: 0.5)
            case .fast:
                AudioService.shared.playSound(rate: 1.5)
            case .chipmunk:
                AudioService.shared.playSound(pitch: 1000)
            case .vader:
                AudioService.shared.playSound(pitch: -1000)
            case .echo:
                AudioService.shared.playSound(echo: true)
            case .reverb:
                AudioService.shared.playSound(reverb: true)
            }
        }
        refreshButtonEnabledness()
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        if audioService.isPlaying {
            audioService.stopAudio()
            refreshButtonEnabledness()
        }
    }
    
    enum ButtonType : Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    let audioService = AudioService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        highPitchButton.imageView?.contentMode = .scaleAspectFit
        lowPitchButton.imageView?.contentMode = .scaleAspectFit
        slowButton.imageView?.contentMode = .scaleAspectFit
        fastButtom.imageView?.contentMode = .scaleAspectFit
        echoButton.imageView?.contentMode = .scaleAspectFit
        reverbButton.imageView?.contentMode = .scaleAspectFit
        
        refreshButtonEnabledness()
        audioService.setupAudioForPlayback(with: self)
    }
    
    private func refreshButtonEnabledness() {
        highPitchButton.isEnabled = !audioService.isPlaying
        lowPitchButton.isEnabled = !audioService.isPlaying
        slowButton.isEnabled = !audioService.isPlaying
        fastButtom.isEnabled = !audioService.isPlaying
        echoButton.isEnabled = !audioService.isPlaying
        reverbButton.isEnabled = !audioService.isPlaying
        
        stopButton.isEnabled = audioService.isPlaying
    }
    
    func playbackError(title: String?, message: String?) {
        refreshButtonEnabledness()
        showAlert(title!, message: message!)
    }
    
    func finishedPlaying() {
        refreshButtonEnabledness()
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AudioAlerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
