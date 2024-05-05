//
//  Extentions.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/5/24.
//

import Foundation
import UIKit

//MARK: UI Image View
extension UIImageView {
    func setImage(from url: URL?) {
        guard let url = url else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _ , error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            task.resume()
        }
        
       
    }
}




//MARK: String
extension String {
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
}

//MARK: -Date Formatter
extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = "YYYY-MM-dd"
        return formater
    }()
    
    static let prettyDateFormatter: DateFormatter = {
        let formater = DateFormatter()
        formater.dateStyle = .medium
        return formater
    }()
}

//MARK: - Add Subview
extension UIView {
    /**
     Adds multiple subviews to the current view.
     - Parameter view: A variable number of UIView objects to be added as subviews.
     The `...` after the `UIView` parameter in the function signature indicates that the parameter accepts a variadic number of arguments of type `UIView`. This means you can pass in multiple `UIView` objects separated by commas, and they will be treated as an array of `UIView` objects inside the function. This allows you to conveniently pass any number of views to the `addSubviews` function without having to explicitly define an array.
     */
    func addSubviews(_ view: UIView...){
        // Iterates through each UIView passed as a parameter and adds it as a subview
        view.forEach {
            self.addSubviews($0)
        }
    }

    
}

//MARK: Framing
extension UIView {
    var width : CGFloat {
        frame.size.width
    }
    
    var height : CGFloat {
        frame.size.height
    }
    
    var left : CGFloat {
        frame.origin.x
    }
    
    var right : CGFloat {
        left + width
    }
    
    var top : CGFloat {
        frame.origin.y
    }
    
    var bottom : CGFloat {
        top + height
    }
}
