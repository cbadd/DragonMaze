//
//  Maze.swift
//  DragonMaze
//
//  Created by Александр Строганов on 27.06.2021.
//

import Foundation
import UIKit

//Класс Maze - лабиринт, состоящий из комнат
class Maze {
    let dimX: Int       //ширина, в комнатах
    let dimY: Int       //высота, в комнатах
    var roomsArray: [Room] = []     //массив со всеми комнатами лабиринта
    var currentRoom: Room?          //комната, в которой находится игрок в данный момент
    var playerIcon: UIImageView?    //картинка игрока, показыватеся на карте в комнате, где он находится
    var stepsLeft = 0               //оставшиеся шаги
    var gold = 0                    //найденное золото
    
    //Создаем лабиринт с заданными размерами
    init(m: Int, n: Int){
        dimX = m
        dimY = n
        
        //Создаем все комнаты лабиритна и сразу добавлем им соседние комнаты
        for i in 0...dimX-1 {
            for j in 0...dimY-1 {
                let newRoom = Room.init(x: i, y: j)
                roomsArray.append(newRoom)      //position of room in roomsArray is x*dimY+y (i*dimY+j)
                if j > 0 {
                    let topNeighbor = roomsArray[i * dimY + j - 1]
                    newRoom.addNeighbor(neighbor: topNeighbor, for: 1)
                    topNeighbor.addNeighbor(neighbor: newRoom, for: 3)
                }
                if i > 0 {
                    let leftNeighbor = roomsArray[(i - 1) * dimY + j]
                    newRoom.addNeighbor(neighbor: leftNeighbor, for: 2)
                    leftNeighbor.addNeighbor(neighbor: newRoom, for: 0)
                }
            }
        }
        
        //Создаем схему лабиринта
        var depth = 0           //запоминаем глубину комнаты - количество шагов от стартовой, чтобы затем задать начальное доступное количество шагов игрока в зависимости от расположения ключа и сундука
        var roomsStack: [Room] = []
        var curRoom = roomsArray.randomElement()!
        currentRoom = curRoom
        curRoom.isVisitedByMazeInit = true
        curRoom.depthInMaze = depth
        roomsStack.append(curRoom)
        depth += 1
        while !roomsStack.isEmpty {
            var foundNeighbor = false
            while !foundNeighbor {
                if roomsStack.isEmpty {
                    break
                }
                curRoom = roomsStack.last!
                roomsStack.removeLast()
                depth -= 1
                var tempNeighbors = Array(curRoom.neighbors.values)
                while !tempNeighbors.isEmpty {
                    if let neighbor = tempNeighbors.randomElement() {
                        if !neighbor.isVisitedByMazeInit {
                            roomsStack.append(curRoom)
                            depth += 1
                            if neighbor.coorX == curRoom.coorX {
                                if neighbor.coorY > curRoom.coorY {
                                    curRoom.removeWall(nr: 3)
                                    neighbor.removeWall(nr: 1)
                                } else {
                                    curRoom.removeWall(nr: 1)
                                    neighbor.removeWall(nr: 3)
                                }
                            } else {
                                if neighbor.coorX > curRoom.coorX {
                                    curRoom.removeWall(nr: 0)
                                    neighbor.removeWall(nr: 2)
                                } else {
                                    curRoom.removeWall(nr: 2)
                                    neighbor.removeWall(nr: 0)
                                }
                            }
                            neighbor.isVisitedByMazeInit = true
                            curRoom.depthInMaze = depth
                            roomsStack.append(neighbor)
                            depth += 1
                            foundNeighbor = true
                            break
                        }
                        tempNeighbors.removeAll(where: {$0.isEqual(room: neighbor)})
                    }
                }
                curRoom.depthInMaze = depth
            }
        }
        
        //Добаляем предметы в комнаты в случайном порядке. Количество еды и золота зависит от размера лабиринта
        var itemsToAdd = ["key", "chest", "stone", "shroom", "bone"]
        for _ in 0...Int(dimX * dimY / 15) {
            itemsToAdd.append("apple")
            itemsToAdd.append("gold")
        }
        for _ in 0...Int(dimX * dimY / 25) {
            itemsToAdd.append("coffee")
        }
        for item in itemsToAdd {
            let room = roomsArray.randomElement()
            if item == "gold" {
                room?.addItem(newItem: ValuableItem.init(texture: item, value: Int.random(in: 1...7) * 5), position: CGPoint.zero)
            } else {
                room!.addItem(newItem: Item.init(texture: item), position: CGPoint.zero)
                if item == "key" {
                    stepsLeft += 2 * (room?.depthInMaze)!
                }
                if item == "chest" {
                    stepsLeft += (room?.depthInMaze)!
                }
            }
        }
    }
    
    //Переход в соседнюю комнату
    func goTo(direction: Int) -> Room {
        stepsLeft -= 1
        currentRoom = currentRoom?.neighbors[direction]
        currentRoom?.visitMe()
        playerIcon?.frame.origin = (currentRoom?.myViewOnMap.frame.origin)!
        return currentRoom!
    }
    
    //Рисуем мини карту
    func drawMap(ofWidth: CGFloat) -> UIView {
        let tileSize = ofWidth / CGFloat(dimX)
        let mapView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: ofWidth, height: CGFloat(dimY) * tileSize))
        mapView.backgroundColor = UIColor.red
        
        for room in roomsArray {
            mapView.addSubview(room.drawRoom(ofWidth: tileSize))
        }
        playerIcon = UIImageView.init(image: UIImage(named: "player"))
        playerIcon?.frame = (currentRoom?.myViewOnMap.frame)!
        mapView.addSubview(playerIcon!)
        currentRoom?.visitMe()
        return mapView
    }
    
    //Вызывается, когда игрок использует еду
    func addSteps(steps: Int) {
        stepsLeft += steps
    }
}
