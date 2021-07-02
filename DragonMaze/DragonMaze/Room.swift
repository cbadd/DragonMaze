//
//  Room.swift
//  DragonMaze
//
//  Created by Александр Строганов on 27.06.2021.
//

import Foundation
import UIKit

//Класс комната - составляющая часть лабиринта. Имеет до 4х стен и может иметь предметы
class Room {
    var neighbors: [Int:Room] = [:]         //Словарь с соседними комнатами, расположение 0 - справа, 1 - сверху, 2 - слева, 3 - снизу
    var walls = [true, true, true, true]    //Наличие стен, индексы направлений такие же. Изначально все стены есть, убираются по походу создания лабиринта
    var isVisitedByMazeInit = false         //Отмечает, что комната посещалась при создании лабиринта в классе Maze
    var isVisitedByPlayer = false           //Отмечает, что комната посещалась игроком и может отображаться на мини карте
    let coorX: Int                          //Координаты в лабиринте
    let coorY: Int
    var myViewOnMap: UIView!                //UIView, который будет добавлен на мини карту
    var items: [Item] = []                  //Массив с предметами, находящимися в комнате
    var depthInMaze: Int?                   //Удаленность от начальной комнаты
    
    //Создаем комнату с координатами в лабиринте
    init(x: Int, y: Int) {
        coorX = x
        coorY = y
    }
    
    //Добавляем соседа с определенной стороны
    func addNeighbor(neighbor: Room, for position: Int) {
        neighbors[position] = neighbor
    }
    
    //Убираем стену с определенной стороны
    func removeWall(nr: Int) {
        walls[nr] = false
    }
    
    //Рисуем комнату для мини карты. Фон и имеющиеся стены. Изначально фон и стены одного цвета, при посещении комнаты игроком цвет фона меняется на синий и комната становится видимой
    func drawRoom(ofWidth: CGFloat) -> UIView {
        myViewOnMap = UIView.init(frame: CGRect.init(x: CGFloat(coorX) * ofWidth, y: CGFloat(coorY) * ofWidth, width: ofWidth, height: ofWidth))
        myViewOnMap.backgroundColor = UIColor.black
        let margin = ofWidth/10
        if walls[0] {
            let wallView = UIView.init(frame: CGRect.init(x: ofWidth - margin, y: 0, width: margin, height: ofWidth))
            wallView.backgroundColor = UIColor.black
            myViewOnMap.addSubview(wallView)
        }
        if walls[1] {
            let wallView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: ofWidth, height: margin))
            wallView.backgroundColor = UIColor.black
            myViewOnMap.addSubview(wallView)
        }
        if walls[2] {
            let wallView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: margin, height: ofWidth))
            wallView.backgroundColor = UIColor.black
            myViewOnMap.addSubview(wallView)
        }
        if walls[3] {
            let wallView = UIView.init(frame: CGRect.init(x: 0, y: ofWidth - margin, width: ofWidth, height: margin))
            wallView.backgroundColor = UIColor.black
            myViewOnMap.addSubview(wallView)
        }
        return myViewOnMap
    }
    
    //Сравниваем комнаты по координатам
    func isEqual(room: Room) -> Bool {
        if room.coorX == self.coorX && room.coorY == self.coorY {
            return true
        } else {
            return false
        }
    }
    
    //Вызывается при посещении комнаты игроком
    func visitMe() {
        if !isVisitedByPlayer {
            isVisitedByPlayer = true
            myViewOnMap.backgroundColor = UIColor.blue
        }
    }
    
    //Добавление предмета в комнату
    func addItem(newItem: Item, position: CGPoint) {
        items.append(newItem)
        newItem.position = position
    }
    
    //Удаление предмета из комнаты
    func removeItem(thisItem: Item) {
        items.removeAll(where: {$0.position == thisItem.position && $0.texture == thisItem.texture})
    }
}
