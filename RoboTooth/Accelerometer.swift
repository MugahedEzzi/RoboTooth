//
//  Accelerometer.swift
//  ATEC BOT
//
//  Created by Saleem Hadad on 28/01/2017.
//  Copyright © 2017 Saleem Hadad. All rights reserved.
//

import UIKit
import Foundation
import CoreMotion

public struct AccelerometerValues {
    var x:Int
    var y:Int
    
    init(x:Int,y:Int){
        self.x = x
        self.y = y
    }
}

extension AccelerometerDelegate{
    //optional methods
    func didStartAccelerometer() {}
    func didStopAccelerometer() {}
}

protocol AccelerometerDelegate: class {
    //required methods
    func didUpdateAccelerometerValues(values: AccelerometerValues)
    //optional methods
    func didStartAccelerometer()
    func didStopAccelerometer()
}

class Accelerometer: NSObject, UIAccelerometerDelegate {
    //MARK: - variables
    private var motionManager: CMMotionManager!
    private var ready: Bool {
        get{
            return motionManager.isAccelerometerAvailable
        }
    }
    private var delegate:AccelerometerDelegate?
    
    var updateRate: TimeInterval = 2 {
        didSet{
            if ready {
                motionManager.accelerometerUpdateInterval = updateRate
            }
        }
    }
    var active: Bool { get { return motionManager.isAccelerometerActive } }
    
    //MARK: - init
    required init(delegate: AccelerometerDelegate) {
        super.init()
        self.delegate = delegate
        self.motionManager = CMMotionManager()
    }
    
    //MARK: - private methods
    private func outputAccelerometerData(accelerometer : CMAcceleration){
        ///calculate the angle of x axis rotation by applying simple algorithm
        var x = atan2(accelerometer.x, sqrt(pow(accelerometer.y, 2)+pow(accelerometer.z, 2)))
        ///calculate the angle of y axis rotation by applying simple algorithm
        var y = atan2(accelerometer.y, sqrt(pow(accelerometer.x, 2)+pow(accelerometer.z, 2)))
        
        //converting g unit to degree
        x = x.toDegree()
        y = y.toDegree()
        //send message to the delegate
        if delegate != nil {
            delegate?.didUpdateAccelerometerValues(values: AccelerometerValues(x: Int(x), y: Int(y)))
        }
    }
    
    //public API
    internal func start(){
        //start the Accelerometer
        updateRate = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if error == nil {
                self.outputAccelerometerData(accelerometer: data!.acceleration)
            }
        }
        //send message to the delegate
        if delegate != nil {
            delegate?.didStartAccelerometer()
        }
    }
    
    internal func stop() {
        //check first if the accelerometer is active first then turn it off
        if(active){
            motionManager.stopAccelerometerUpdates()
            //send message to the delegate
            if delegate != nil {
                delegate?.didStopAccelerometer()
            }
        }
    }
}
