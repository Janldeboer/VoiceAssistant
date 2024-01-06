//
//  SpeechRocognitionViewModelw.swift
//  VoiceAssistant
//
//  Created by Jan de Boer on 06.01.24.
//

import Foundation
import Speech

class SpeechRecognizerViewModel: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published var transcribedText: String = ""

    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition not available")
                @unknown default:
                    fatalError()
                }
            }
        }
    }

    func startSpeechRecognition() {
        do {
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                self.recognitionRequest?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create request") }
            recognitionRequest.shouldReportPartialResults = true

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                if let result = result {
                    self?.transcribedText = result.bestTranscription.formattedString
                }
                if error != nil || result?.isFinal == true {
                    self?.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self?.recognitionRequest = nil
                    self?.recognitionTask = nil
                }
            }
        } catch {
            print("Error starting the speech recognition")
        }
    }

    func stopSpeechRecognition() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }
}
