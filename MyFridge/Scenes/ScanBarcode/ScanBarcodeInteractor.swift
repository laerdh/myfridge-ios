//
//  ScanBarcodeInteractor.swift
//  MyFridge
//
//  Created by Lars Dahl on 01.06.2018.
//  Copyright (c) 2018 Lars Dahl. All rights reserved.
//

import UIKit

protocol ScanBarcodeBusinessLogic {
    func saveItem(request: ScanBarcode.Request)
    func handleBarcodeFound(request: ScanBarcode.Request)
}

protocol ScanBarcodeDataStore {
    
}

class ScanBarcodeInteractor: ScanBarcodeBusinessLogic, ScanBarcodeDataStore {
    
    var presenter: ScanBarcodePresentationLogic?
    var worker: ScanBarcodeWorker?
    
    func saveItem(request: ScanBarcode.Request) {
        worker = ScanBarcodeWorker()
        worker?.addItem(itemName: request.data.itemName, barcode: request.data.barcode, quantity: request.data.quantity)
        presenter?.itemSaved()
    }
  
    func handleBarcodeFound(request: ScanBarcode.Request) {
        worker = ScanBarcodeWorker()
        let barcode = request.data.barcode
        var response = ScanBarcode.Response()
        response.data.barcode = barcode
        
        if (!barcode.isEmpty) {
            worker?.fetchItem(barcode: barcode) { fetchedResponse in
                if let fetchedResponse = fetchedResponse {
                    self.presenter?.showItem(response: fetchedResponse)
                } else {
                    self.presenter?.showItem(response: response)
                }
            }
        } else {
            presenter?.showItem(response: response)
        }
  }
}
