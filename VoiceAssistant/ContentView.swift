//
//  ContentView.swift
//  VoiceAssistant
//
//  Created by Jan de Boer on 06.01.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var speechRecognizerVM = SpeechRecognizerViewModel()
    @State private var isListening = false

    var body: some View {
        VStack {
            TextEditor(text: $speechRecognizerVM.transcribedText)
                .padding()
                .border(Color.gray, width: 1)
                .disabled(true) // Disables editing

            Button(action: {
                self.isListening.toggle()
                if self.isListening {
                    self.speechRecognizerVM.startSpeechRecognition()
                } else {
                    self.speechRecognizerVM.stopSpeechRecognition()
                }
            }) {
                Text(isListening ? "Stop Listening" : "Start Listening")
            }
            .padding()
            .background(isListening ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
