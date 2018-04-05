//
//  AudioService.swift
//  PitchPerfect
//
//  Created by Tristan Heal on 05/04/2018.
//  Copyright © 2018 tristanheal. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioServiceDelegate {
    
    func finishedRecording(success: Bool)
}

class AudioService : NSObject, AVAudioRecorderDelegate {
    
    private static let sharedAudioService = AudioService()
    
    static var shared: AudioService {
        get {
            return sharedAudioService
        }
    }
    
    let audioSession = AVAudioSession.sharedInstance()
    
    var isRecording = false
    var delegate: AudioServiceDelegate?
    var audioRecorder: AVAudioRecorder!
    
    private override init() {
        super.init()
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.isMeteringEnabled = true
    }
    
    func startRecording(with delegate: AudioServiceDelegate) {
        self.delegate = delegate
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        audioRecorder.delegate = self
    }
    
    func stopRecording() {
        audioRecorder.stop()
    }
    
    func getRecording() {
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        delegate?.finishedRecording(success: flag)
    }
    
}
