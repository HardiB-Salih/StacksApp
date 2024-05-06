//
//  Extentions.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/5/24.
//

import Foundation
import UIKit

//MARK: NOTIFICATION
extension Notification.Name {
    static let didAddToWatchlist = Notification.Name("didAddToWatchlist")
}

//MARK: Number Formatter
extension NumberFormatter {
    static let percentageFormatter : NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let numberFormatter : NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}



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
    
    static func persentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentageFormatter
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    static func formatted(number: Double) -> String {
        let formatter = NumberFormatter.numberFormatter
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
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
//    func addSubviews(_ view: UIView...){
//        // Iterates through each UIView passed as a parameter and adds it as a subview
//        view.forEach {
//            self.addSubviews($0)
//        }
//    }

    
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
