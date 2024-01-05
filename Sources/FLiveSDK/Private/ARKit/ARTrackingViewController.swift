//
//  ARTrackingFaceViewController.swift
//  DetectBody
//
//  Created by HungND on 11/08/2023.
//

import UIKit
import ARKit
import AVFoundation

open class ARTrackingViewController: UIViewController, FaceDetectorDelegate {
    
    private var sceneView = ARSCNView()
    private var detector = FaceDetector()
    
    open var showFaceMesh: Bool {
        return true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        setupUI()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()
        configuration.isWorldTrackingEnabled = false
        configuration.isLightEstimationEnabled = false
        
        let listVideo = ARFaceTrackingConfiguration.supportedVideoFormats
        for i in stride(from: listVideo.count - 1, to: 0,by: -1){
            let videoFormat = listVideo[i]
            if(videoFormat.framesPerSecond > 40){
                configuration.videoFormat = videoFormat
                break
            }
        }
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
        detector.detectorDidRelease()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func setupUI() {
        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        configurationSceneView()
    }
    
    private func configurationSceneView() {
        detector.delegate = self
        detector.detectorDidActive()
        
        sceneView.showsStatistics = true
        sceneView.delegate = detector
        sceneView.session.delegate = detector
        
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device")
            return
        }
    }
    
    internal func detector(sceneView detector: FaceDetector) -> ARSCNView {
        return sceneView
    }
    
    internal func detector(showFaceMesh detector: FaceDetector) -> Bool {
        return showFaceMesh
    }
}
