//
//  BLETableViewController.swift
//  ATEC BOT
//
//  Created by Saleem Hadad on 28/01/2017.
//  Copyright © 2017 Saleem Hadad. All rights reserved.
//

import UIKit
import CoreBluetooth

//MARK: - BLE Controller
class BLETableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    // MARK: - Variables
    var peripherals: [Peripheral] = []
    var selectedPeripherals: CBPeripheral?
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - System's Functionality
    override func viewDidLoad() {
        super.viewDidLoad()
        serial.delegate = self
        self.tableView.separatorColor = .none
        serial.disconnect()
        self.startScanning()
    }
    
    // MARK: - Table functionality
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BLECell", for: indexPath) as! BLECell
        cell.peripheral = peripherals[indexPath.row]
        return cell
    }
    
    //Connect to selected BLE when row is selected of disconnecte it
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        serial.stopScan()
        let ble = peripherals[indexPath.row].peripheral
        if !peripherals[indexPath.row].connected {
            selectedPeripherals = ble
            serial.connectToPeripheral(peripheral: ble)
            self.peripherals[indexPath.row].connected = true
            print("connecting")
        }else{
            serial.disconnect()
            print("disConnecting")
            self.peripherals[indexPath.row].connected = false
        }
        self.tableView.reloadData()
    }
    
    // MARK: - custom functions
    func startScanning() {
        serial.startScan()
        self.setTimer(seconds: 10, selector: #selector(BLETableViewController.scanTimeOut), repeats: false)
    }
    
    @objc func scanTimeOut() {
        serial.stopScan()
    }
    
    ///Set timer to fire one method after **seconds** seconds.
    private func setTimer(seconds:TimeInterval,selector: Selector, repeats: Bool){
        Timer.scheduledTimer(timeInterval: seconds, target: self, selector: selector, userInfo: nil, repeats: repeats)
    }
    
    //DisConnecte the BLE and dismiss the controller
    @IBAction func stopSearching(_ sender: UIBarButtonItem) {
        if #available(iOS 10.0, *) {
            serial.stopScan()
            serial.disconnect()
        }
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - BLE Delegate
extension BLETableViewController: BLEDelegate{
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) {
        print("serialDidDiscoverPeripheral")
        // check whether it is a duplicate
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        let theRSSI = RSSI?.floatValue ?? 0.0
        let status: Bool  = peripheral.state == CBPeripheralState.connected
        let robot = Peripheral(peripheral: peripheral, RSSI: theRSSI, connected: status)
        peripherals.append(robot)
        peripherals.sort { $0.RSSI < $1.RSSI }
        tableView.reloadData()
    }
    
    func serialDidConnect(peripheral: CBPeripheral){
        //perform the seque
        self.dismiss(animated: true, completion: nil)
    }
    
    func serialDidDisconnect(peripheral: CBPeripheral, error: NSError?){}
    
    func serialIsReady(peripheral: CBPeripheral) {}
    
    func serialDidReceiveString(message: String) {}
    
    func serialDidChangeState(newState: CBManagerState) {
        if newState == .poweredOn {
            self.startScanning()
        }
    }
}
