//
//  AudioService.swift
//  PitchPerfect
//
//  Created by Tristan Heal on 05/04/2018.
//  Copyright © 2018 tristanheal. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

@objc protocol AudioServiceDelegate {
    @objc optional func finishedRecording(success: Bool)
    @objc optional func finishedPlaying()
    @objc optional func playbackError(title: String?, message: String?)
}

struct AudioAlerts {
    static let DismissAlert = "Dismiss"
    static let RecordingDisabledTitle = "Recording Disabled"
    static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
    static let RecordingFailedTitle = "Recording Failed"
    static let RecordingFailedMessage = "Something went wrong with your recording."
    static let AudioRecorderError = "Audio Recorder Error"
    static let AudioSessionError = "Audio Session Error"
    static let AudioRecordingError = "Audio Recording Error"
    static let AudioFileError = "Audio File Error"
    static let AudioEngineError = "Audio Engine Error"
}

class AudioService : NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    // Static instance section
    private static let sharedAudioService = AudioService()
    
    static var shared: AudioService {
        get {
            return sharedAudioService
        }
    }
    
    // Instance code
    let audioSession = AVAudioSession.sharedInstance()
    let fileUrl: URL?
    
    var delegate: AudioServiceDelegate?
    var audioRecorder: AVAudioRecorder!
    
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    private override init() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        fileUrl = URL(string: pathArray.joined(separator: "/"))
        
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
        try! audioRecorder = AVAudioRecorder(url: fileUrl!, settings: [:])
        audioRecorder.isMeteringEnabled = true
        super.init()
    }
    
    var isPlaying: Bool {
        get {
            return audioEngine?.isRunning ?? false
        }
    }
    
    var isRecording: Bool {
        get {
            return audioRecorder?.isRecording ?? false
        }
    }
    
    var isAvailable: Bool {
        get {
            return !isPlaying && !isRecording
        }
    }
    
    func reset() {
        if isPlaying {
            stopAudio()
        }
        if isRecording {
            stopRecording()
        }
    }
    
    func startRecording(with delegate: AudioServiceDelegate) {
        if !isPlaying && !isRecording {
            self.delegate = delegate
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            audioRecorder.delegate = self
        }
    }
    
    func stopRecording() {
        if isRecording {
            audioRecorder.stop()
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        delegate?.finishedRecording?(success: flag)
    }
    
    
    // MARK: Audio Functions
    
    func setupAudioForPlayback(with delegate: AudioServiceDelegate) {
        
        if isRecording || isPlaying { return }
        self.delegate = delegate
        do {
            audioFile = try AVAudioFile(forReading: fileUrl!)
        } catch {
            self.delegate?.playbackError?(title: AudioAlerts.AudioFileError, message: String(describing: error))
        }
    }
    
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            // schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(self.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
        }
        
        do {
            try audioEngine.start()
        } catch {
            self.delegate?.playbackError?(title: AudioAlerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        // play the recording!
        audioPlayerNode.play()
    }
    
    @objc func stopAudio() {
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
        
        delegate?.finishedPlaying?()
    }
    
    // MARK: Connect List of Audio Nodes
    
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
}
