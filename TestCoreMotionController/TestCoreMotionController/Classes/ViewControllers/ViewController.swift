//
//  ViewController.swift
//  TestCoreMotionController
//
//  Created by Gene Backlin on 2/3/18.
//  Copyright © 2018 Gene Backlin. All rights reserved.
//

import UIKit
import CoreMotionController

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    var coreMotionController: CoreMotionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        coreMotionController = CoreMotionController.sharedInstance
        textView.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coreMotionController?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setActivityUpdates(_ sender: UISwitch) {
        if sender.isOn == true {
            if coreMotionController!.isMotionActivityAvailable() == true {
                coreMotionController!.startActivityUpdates()
            } else {
                var data: [String : AnyObject] = [String : AnyObject]()
                data["buffer"] = NoMotionActivityAvailable as AnyObject
                
                updateBuffer(data: data)
                sender.isOn = false
            }
        } else {
            if coreMotionController!.isMotionActivityAvailable() == true {
                coreMotionController!.stopActivityUpdates()
            }
        }
    }
    
    @IBAction func setPedometerUpdates(_ sender: UISwitch) {
        if sender.isOn == true {
            if coreMotionController!.isStepCountingAvailable() == true {
                coreMotionController!.startPedometerUpdates()
            } else {
                var data: [String : AnyObject] = [String : AnyObject]()
                data["buffer"] = NoPedometerActivityAvailable as AnyObject
                
                updateBuffer(data: data)
                sender.isOn = false
            }
        } else {
            if coreMotionController!.isStepCountingAvailable() == true {
                coreMotionController!.stopPedometerUpdates()
            }
        }
    }
    
    @IBAction func setAltimeterUpdates(_ sender: UISwitch) {
        if sender.isOn == true {
            if coreMotionController!.isRelativeAltitudeAvailable() == true {
                coreMotionController!.startRelativeAltitudeUpdates()
            } else {
                var data: [String : AnyObject] = [String : AnyObject]()
                data["buffer"] = NoAltitudeActivityAvaiable as AnyObject

                updateBuffer(data: data)
                sender.isOn = false
            }
        } else {
            if coreMotionController!.isRelativeAltitudeAvailable() == true {
                coreMotionController!.stopRelativeAltitudeUpdates()
            }
        }
    }
    
    
    @IBAction func clear(_ sender: UIBarButtonItem) {
        textView.text = ""
    }
    
}

extension ViewController: CoreMotionControllerDelegate {
    
    func updateBuffer(data: [String : AnyObject]) {
        let buffer: String = data["buffer"] as! String
        textView.text = buffer
        textView.scrollRangeToVisible(NSMakeRange(textView.text.count, 0))
    }
}

