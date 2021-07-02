//
//  Item.swift
//  DragonMaze
//
//  Created by Александр Строганов on 27.06.2021.
//

import UIKit

//Класс Предмет, подкласс UIImageView с позицией внутри комнаты, текстурой (она же название предмета) и описанием из ItemsDescription.swift
class Item: UIImageView {
    var position: CGPoint?
    var texture: String?
    var useDesc: String?

    
    init(texture: String) {
        self.texture = texture
        self.useDesc = ItemsDescriptions.descDict[texture]
        super.init(image: UIImage(named: texture))
        self.isUserInteractionEnabled = true
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
}
