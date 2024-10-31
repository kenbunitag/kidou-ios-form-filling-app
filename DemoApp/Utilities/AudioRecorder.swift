//
//  AudioRecorder.swift
//  DemoApp
//
//  Created by Matthias Dunkelberg on 02.12.24.
//

import AVFoundation

class AudioRecorder: NSObject {
    private var audioEngine: AVAudioEngine!
    private var inputNode: AVAudioInputNode!
    private var audioFormat: AVAudioFormat!
    private var callBack: (([Float]) -> Void)?
    
    override init() {
        super.init()
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine.inputNode
        audioFormat = inputNode.inputFormat(forBus: 0)
    }
    
    func getSampleRate() -> Double {
        return audioFormat.sampleRate
    }

    func setCallback(_ callback: @escaping ([Float]) -> Void) {
        self.callBack = callback
    }
    
    func startRecording() {
        inputNode.installTap(onBus: 0, bufferSize: 48000, format: audioFormat) { (buffer, time) in
            // Process the audio buffer here
            // Convert buffer to data and send it via WebSocket
            let data = buffer.floatChannelData![0]
            let dataLength = Int(buffer.frameLength)
            let dataPointer = UnsafeBufferPointer(start: data, count: dataLength)
            let audioData = Array(dataPointer)
            self.callBack?(audioData)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio Engine couldn't start: \(error)")
        }
        // print sample rate
        print("Sample rate: \(audioFormat.sampleRate)")
    }
    
    func stopRecording() {
        inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
}
