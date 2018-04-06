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
        if !isPlaying {
            isPlaying = true
            setButtonEnabledness(playing: isPlaying)
            
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
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        if isPlaying {
            AudioService.shared.stopAudio()
            isPlaying = false
            setButtonEnabledness(playing: isPlaying)
        }
    }
    
    enum ButtonType : Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        highPitchButton.imageView?.contentMode = .scaleAspectFit
        lowPitchButton.imageView?.contentMode = .scaleAspectFit
        slowButton.imageView?.contentMode = .scaleAspectFit
        fastButtom.imageView?.contentMode = .scaleAspectFit
        echoButton.imageView?.contentMode = .scaleAspectFit
        reverbButton.imageView?.contentMode = .scaleAspectFit
        
        setButtonEnabledness(playing: isPlaying)
        AudioService.shared.setupAudioForPlayback(with: self)
    }
    
    private func setButtonEnabledness(playing: Bool) {
        highPitchButton.isEnabled = !playing
        lowPitchButton.isEnabled = !playing
        slowButton.isEnabled = !playing
        fastButtom.isEnabled = !playing
        echoButton.isEnabled = !playing
        reverbButton.isEnabled = !playing
        
        stopButton.isEnabled = playing
    }
    
    func playbackError(title: String?, message: String?) {
        isPlaying = false
        setButtonEnabledness(playing: isPlaying)
        showAlert(title!, message: message!)
    }
    
    func finishedPlaying() {
        isPlaying = false
        setButtonEnabledness(playing: isPlaying)
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AudioAlerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
