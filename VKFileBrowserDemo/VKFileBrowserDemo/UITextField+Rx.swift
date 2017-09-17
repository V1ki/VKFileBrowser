//
//  UITextField+Rx.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/17.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class RxTextFieldDelegateProxy : DelegateProxy , UITextFieldDelegate , DelegateProxyType {
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let tf = object as! UITextField
        return tf.delegate
    }
    
    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let tf = object as! UITextField
        tf.delegate = delegate as? UITextFieldDelegate
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
extension Reactive where Base: UITextField {
    public var delegate : DelegateProxy {
        return RxTextFieldDelegateProxy.proxyForObject(base)
    }
    
    public var shouldReturn : ControlEvent<Void> {
       return controlEvent(.editingDidEndOnExit)
        
    }
}
