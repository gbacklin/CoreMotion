//
//  CoreMotionHistoryViewController.swift
//  TestCoreMotionController
//
//  Created by Gene Backlin on 2/6/18.
//  Copyright © 2018 Gene Backlin. All rights reserved.
//

import UIKit
import CoreMotionController

let OneDayInterval: TimeInterval = (24 * 3600)

class CoreMotionHistoryViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var coreMotionController: CoreMotionController?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        coreMotionController = CoreMotionController.sharedInstance
        setUpUI()
        initializeDateFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coreMotionController?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - @IBAction methods
    
    @IBAction func queryActivityHistory(_ sender: UIButton) {
        coreMotionController?.clearBuffer()
        activityIndicator.startAnimating()
        coreMotionController!.queryActivity(from: coreMotionController!.date(from: startDateTextField.text!)!,
                                            to: coreMotionController!.date(from: endDateTextField.text!)!)
    }
    
    @IBAction func queryPedometerHistory(_ sender: UIButton) {
        coreMotionController?.clearBuffer()
        activityIndicator.startAnimating()
        coreMotionController!.queryPedometer(from: coreMotionController!.date(from: startDateTextField.text!)!,
                                             to: coreMotionController!.date(from: endDateTextField.text!)!)
    }
    
    @IBAction func takeIntValueFromSlider(_ sender: UISlider) {
        let dayValue: Double = Double(sender.value)
        let timeInterval = OneDayInterval * dayValue
        let startDate = NSDate(timeIntervalSinceNow: -timeInterval)
        
        startDateTextField.text = coreMotionController?.string(from: startDate as Date)
    }
    
    // MARK: - Utility methods
    
    func initializeDateFields() {
        let startDate = NSDate(timeIntervalSinceNow: -OneDayInterval)
        let endDate = Date()
        
        startDateTextField.text = coreMotionController?.string(from: startDate as Date)
        endDateTextField.text = coreMotionController?.string(from: endDate)
    }
    
    func setUpUI() {
        let trashBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clear(_:)))
        navigationItem.rightBarButtonItem = trashBarButtonItem
        textView.text = ""
        title = "History"
   }
    
    // MARK: - Selector methods
    
    @objc
    func clear(_ sender: Any) {
        textView.text = ""
        coreMotionController?.clearBuffer()
    }

}

// MARK: - CoreMotionControllerDelegate

extension CoreMotionHistoryViewController: CoreMotionControllerDelegate {
    
    func updateBuffer(data: [String : AnyObject]) {
        let buffer: String = data["buffer"] as! String
        textView.text = buffer
        textView.scrollRangeToVisible(NSMakeRange(textView.text.count, 0))
        activityIndicator.stopAnimating()
    }
}
