//
//  ScanBarcodeWorker.swift
//  MyFridge
//
//  Created by Lars Dahl on 01.06.2018.
//  Copyright (c) 2018 Lars Dahl. All rights reserved.
//

import UIKit
import Firebase

class ScanBarcodeWorker {
    var databaseRef: DatabaseReference?
    
    init() {
        databaseRef = Database.database().reference()
    }
    
    func fetchItem(barcode: String, completion: @escaping (ScanBarcode.Response?) -> Void) {
        var response = ScanBarcode.Response()
        response.data.barcode = barcode
        
        let itemsQuery = databaseRef?.child("items").queryOrderedByKey()
        itemsQuery?.observeSingleEvent(of: .value, with: { snapshot in
            var itemFound = false
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let value = item.value as? NSDictionary
                if (item.key == barcode) {
                    response.data.itemName = value?["itemName"] as? String ?? ""
                    response.data.quantity = value?["quantity"] as? Int ?? 0
                    
                    itemFound = true
                    completion(response)
                }
            }
            
            if (!itemFound) {
                completion(nil)
            }
        })
    }
    
    func addItem(itemName: String, barcode: String, quantity: Int) {
        self.databaseRef?.child("items").child(barcode).setValue(["itemName": itemName, "quantity": quantity])
    }
}
