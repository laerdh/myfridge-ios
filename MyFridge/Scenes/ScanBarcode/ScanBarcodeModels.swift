//
//  ScanBarcodeModels.swift
//  MyFridge
//
//  Created by Lars Dahl on 01.06.2018.
//  Copyright (c) 2018 Lars Dahl. All rights reserved.
//

import UIKit

enum ScanBarcode {
    
    struct BarcodeData {
        var value: String = ""
    }
  
    struct Request {
        var data: BarcodeData = BarcodeData()
    }
    
    struct Response {
        var data: BarcodeData = BarcodeData()
    }
    
    struct ViewModel {
        var barcodeValue: String = ""
    }
}
