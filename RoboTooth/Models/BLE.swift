import Foundation
import CoreBluetooth

/// Global serial handler
@available(iOS 10.0, *)
var serial: BLE!

// MARK: - Protocol
// Delegate functions
protocol BLEDelegate {
    // Called when the state of the CBCentralManager changes
    @available(iOS 10.0, *)
    func serialDidChangeState(newState: CBManagerState)
    // Called when a peripheral disconnected
    func serialDidDisconnect(peripheral: CBPeripheral, error: NSError?)
    // Called when peripheral send data as String
    func serialDidReceiveString(message: String)
    // Called when peripheral send data
    func serialDidReceiveBytes(bytes: [UInt8])
    func serialDidReceiveData(data: NSData)
    // Called when discovering BLEs
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?)
    // Called when connecting to BLE
    func serialDidConnect(peripheral: CBPeripheral)
    // Called when failed to connect to specific BLE
    func serialDidFailToConnect(peripheral: CBPeripheral, error: NSError?)
    // Called when the connection is ready
    func serialIsReady(peripheral: CBPeripheral)
}

extension BLEDelegate {
    func serialDidReceiveString(message: String) {}
    func serialDidReceiveBytes(bytes: [UInt8]) {}
    func serialDidReceiveData(data: NSData) {}
    func serialDidReadRSSI(rssi: NSNumber) {}
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) {}
    func serialDidConnect(peripheral: CBPeripheral) {}
    func serialDidFailToConnect(peripheral: CBPeripheral, error: NSError?) {}
    func serialIsReady(peripheral: CBPeripheral) {}
}

@available(iOS 10.0, *)
class BLE: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: - Variables
    // The delegate object the BluetoothDelegate methods will be called upon
    var delegate: BLEDelegate!
    
    // The bluetooth serial handler
    var centralManager: CBCentralManager!
    
    // The peripheral
    var pendingPeripheral: CBPeripheral?
    
    // The connected peripheral
    var connectedPeripheral: CBPeripheral?
    
    // The characteristic
    weak var writeCharacteristic: CBCharacteristic?
    
    // The state of the bluetooth manager (use this to determine whether it is on or off or disabled etc)
    @available(iOS 10.0, *)
    var state: CBManagerState { get { return centralManager.state } }
    
    // Whether this serial is ready to send and receive data
    var isReady: Bool {
        get {
            return centralManager.state == .poweredOn && connectedPeripheral != nil && writeCharacteristic != nil
        }
    }
    // Some BLE need to be withResponse //see the DataSheet of the BLE of by testing it
    var writeType: CBCharacteristicWriteType = .withoutResponse
    
    // MARK: - Custom Functions
    // init
    required init(delegate: BLEDelegate) {
        super.init()
        self.delegate = delegate
        print("creating BLE class")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Start scanning for peripherals
    func startScan() {
        guard centralManager.state == .poweredOn else { return }
        // start scanning for peripherals with correct service UUID
        print("scanning")
        let uuid = CBUUID(string: "FFE0")
        centralManager.scanForPeripherals(withServices: [uuid], options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
    
        
        // retrieve peripherals that are already connected
        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [uuid])
        for peripheral in peripherals {
            print(peripheral)
            delegate.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: nil)
        }
    }
    
    // Stop scanning for peripherals
    func stopScan() {
        centralManager.stopScan()
        print("stop scanning")
    }
    
    // Try to connect to the given peripheral
    func connectToPeripheral(peripheral: CBPeripheral) {
        pendingPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    /// **Disconnect** from the connected peripheral or stop connecting to it
    func disconnect() {
        if connectedPeripheral != nil {
            centralManager.cancelPeripheralConnection(self.connectedPeripheral!)
            print("disconnected the prev ble")
        } else if let peripheral = pendingPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            print("disconnected the prev ble")
        }
    }
    
    // The didReadRSSI delegate function will be called after calling this function
    func readRSSI() {
        guard isReady else { return }
        connectedPeripheral!.readRSSI()
    }
    
    // Send a string to the device
    func sendMessageToDevice(message: String) {
        guard isReady else { return }
        if let data = message.data(using: String.Encoding.utf8) {
            print("sendMessageToDevice")
            connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
        }
    }
    
    /// Send an array of bytes to the device
    func sendBytesToDevice(bytes: [UInt8]) {
        guard isReady else { return }
        let data = NSData(bytes: bytes, length: bytes.count)
        connectedPeripheral!.writeValue(data as Data, for: writeCharacteristic!, type: writeType)
    }
    
    /// Send data to the device
    func sendDataToDevice(data: NSData) {
        guard isReady else { return }
        connectedPeripheral!.writeValue(data as Data, for: writeCharacteristic!, type: writeType)
    }
    
    
    //MARK: - CBCentralManagerDelegate functions
    // didDiscoverPeripheral called when the bluetooth found any ble device
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        delegate.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: RSSI)
    }
    // Called when the phone is connected to ble
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        pendingPeripheral = nil
        connectedPeripheral = peripheral
        // send notification to the delegate
        print("connected")
        delegate.serialDidConnect(peripheral: peripheral)
        // Get the service then the characteristic of this service and subscript to it.
        peripheral.discoverServices([BLEParameters.Service])
    }
    // Called when disconnecting the peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        pendingPeripheral = nil
        // send notification to the delegate
        delegate.serialDidDisconnect(peripheral: peripheral, error: error as NSError?)
    }
    // Called when the connection is failed
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        pendingPeripheral = nil
        // send notification to the delegate
        delegate.serialDidFailToConnect(peripheral: peripheral, error: error as NSError?)
    }
    // this function won't be called if BLE is turned off while connected
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        connectedPeripheral = nil
        pendingPeripheral = nil
        // send notification to the delegate
        delegate.serialDidChangeState(newState: central.state)
    }
    
    //MARK: - CBPeripheralDelegate functions
    // Called when
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // discover the 0xFFE1 characteristic for all services
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([CBUUID(string: "FFE1")], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            if characteristic.uuid == CBUUID(string: "FFE1") {
                // subscribe to this value
                peripheral.setNotifyValue(true, for: characteristic)
                writeCharacteristic = characteristic
                delegate.serialIsReady(peripheral: peripheral)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        let data = characteristic.value
        guard data != nil else { return }
        
        // notify the delegate with data
        delegate.serialDidReceiveData(data: data! as NSData)
        
        if let str = String(data: data!, encoding: String.Encoding.utf8) {
            // notify the delegate with string
            delegate.serialDidReceiveString(message: str)
        } else {
            print("invalid string!")
        }
    }
}
