//
//  ScanBarcodeModels.swift
//  MyFridge
//
//  Created by Lars Dahl on 01.06.2018.
//  Copyright (c) 2018 Lars Dahl. All rights reserved.
//

import UIKit

enum ScanBarcode {
    
    struct ItemData {
        var itemName: String = ""
        var barcode: String = ""
        var quantity: Int = 0
    }
  
    struct Request {
        var data: ItemData = ItemData()
    }
    
    struct Response {
        var data: ItemData = ItemData()
    }
    
    struct ViewModel {
        var itemName: String = ""
        var barcodeValue: String = ""
        var quantity: Int = 0
    }
}
