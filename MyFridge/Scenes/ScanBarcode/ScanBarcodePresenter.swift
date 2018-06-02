//
//  ScanBarcodePresenter.swift
//  MyFridge
//
//  Created by Lars Dahl on 01.06.2018.
//  Copyright (c) 2018 Lars Dahl. All rights reserved.
//

import UIKit

protocol ScanBarcodePresentationLogic {
    func showItem(response: ScanBarcode.Response)
    func itemSaved()
}

class ScanBarcodePresenter: ScanBarcodePresentationLogic {
    weak var viewController: ScanBarcodeDisplayLogic?
  
    func showItem(response: ScanBarcode.Response) {
        var viewModel = ScanBarcode.ViewModel()
        
        viewModel.itemName = response.data.itemName
        viewModel.barcodeValue = response.data.barcode
        viewModel.quantity = response.data.quantity
        
        DispatchQueue.main.async {
            self.viewController?.displayItem(viewModel: viewModel)
        }
    }
    
    func itemSaved() {
        DispatchQueue.main.async {
            self.viewController?.itemSaved()
        }
    }
}
