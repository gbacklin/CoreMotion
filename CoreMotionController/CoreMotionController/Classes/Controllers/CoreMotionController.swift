//
//  CoreMotionController.swift
//  CoreMotionController
//
//  Created by Gene Backlin on 2/3/18.
//  Copyright © 2018 Gene Backlin. All rights reserved.
//

import UIKit
import CoreMotion

public protocol CoreMotionControllerDelegate {
    func updateBuffer(data: [String : AnyObject])
}

public let NoMotionActivityAvailable = "This app is not authorized for M7\nNo motion activity is available"
public let NoAltitudeActivityAvaiable = "This app is not authorized for M7\nNo altitude info is available"
public let NoPedometerActivityAvailable = "This app is not authorized for M7\nNo pedometer activity is available"

private let onceToken = NSUUID().uuidString

public class CoreMotionController: NSObject {
    public static let sharedInstance = CoreMotionController()

    private var activityManager: CMMotionActivityManager?
    private var _activityHandler: CMMotionActivityHandler!
    
    private var altimeter: CMAltimeter?
    private var _altitudeHandler: CMAltitudeHandler?
    
    private var pedometer: CMPedometer?
    private var _pedometerHandler: CMPedometerHandler?
    
    private var _activityQueryHandler: CMMotionActivityQueryHandler?
    private var _pedometerQueryHandler: CMPedometerHandler?
    
    private var buffer: String = ""
    
    public var delegate: CoreMotionControllerDelegate?
    
    // MARK: - CoreMotion Handlers
    
    var activityHandler: CMMotionActivityHandler {
        get {
            weak var weakSelf = self
            
            let handler: CMMotionActivityHandler = { activity in
                let startDate = activity!.startDate
                
                let stationary = activity!.stationary ? "YES" : "NO"
                let walking = activity!.walking ? "YES" : "NO"
                let running = activity!.running ? "YES" : "NO"
                let automotive = activity!.automotive ? "YES" : "NO"
                let cycling = activity!.cycling ? "YES" : "NO"
                let unknown = activity!.unknown ? "YES" : "NO"
                
                var confidence: [String : CMMotionActivityConfidence] = [String : CMMotionActivityConfidence]()
                switch activity!.confidence {
                case CMMotionActivityConfidence.low:
                    confidence["Low"] = activity!.confidence
                case CMMotionActivityConfidence.medium:
                    confidence["Medium"] = activity!.confidence
                case CMMotionActivityConfidence.high:
                    confidence["High"] = activity!.confidence
                }
                
                var data: [String : AnyObject] = [String : AnyObject]()
                data["buffer"] = "startDate \(startDate) stationary \(stationary) walking \(walking) running \(running) automotive \(automotive) cycling \(cycling) unknown \(unknown) confidence \(confidence)\n" as AnyObject
                data["stationary"] = stationary as AnyObject
                data["walking"] = walking as AnyObject
                data["running"] = running as AnyObject
                data["automotive"] = automotive as AnyObject
                data["cycling"] = cycling as AnyObject
                data["unknown"] = unknown as AnyObject
                data["confidence"] = confidence as AnyObject

                weakSelf!.appendToBuffer(data: data)
            }
            
            _activityHandler = handler
            return _activityHandler
        }
    }
    
    var altitudeHandler: CMAltitudeHandler {
        get {
            weak var weakSelf = self
            
            let handler: CMAltitudeHandler = { altitudeData, error in
                let timestamp = altitudeData!.timestamp
                let relativeAltitude = altitudeData!.relativeAltitude
                let pressure = altitudeData!.pressure
                
                var data: [String : AnyObject] = [String : AnyObject]()
                data["buffer"] = "timestamp \(timestamp) relativeAltitude \(relativeAltitude) pressure \(pressure)\n" as AnyObject
                data["timestamp"] = timestamp as AnyObject
                data["relativeAltitude"] = relativeAltitude as AnyObject
                data["pressure"] = pressure as AnyObject
                
                weakSelf!.appendToBuffer(data: data)

            }
            
            _altitudeHandler = handler
            return _altitudeHandler!
        }
    }
    
    var pedometerHandler: CMPedometerHandler {
        get {
            weak var weakSelf = self
            
            let handler: CMPedometerHandler = { pedometerData, error in
                DispatchQueue.main.async {
                    if error != nil {
                        //weakSelf!.handleError(error: error!)
                    } else {
                        let numberOfSteps = pedometerData!.numberOfSteps
                        let distance = pedometerData!.distance
                        let floorsAscended = pedometerData!.floorsAscended
                        let floorsDescended = pedometerData!.floorsDescended
                        
                        var data: [String : AnyObject] = [String : AnyObject]()
                        data["buffer"] = "numberOfSteps \(String(describing: numberOfSteps)) distance \(String(describing: distance!)) floorsAscended \(String(describing: floorsAscended!)) floorsDescended \(String(describing: floorsDescended!))\n" as AnyObject
                        data["numberOfSteps"] = numberOfSteps as AnyObject
                        data["distance"] = distance as AnyObject
                        data["floorsAscended"] = floorsAscended as AnyObject
                        data["floorsDescended"] = floorsDescended as AnyObject

                        weakSelf!.appendToBuffer(data: data)

                    }
                }
            }
            
            _pedometerHandler = handler
            return _pedometerHandler!
        }
    }
    
    var activityQueryHandler: CMMotionActivityQueryHandler {
        get {
            weak var weakSelf = self
            
            let handler: CMMotionActivityQueryHandler = { activities, error in
                DispatchQueue.main.async {
                    if error != nil {
                        //weakSelf!.handleError(error: error!)
                    } else {
                        if let motionActivities = activities {
                            for activity in motionActivities {
                                let startDate = activity.startDate
                                
                                let stationary = activity.stationary ? "YES" : "NO"
                                let walking = activity.walking ? "YES" : "NO"
                                let running = activity.running ? "YES" : "NO"
                                let automotive = activity.automotive ? "YES" : "NO"
                                let cycling = activity.cycling ? "YES" : "NO"
                                let unknown = activity.unknown ? "YES" : "NO"
                                
                                var confidence: [String : CMMotionActivityConfidence] = [String : CMMotionActivityConfidence]()
                                switch activity.confidence {
                                case CMMotionActivityConfidence.low:
                                    confidence["Low"] = activity.confidence
                                case CMMotionActivityConfidence.medium:
                                    confidence["Medium"] = activity.confidence
                                case CMMotionActivityConfidence.high:
                                    confidence["High"] = activity.confidence
                                }
                                
                                var data: [String : AnyObject] = [String : AnyObject]()
                                data["buffer"] = "startDate \(startDate) stationary \(stationary) walking \(walking) running \(running) automotive \(automotive) cycling \(cycling) unknown \(unknown) confidence \(confidence)\n" as AnyObject
                                data["stationary"] = stationary as AnyObject
                                data["walking"] = walking as AnyObject
                                data["running"] = running as AnyObject
                                data["automotive"] = automotive as AnyObject
                                data["cycling"] = cycling as AnyObject
                                data["unknown"] = unknown as AnyObject
                                data["confidence"] = confidence as AnyObject
                                
                                weakSelf!.appendToBuffer(data: data)
                            }
                        } else {
                            print("CMMotionActivityQueryHandler returned empty activity array")
                        }

                    }
                }
            }
            
            _activityQueryHandler = handler
            return _activityQueryHandler!
        }
    }
    
    var pedometerQueryHandler: CMPedometerHandler {
        get {
            weak var weakSelf = self
            
            let handler: CMPedometerHandler = { pedometerData, error in
                DispatchQueue.main.async {
                    if error != nil {
                        weakSelf!.handleError(error: error!)
                    } else {
                        let numberOfSteps = pedometerData!.numberOfSteps
                        let distance = pedometerData!.distance
                        let floorsAscended = pedometerData!.floorsAscended
                        let floorsDescended = pedometerData!.floorsDescended
                        
                        var data: [String : AnyObject] = [String : AnyObject]()
                        data["buffer"] = "numberOfSteps \(String(describing: numberOfSteps)) distance \(String(describing: distance!)) floorsAscended \(String(describing: floorsAscended!)) floorsDescended \(String(describing: floorsDescended!))\n" as AnyObject
                        data["numberOfSteps"] = numberOfSteps as AnyObject
                        data["distance"] = distance as AnyObject
                        data["floorsAscended"] = floorsAscended as AnyObject
                        data["floorsDescended"] = floorsDescended as AnyObject
                        
                        weakSelf!.appendToBuffer(data: data)
                    }
                }
            }
            
            _pedometerQueryHandler = handler
            return _pedometerQueryHandler!
        }
    }
    
    // MARK: - Availibility methods
    
    public func isMotionActivityAvailable() -> Bool {
        return CMMotionActivityManager.isActivityAvailable()
    }

    public func isStepCountingAvailable() -> Bool {
        return CMPedometer.isStepCountingAvailable()
    }

    public func isRelativeAltitudeAvailable() -> Bool {
        return CMAltimeter.isRelativeAltitudeAvailable()
    }

    public func isAuthorized() -> Bool {
        return isMotionActivityAvailable()
    }
    
    // MARK: - CMMotionActivityManager methods (Current activity)
    
    public func motionActivityManager() -> CMMotionActivityManager {
        DispatchQueue.once(token: "\(onceToken)-CMMotionActivityManager") {
            activityManager = CMMotionActivityManager()
        }
        return activityManager!
    }
    
    public func startActivityUpdates() {
        startActivityUpdates(queue: OperationQueue.main)
    }
    
    public func startActivityUpdates(queue: OperationQueue) {
        startActivityUpdates(queue: queue, handler: defaultActivityHandler())
    }
    
    public func startActivityUpdates(handler: CMMotionActivityHandler) {
        startActivityUpdates(queue: OperationQueue.main, handler: defaultActivityHandler())
    }
    
    public func startActivityUpdates(queue: OperationQueue, handler: @escaping CMMotionActivityHandler) {
        if isMotionActivityAvailable() == true {
            motionActivityManager().startActivityUpdates(to: queue, withHandler: handler)
        } else {
            var data: [String : AnyObject] = [String : AnyObject]()
            data["buffer"] = NoMotionActivityAvailable as AnyObject

            appendToBuffer(data: data)
        }
    }
    
    public func stopActivityUpdates() {
        clearBuffer()
        motionActivityManager().stopActivityUpdates()
    }
    
    func defaultActivityHandler() -> CMMotionActivityHandler {
        return activityHandler
    }

    // MARK: - CMAltimeter methods (Current activity)
    
    public func motionAltimeter() -> CMAltimeter {
        DispatchQueue.once(token: "\(onceToken)-CMAltimeter") {
            altimeter = CMAltimeter()
        }
        return altimeter!
    }
    
    public func startRelativeAltitudeUpdates() {
        startRelativeAltitudeUpdates(queue: OperationQueue.main)
    }
    
    public func startRelativeAltitudeUpdates(queue: OperationQueue) {
        startRelativeAltitudeUpdates(queue: queue, handler: defaultAltitudeHandler())
    }
    
    public func startRelativeAltitudeUpdates(queue: OperationQueue, handler: @escaping CMAltitudeHandler) {
        if isRelativeAltitudeAvailable() == true {
            motionAltimeter().startRelativeAltitudeUpdates(to: queue, withHandler: handler)
        } else {
            var data: [String : AnyObject] = [String : AnyObject]()
            data["buffer"] = NoAltitudeActivityAvaiable as AnyObject
            
            appendToBuffer(data: data)
        }
    }
    
    public func stopRelativeAltitudeUpdates() {
        clearBuffer()
        motionAltimeter().stopRelativeAltitudeUpdates()
    }
    
    func defaultAltitudeHandler() -> CMAltitudeHandler {
        return altitudeHandler
    }

    // MARK: - CMPedometer methods (Current activity)
    
    public func motionPedometer() -> CMPedometer {
        DispatchQueue.once(token: "\(onceToken)-CMPedometer") {
            pedometer = CMPedometer()
        }
        return pedometer!
    }

    public func startPedometerUpdates() {
        startPedometerUpdates(from: Date())
    }
    
    public func startPedometerUpdates(from date: Date) {
        startPedometerUpdates(from: date, handler: defaultPedometerHandler())
    }

    public func startPedometerUpdates(from date: Date, handler: @escaping CMPedometerHandler) {
        if isStepCountingAvailable() == true {
            motionPedometer().startUpdates(from: date, withHandler: handler)
        }  else {
            var data: [String : AnyObject] = [String : AnyObject]()
            data["buffer"] = NoPedometerActivityAvailable as AnyObject
            
            appendToBuffer(data: data)
        }
    }
    
    public func stopPedometerUpdates() {
        clearBuffer()
        motionPedometer().stopUpdates()
    }

    func defaultPedometerHandler() -> CMPedometerHandler {
        return pedometerHandler
    }
    
    // MARK: - CMMotionActivity Query methods (Historical activity)
    
    public func queryActivity() {
        queryActivity(from: Date())
    }
    
    public func queryActivity(from startDate: Date) {
        queryActivity(from: startDate, to: Date())
    }

    public func queryActivity(from startDate: Date, handler: @escaping CMMotionActivityQueryHandler) {
        queryActivity(from: startDate, to: Date(), to: OperationQueue.main, handler: handler)
    }
    
    public func queryActivity(from startDate: Date, to endDate: Date) {
        queryActivity(from: startDate, to: endDate, to: OperationQueue.main)
    }

    public func queryActivity(from startDate: Date, to endDate: Date, to queue: OperationQueue) {
        queryActivity(from: startDate, to: endDate, to: queue, handler: defaultActivityQueryHandler())
    }

    public func queryActivity(from startDate: Date, to endDate: Date, handler: @escaping CMMotionActivityQueryHandler) {
        queryActivity(from: startDate, to: endDate, to: OperationQueue.main, handler: handler)
    }

    public func queryActivity(from startDate: Date, to endDate: Date, to queue: OperationQueue, handler: @escaping CMMotionActivityQueryHandler) {
        if isMotionActivityAvailable() == true {
            motionActivityManager().queryActivityStarting(from: startDate, to: endDate, to: queue, withHandler: handler)
        } else {
            var data: [String : AnyObject] = [String : AnyObject]()
            data["buffer"] = "This app is not authorized for M7\nNo motion activity is available" as AnyObject
            
            appendToBuffer(data: data)
        }
    }
    
    func defaultActivityQueryHandler() -> CMMotionActivityQueryHandler {
        return activityQueryHandler
    }

    // MARK: - CMPedometer Query methods (Historical activity)
    
    public func queryPedometer() {
        queryPedometer(from: Date())
    }
    
    public func queryPedometer(from startDate: Date) {
        queryPedometer(from: startDate, to: Date())
    }
    
    public func queryPedometer(from startDate: Date, handler: @escaping CMPedometerHandler) {
        queryPedometer(from: startDate, to: Date(), handler: handler)
    }
    
    public func queryPedometer(from startDate: Date, to endDate: Date) {
        queryPedometer(from: startDate, to: endDate, handler: defaultPedometerQueryHandler())
    }
    
    public func queryPedometer(from startDate: Date, to endDate: Date, handler: @escaping CMPedometerHandler) {
        if isStepCountingAvailable() == true {
            motionPedometer().queryPedometerData(from: startDate, to: endDate, withHandler: handler)
        } else {
            var data: [String : AnyObject] = [String : AnyObject]()
            data["buffer"] = "This app is not authorized for M7\nNo pedometer activity is available" as AnyObject
            
            appendToBuffer(data: data)
        }
    }
    
    func defaultPedometerQueryHandler() -> CMPedometerHandler {
        return pedometerQueryHandler
    }
    
    // MARK: - Utility methods
    
    public func appendToBuffer(data: [String : AnyObject]) {
        var data = data
        let newBufferValue: String = data["buffer"] as! String
        buffer += newBufferValue
        data["buffer"] = buffer as AnyObject
        updateBuffer(data: data)
    }
    
    public func clearBuffer() {
        buffer = ""
    }
    
    public func date(from string: String) -> Date? {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        return formatter.date(from: string)
    }
    
    public func string(from date: Date) -> String? {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        return formatter.string(from: date)
    }

    func handleError(error: Error) {
        var data: [String : AnyObject] = [String : AnyObject]()
        data["buffer"] = error.localizedDescription as AnyObject
        
        appendToBuffer(data: data)
    }
    
}

extension CoreMotionController: CoreMotionControllerDelegate {
    
    public func updateBuffer(data: [String : AnyObject]) {
        delegate?.updateBuffer(data: data)
    }
}
