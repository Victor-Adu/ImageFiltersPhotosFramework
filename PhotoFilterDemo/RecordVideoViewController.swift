//
//  RecordVideoViewController.swift
//  PhotoFilterDemo
//
//  Created by Victor  Adu on 8/24/14.
//  Copyright (c) 2014 Victor  Adu. All rights reserved.
//

import UIKit
import AVFoundation
import CoreVideo
import ImageIO
import QuartzCore
import CoreMedia
import Photos

class RecordVideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    var captureSession = AVCaptureSession()
    var movieFileOutput = AVCaptureMovieFileOutput()
    var videoFilePath = String()
    
    @IBOutlet var recordButton : UIBarButtonItem!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //create a capturesession
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        //setup preview layer
        var layer = self.previewView.layer
        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        println(self.view.bounds)
        previewLayer.frame = self.previewView.frame
        self.previewView.layer.addSublayer(previewLayer)
        
        //setup input device
        var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput!
        if let mic = AVCaptureDeviceInput.deviceInputWithDevice(AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio), error: &error) as? AVCaptureDeviceInput {
            if self.captureSession.canAddInput(mic) {
                self.captureSession.addInput(mic)
            }
        }
        if error != nil {
            //will print error if creating the input device does not work, IE simulator
            println(error!.localizedDescription)
        }
        
        if self.captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        self.videoFilePath = NSTemporaryDirectory().stringByAppendingPathComponent("temp.mov")
        if self.captureSession.canAddOutput(movieFileOutput) {
            self.captureSession.addOutput(movieFileOutput)
        }
        
        captureSession.startRunning()
    }
    
    /*  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.addTestLabelWithString("Test Label", frame: self.view.bounds)
    } */
    @IBAction func recordVideo(sender: AnyObject) {
        
        self.recordButton.enabled = false
        
        //used for capturing a video from AVCaptureSession
        if self.movieFileOutput.recording {
            self.recordButton.title = "Saving Video..."
            movieFileOutput.stopRecording()
        } else {
            movieFileOutput.startRecordingToOutputFileURL(NSURL(fileURLWithPath: videoFilePath), recordingDelegate: self)
            self.recordButton.title = "Stop Recording"
            self.recordButton.enabled = true
        }
    }
    
    func saveVideoToPhotosLibrary() {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.Authorized {
            PHPhotoLibrary.requestAuthorization({ (authStatus) -> Void in
                if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.Authorized {
                    return
                }
            })
        }
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            var request = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(NSURL(fileURLWithPath: self.videoFilePath))
            
            }, completionHandler: { (success, error) -> Void in
                if error != nil || success == false {
                    println("error saving video: \(error.localizedDescription)")
                } else {
                    println("Successfully Saved video")
                }
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.recordButton.title = "Start Recording"
                    self.recordButton.enabled = true
                })
        })
    }
    
    //MARK: - Capture Output
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        println("Started Recording")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        println("Finished Saving Recording To Disk")
        self.saveVideoToPhotosLibrary()
    }
}
