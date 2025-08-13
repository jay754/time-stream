//
//  NibInstantiable.swift
//  FlexiPass
//
//  Created by appssemble on 12.05.2021.
//

import UIKit

protocol NibInstantiable { }

extension UIView: NibInstantiable { }
extension UIViewController: NibInstantiable { }

extension NibInstantiable {
    /// Loads the `UIView` from a .xib file
    ///
    /// - Parameters:
    ///   - name: A name of the `xib` file.
    ///   - bundle: Bundle name where the `xib` file is stored.
    ///   - owner: See `instantiate(withOwner:, options:)` in `UINib` interface.
    ///   - options: See `instantiate(withOwner:, options:)` in `UINib` interface.
    /// - Returns: UIView.
    ///
    /// EXAMPLE:
    /// ```
    /// let myView = MyView.loadFromNib()
    /// // or:
    /// let myView: MyView = .loadFromNib()
    /// ```
    static func loadFromNib(name: String? = nil,
                           bundle: Bundle? = nil,
                           owner: AnyObject? = nil,
                           options: [UINib.OptionsKey: Any]? = nil) -> Self {
        
        func instanceFromNib<T: NibInstantiable>() -> T {
            
            let nibName = name ?? defaultNibName()
            let nib = UINib(nibName: nibName, bundle: bundle)
            guard let view = nib
                .instantiate(withOwner: owner, options: options)
                .compactMap({ $0 as? T })
                .first else {
                preconditionFailure("Could not instantiate view: \(self) from nib named: \(nibName) in bundle: \(String(describing: bundle))")
            }

            return view
        }

        return instanceFromNib()
    }
    
    static func defaultNibName() -> String {
        return String(describing: self)
    }
}

