//
//  ViewController.swift
//  Bomber
//
//  Created by Saleem Hadad on 13/01/2018.
//  Copyright © 2018 Binary Torch. All rights reserved.
//

import UIKit
import Foundation
import CoreMotion
import CoreBluetooth
import SimpleAnimation

class HomeViewController: UIViewController {
    // MARK: properties
    private var accelerometer: Accelerometer!
    private var isReady: Bool = false {
        didSet{
            guard isReady else {
                bombButtonOutlet.isEnabled = true
                rightButtonOutlet.isEnabled = true
                topButtonOutlet.isEnabled = true
                bottomButtonOutlet.isEnabled = true
                leftButtonOutlet.isEnabled = true
                accelerometer.start()
                return
            }
            
            bombButtonOutlet.isEnabled = false
            rightButtonOutlet.isEnabled = false
            topButtonOutlet.isEnabled = false
            bottomButtonOutlet.isEnabled = false
            leftButtonOutlet.isEnabled = false
            accelerometer.stop()
        }
    }
    
    // MARK: outlines
    @IBOutlet weak var bombButtonOutlet: UIButton!
    @IBOutlet weak var rightButtonOutlet: UIButton!
    @IBOutlet weak var topButtonOutlet: UIButton!
    @IBOutlet weak var bottomButtonOutlet: UIButton!
    @IBOutlet weak var leftButtonOutlet: UIButton!
    @IBOutlet weak var angleLabelOutlet: UILabel!
    
    //MARK: - life cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        serial = BLE(delegate: self)
        serial.writeType = .withoutResponse
        accelerometer = Accelerometer(delegate: self)
        accelerometer.updateRate = 1.0
        accelerometer.start()
        isReady = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isReady = serial.isReady
    }
    
    //MARK: - Actions
    @IBAction func disconnectBLE(_ sender: UIButton) {
        guard serial.isReady else { return }
        sender.popIn()
        serial.disconnect()
    }
    
    @IBAction func bombAction(_ sender: UIButton) {
        guard serial.isReady else { return }
        sender.popIn()
        serial.sendBytesToDevice(bytes: [95])
    }
   
    @IBAction func rightAction(_ sender: UIButton) {
        guard serial.isReady else { return }
        sender.popIn()
        serial.sendBytesToDevice(bytes: [80])
    }
    
    @IBAction func forwardAction(_ sender: UIButton) {
        guard serial.isReady else { return }
        sender.popIn()
        serial.sendBytesToDevice(bytes: [85])
    }
    
    @IBAction func backwardAction(_ sender: UIButton) {
        guard serial.isReady else { return }
        sender.popIn()
        serial.sendBytesToDevice(bytes: [90])
    }
    
    @IBAction func leftAction(_ sender: UIButton) {
        guard serial.isReady else { return }
        sender.popIn()
        serial.sendBytesToDevice(bytes: [75])
    }
    
    @IBAction func stopAction(_ sender: UIButton) {
        guard serial.isReady else { return }
        serial.sendBytesToDevice(bytes: [100])
    }
}

extension HomeViewController: AccelerometerDelegate {
    func didUpdateAccelerometerValues(values: AccelerometerValues) {
        let xAxis = UInt8(abs(values.x))
        if xAxis > 20 && xAxis < 70{
            angleLabelOutlet.text = "Angle: \(xAxis)º"
            
            if(serial.isReady) {
                serial.sendBytesToDevice(bytes: [xAxis])
            }
        }
    }
}

extension HomeViewController: BLEDelegate {
    func serialDidDisconnect(peripheral: CBPeripheral, error: NSError?) {
        isReady = false
    }
    
    func serialDidConnect(peripheral: CBPeripheral) {
        isReady = true
    }
    
    func serialDidFailToConnect(peripheral: CBPeripheral, error: NSError?) {
        isReady = false
    }
    
    func serialDidChangeState(newState: CBManagerState) {
        if newState == .poweredOff {
            isReady = false
        }
    }
}
