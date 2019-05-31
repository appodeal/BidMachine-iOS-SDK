//
//  Utilities.swift
//  Sample
//
//  Created by Stas Kochkin on 11/12/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import Foundation
import os.log

func __print(_ module: String, function: String = #function) {
    guard SdkContext.shared.appConfiguration.callbackLog else {
        return
    }
    
    NSLog("[Callback][%@] Recieve method: %@", module, function)
}
