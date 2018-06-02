//
//  ScanBarcodeInteractor.swift
//  MyFridge
//
//  Created by Lars Dahl on 01.06.2018.
//  Copyright (c) 2018 Lars Dahl. All rights reserved.
//

import UIKit

protocol ScanBarcodeBusinessLogic {
    func handleBarcodeFound(request: ScanBarcode.Request)
}

protocol ScanBarcodeDataStore {
    // var name: String { get set }
}

class ScanBarcodeInteractor: ScanBarcodeBusinessLogic, ScanBarcodeDataStore {
    var presenter: ScanBarcodePresentationLogic?
    var worker: ScanBarcodeWorker?
  
    // MARK: Do something
  
    func handleBarcodeFound(request: ScanBarcode.Request) {
        var response = ScanBarcode.Response()
        response.data.value = request.data.value
    
        presenter?.showBarcode(response: response)
  }
}
