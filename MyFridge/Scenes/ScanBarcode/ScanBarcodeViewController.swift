//
//  ScanBarcodeViewController.swift
//  MyFridge
//
//  Created by Lars Dahl on 01.06.2018.
//  Copyright (c) 2018 Lars Dahl. All rights reserved.
//

import UIKit
import AVFoundation

protocol ScanBarcodeDisplayLogic: class {
    func displayBarcode(viewModel: ScanBarcode.ViewModel)
}

class ScanBarcodeViewController: UIViewController, ScanBarcodeDisplayLogic {
    
    var interactor: ScanBarcodeBusinessLogic?
    var router: (NSObjectProtocol & ScanBarcodeRoutingLogic & ScanBarcodeDataPassing)?
    
    @IBOutlet weak var barcodeViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var barcodeView: UIView!
    
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemQuantityStepper: UIStepper!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    
    var isDisplayingBarcode: Bool = false
    
    var captureSession: AVCaptureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var barcodeFrameView: UIView?
    
    let supportedMetadataObjectTypes: [AVMetadataObject.ObjectType] = [
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.upce
    ]

    // MARK: Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Setup

    private func setup() {
        let viewController = self
        let interactor = ScanBarcodeInteractor()
        let presenter = ScanBarcodePresenter()
        let router = ScanBarcodeRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: Routing

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardShown(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        startCameraSession()
    }
    
    @objc func keyboardShown(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.barcodeViewConstraint.constant = 0.0
            } else {
                self.barcodeViewConstraint.constant = endFrame?.size.height ?? 0.0
            }
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer?) {
        itemNameTextField.resignFirstResponder()
    }

    func startCameraSession() {
        captureSession.beginConfiguration()
        
        // Add input
        let videoDevice = findAppropriateCaptureDevice()
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            captureSession.canAddInput(videoDeviceInput) == true else {
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        
        // Add output
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = supportedMetadataObjectTypes
        captureSession.commitConfiguration()
        
        // Add video preview layer
        setUpPreviewViews()
        
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }

    func displayBarcode(viewModel: ScanBarcode.ViewModel) {
        guard !isDisplayingBarcode else {
            return
        }
        
        isDisplayingBarcode = true
        itemNameTextField.text = viewModel.barcodeValue
    
        UIView.animate(withDuration: 0.3, animations: {
            self.view.bringSubview(toFront: self.barcodeView)
            self.barcodeViewConstraint.constant = -5
            self.view.layoutIfNeeded()
        }, completion: { done in
            self.changeVideoPreviewLayerHeight(add: -190)
        })
    }
    
    private func setUpPreviewViews() {
        // Camera preview
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = self.view.layer.bounds
        
        if let videoPreviewLayer = videoPreviewLayer {
            self.view.layer.addSublayer(videoPreviewLayer)
        }
        
        // Barcode highlight view
        barcodeFrameView = UIView()
        if let barcodeFrameView = barcodeFrameView {
            barcodeFrameView.layer.borderColor = UIColor.green.cgColor
            barcodeFrameView.layer.borderWidth = 2
            self.view.addSubview(barcodeFrameView)
            self.view.bringSubview(toFront: barcodeFrameView)
        }
    }
    
    private func findAppropriateCaptureDevice() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera device.")
        }
    }
    
    private func changeVideoPreviewLayerHeight(add height: Int) {
        guard let videoPreviewLayer = self.videoPreviewLayer else {
            return
        }
        
        var rect = videoPreviewLayer.frame
        rect.size.height = rect.height + CGFloat(height)
        videoPreviewLayer.frame = rect
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        itemQuantityLabel.text = "\(sender.value)"
    }
    
    @IBAction func buttonCancelClicked(_ sender: UIButton) {
        changeVideoPreviewLayerHeight(add: 190)
        self.dismissKeyboard(nil)
        
        UIView.animate(withDuration: 0.3) {
            self.view.sendSubview(toBack: self.barcodeView)
            self.barcodeViewConstraint.constant = -200
            self.view.layoutIfNeeded()
            self.isDisplayingBarcode = false
        }
    }
    
    @IBAction func buttonSaveClicked(_ sender: UIButton) {
        // TODO
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ScanBarcodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count > 0 else {
            barcodeFrameView?.frame = CGRect.zero
            print("No barcode detected")
            return
        }
        
        let metadataObject = metadataObjects.first as! AVMetadataMachineReadableCodeObject
        if supportedMetadataObjectTypes.contains(metadataObject.type) {
            if let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject) {
                barcodeFrameView?.frame = barcodeObject.bounds
            }
            
            if let value = metadataObject.stringValue {
                var request = ScanBarcode.Request()
                request.data.value = value
                
                interactor?.handleBarcodeFound(request: request)
            }
        }
    }
}
