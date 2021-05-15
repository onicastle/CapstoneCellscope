//
//  BluetoothSerialDelegate.swift
//  CapstoneCellscope
//
//  Created by Oni on 5/1/21.
//

import Foundation
//
//  SwiftUIView.swift
//  BluetoothTester
//
//  Created by Oni on 5/1/21.
//

import SwiftUI
import CoreBluetooth
class SerialController: BluetoothSerialDelegate{
    
    var serial: BluetoothSerial!
    
    init() {
        serial = BluetoothSerial(delegate: self)
    }
    
    
    func serialDidChangeState() {
        if serial.centralManager.state != .poweredOn{
            print("Serial State Changed")
        }
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("Serial Disconnected")
    }
}


