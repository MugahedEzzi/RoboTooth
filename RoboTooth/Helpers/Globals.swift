import UIKit
import Foundation
import CoreBluetooth

/*
 IMPORTANT COMMANT IN ARDUINO:
 AT+UUID sets the service while AT+CHAR sets the characteristic
 By defualt:
 Service UUID = FFE0
 Characteristic = FFE1 //Read & Write & Notify
*/
struct BLEParameters {
    static let Service = CBUUID(string:"FFE0")
    static let Characteristic = CBUUID(string:"FFE1")
}

public struct Peripheral {
    var peripheral: CBPeripheral
    var RSSI: Float
    var connected: Bool
}
