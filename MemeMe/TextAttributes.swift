//
//  TextAttributes.swift
//  MemeMe
//
//  Created by Phizer Cost on 5/26/18.
//  Copyright © 2018 Phizer Cost. All rights reserved.
//

import Foundation

class TextAttributes {
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "Impact", size: 20)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3.5]

}
