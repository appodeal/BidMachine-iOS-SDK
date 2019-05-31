//
//  RequestVC.swift
//  Sample
//
//  Created by Stas Kochkin on 14/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine
import BidMachine.ParalellBidding

class RequestVC <T:BDMRequest>: DataTableViewController {
    open var onUpdateRequest:((T?)->())?
   
    private var pricefloors: [BDMPriceFloor?] = []
    private var request: T?
    
    override func setupSections() {
        addPricefloorsSection()
        addUserTargetingSection()
        addLocationTargetingSection()
        addAppTargetingSection()
        addAdResttrictionsSection()
        addSdkRestrictionsSection()
    }
    
    open func add(_ request:T) {
        self.request = request
    }
    
    @IBAction private func closeTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func saveAndCloseTouched(_ sender: Any) {
        request.flatMap { $0.priceFloors = pricefloors.map{$0 ?? BDMPriceFloor()} }
        request.flatMap { $0.targeting = SdkContext.shared.targeting }
        onUpdateRequest?(request)
        SdkContext.shared.synchronise()
        dismiss(animated: true, completion: nil)
    }
}

extension RequestVC {
    func addPricefloorsSection() {
        let _ = addSection { section in
            section.title = "Auction"
            section.state = .expanded
            for idx in 0...self.pricefloors.count + 3 {
                if (idx < self.pricefloors.count) {
                    let _ = section.addRow { [unowned self] row in
                        let pricefloor = self.pricefloors[idx]
                        let cell: DataTableViewCell = self.tableView.dequeueCell()
                        cell.entity = DataEntity(info: "Pricefloor", type:.string, value:pricefloor?.toString())
                        cell.binding = { self.pricefloors.insert($0.value!.toPricefloor(), at: idx) }
                        row.cell = cell
                    }
                } else {
                    let _ = section.addRow { [unowned self] row in
                        let cell: DataTableViewCell = self.tableView.dequeueCell()
                        cell.entity = DataEntity(info: "Pricefloor", type:.string, value:nil)
                        cell.binding = { self.pricefloors.append($0.value?.toPricefloor()) }
                        row.cell = cell
                    }
                }
            }
        }
    }
}

private extension String {
    func toPricefloor() -> BDMPriceFloor {
        let pricefloor = BDMPriceFloor()
        pricefloor.value = self.components(separatedBy: ":").first.map { NSDecimalNumber(string:$0) } ?? 0.01
        pricefloor.id = self.components(separatedBy: ":").last  ?? UUID().uuidString
        return pricefloor
    }
}

private extension BDMPriceFloor {
    func toString() -> String {
        return "\(self.value):\(self.id)"
    }
}

class BannerRequestVC: RequestVC <BDMBannerRequest> {
    
}

class InterstitialRequestVC: RequestVC <BDMInterstitialRequest> {
    
}

class RewardedRequestVC: RequestVC <BDMRewardedRequest> {
    
}
