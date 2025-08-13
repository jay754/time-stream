//
//  NewRequestViewController.swift
//  TimeStream
//
//  Created by appssemble on 29.10.2021.
//

import UIKit
import CameraKit_iOS
import AVKit

protocol NewRequestViewControllerFlowDelegate: BaseViewControllerFlowDelegate {
    func newRequestGoToPreview(vc: NewRequestViewController, url: URL, user: User)
}

class NewRequestViewController: BaseViewController, TopIndicatorViewDelegate {
    
    weak var flowDelegate: NewRequestViewControllerFlowDelegate?
    var user: User!
    
    private struct Constants {
        static let recordTime = 59 // seconds
    }
    
    @IBOutlet weak var durationIndicatorContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    
    private let topIndicatorView = TopIndicatorView.loadFromNib()
    
    // Recording
    private let session = CKFVideoSession()
    private var previewView: CKFPreviewView!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        durationIndicatorContainer.addSubview(topIndicatorView)
        topIndicatorView.pinToSuperview()
        topIndicatorView.delegate = self
        
        setInitialState()
        
        session.cameraPosition = .front
        
        if !UIDevice.isSimulator {
            DispatchQueue.main.async {
                self.configureCamera()
            }
        }
        
        recordButton.type = .readyToRecord
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        session.start()
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.stop()
    }

    // MARK: Actions
    
    @IBAction func back(_ sender: Any) {
        flowDelegate?.backButtonPressed(from: self)
    }
    
    @IBAction func recordTouchedUpInside(_ sender: Any) {
        if recordButton.type == .readyToRecord {
            startRecording()
        } else {
            endRecording()
        }
    }
    
    @IBAction func recordTouchDown(_ sender: Any) {
    }
    
    @IBAction func switchCamera(_ sender: Any) {
        session.togglePosition()
    }
    
    // MARK: TopIndicatorViewDelegate
    
    func topIndicatorTimeElapsed(view: TopIndicatorView) {
        endRecording()
    }
    
    func topIndicatorTimeRemaining(view: TopIndicatorView, seconds: Int) {
        setTime(seconds: seconds)
    }
    
    // MARK: Private methods
    
    private func configureCamera() {
        previewView = CKFPreviewView(frame: cameraView.bounds)
        previewView.session = session
        previewView.previewLayer?.videoGravity = .resizeAspectFill

        cameraView.addSubview(previewView)
        previewView.pinToSuperview()
    }
    
    private func setTime(seconds: Int) {
        timerLabel.text = "request.for".localized + " " + user.name + "\n" + seconds.secondsToTime()
    }
    
    private func startRecording() {
        setRecordingState()
        
        session.record { (url) in
            let asset = AVAsset(url: url)
            if asset.duration.seconds < 3 {
                self.setInitialState()
                return
            }
            
            self.goToPreviewWith(url: url)
            
        } error: { (error) in
            self.showGenericError()
            
            self.setInitialState()
        }
    }
    
    private func goToPreviewWith(url: URL) {
        flowDelegate?.newRequestGoToPreview(vc: self, url: url, user: user)
        setInitialState()
    }
    
    private func endRecording() {
        setInitialState()
        
        if session.isRecording {
            session.stopRecording()
        }
    }
    
    private func setInitialState() {
        recordButton.type = .readyToRecord
        topIndicatorView.stop = true
        timerLabel.text = "request.for".localized + " " + user.name
        switchCameraButton.isHidden = false
        backButton.isHidden = false
        durationIndicatorContainer.isHidden = true
        recordButton.type = .readyToRecord
    }
    
    private func setRecordingState() {
        switchCameraButton.isHidden = true
        backButton.isHidden = true
        recordButton.type = .recording
        setTime(seconds: Constants.recordTime)
        durationIndicatorContainer.isHidden = false
        topIndicatorView.startCountDown(seconds: Constants.recordTime)
        recordButton.type = .recording
    }
}
