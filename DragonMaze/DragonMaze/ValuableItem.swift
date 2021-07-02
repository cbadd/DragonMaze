//
//  ValuableItem.swift
//  DragonMaze
//
//  Created by Александр Строганов on 01.07.2021.
//

import Foundation
import UIKit

//Разновидность предмета, со значением (количество единиц золота)
class ValuableItem: Item {
    var itemValue: Int?
    var valueLabel: UILabel?
    
    init(texture: String, value: Int) {
        itemValue = value
        super.init(texture: texture)
        
        //К изображению предмета добалется надпись со значением
        valueLabel = UILabel.init(frame: CGRect.init(x: self.frame.size.height/2, y: -self.frame.size.width/2, width: self.frame.size.width, height: self.frame.size.height))
        valueLabel?.textAlignment = NSTextAlignment.center
        valueLabel?.text = "\(itemValue ?? 0)"
        self.addSubview(valueLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
}
