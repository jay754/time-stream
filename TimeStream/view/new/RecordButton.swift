//
//  RecordButton.swift
//  TimeStream
//
//  Created by appssemble on 02.10.2021.
//

import UIKit

enum RecordButtonType {
    case readyToRecord
    case recording
}

class RecordButton: UIButton {

    var type = RecordButtonType.readyToRecord {
        didSet {
            changeType()
        }
    }
    
    // MARK: Private methods
    
    private func changeType() {
        switch type {
        case .readyToRecord:
            setReadyToRecord()
        case .recording:
            setRecording()
            
        }
    }
    
    private func setReadyToRecord() {
        layer.removeAllAnimations()
        setImage(UIImage(named: "record-icon-normal"), for: .normal)
    }
    
    private func setRecording() {
        layer.removeAllAnimations()
        setImage(UIImage(named: "record-icon-recording"), for: .normal)
    }
}

