//
//  ViewController.swift
//  DragonMaze
//
//  Created by Александр Строганов on 27.06.2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var healthLabel: UILabel!            //Показывает количество оставшихся шагов
    @IBOutlet weak var gameView: UIView!                //View с комнатой, в которой находится игрок и кнопками перехода между конмнатами
    @IBOutlet weak var inventoryView: UIView!           //Инвентарь, сюда добавляются взятые предметы
    @IBOutlet weak var itemDescLabel: UILabel!          //Описание выбранного предмета
    @IBOutlet weak var goldLabel: UILabel!              //Количество собранного золота
    @IBOutlet weak var buttonRight: UIButton!           //Кнопки перехода между комнатами
    @IBOutlet weak var buttonUp: UIButton!
    @IBOutlet weak var buttonLeft: UIButton!
    @IBOutlet weak var buttonDown: UIButton!
    @IBOutlet weak var gameOverLabel: UILabel!          //Надпись "Конец игры"
    private var buttonsArray: [UIButton] = []           //Массив с кнопками перехода между комнатами
    private var maze: Maze!                             //Лабиринт
    private var mapView: UIView!                        //Мини карта
    private var tileSize: CGFloat!                      //Размер предметов, рассчитывается так, чтобы в инвентарь входило 5 предметов
    private var dimX: Int!                              //Размеры лабиринта
    private var dimY: Int!
    private var selectedItem: Item?                     //Выбранный предмет
    private var selectFrame: UIImageView?               //Рамка выделения выбранного предмета
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        gameView.isHidden = true
        gameOverLabel.isHidden = true
        buttonsArray = [buttonRight, buttonUp, buttonLeft, buttonDown]
    }
    func startGame() {
        self.initLayout()
        self.setNewRoom(newRoom: maze.currentRoom!)
    }
    func gameOver() {
        gameView.isHidden = true
        gameOverLabel.isHidden = false
        for view in inventoryView.subviews {
            view.removeFromSuperview()
        }
        mapView.removeFromSuperview()
    }
    
    //Создаем мини карту, обновляем надписи с шагами и золотом
    func initLayout() {
        mapView = maze.drawMap(ofWidth: gameView.frame.size.width)
        mapView.frame.origin = gameView.frame.origin
        self.view.addSubview(mapView)
        mapView.isHidden = true
        updateHealthLabel()
        goldLabel.text = "Gold: \(maze.gold)"
        tileSize = inventoryView.frame.size.height
        selectFrame = UIImageView.init(image: UIImage(named: "selectFrame"))
        gameView.isHidden = false
    }
    
    //Спрашиваем пользователя о размерах лабиринта, обрабатываем неправильный ввод (должно быть целое число > 0)
    func askUserForDimensionM(withText: String) {
        let ac = UIAlertController(title: withText, message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "YES", style: .default) { [self, unowned ac] _ in
            if let answer = Int(ac.textFields![0].text!) {
                if answer > 0 {
                    dimX = answer
                    askUserForDimensionN(withText: "Enter maze height")
                } else {
                    askUserForDimensionM(withText: "Error: number of rooms has to be positive.")
                }
            } else {
                askUserForDimensionM(withText: "Error: number of rooms has to be an integer number.")
            }
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    func askUserForDimensionN(withText: String) {
        let ac = UIAlertController(title: withText, message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "YES", style: .default) { [self, unowned ac] _ in
            if let answer = Int(ac.textFields![0].text!) {
                if answer > 0 {
                    dimY = answer
                    maze = Maze.init(m: dimX, n: dimY)
                    startGame()
                } else {
                    askUserForDimensionN(withText: "Error: number of rooms has to be positive.")
                }
            } else {
                askUserForDimensionN(withText: "Error: number of rooms has to be an integer number.")
            }
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    func updateHealthLabel() {
        healthLabel.text = "Steps left: \(maze.stepsLeft)"
    }
    
    //Отображаем новую комнату, в которую перешел игрок
    func setNewRoom(newRoom: Room) {
        //Убираем кнопки с тех сторон, где у комнаты стены
        for i in 0...3 {
            if newRoom.walls[i] {
                buttonsArray[i].isHidden = true
            } else {
                buttonsArray[i].isHidden = false
            }
        }
        //Убираем старые и добавляем новые предметы
        for subView in gameView.subviews {
            if subView.isKind(of: Item.self) {
                subView.removeFromSuperview()
            }
        }
        for item in newRoom.items {
            var xPos = item.position?.x
            var yPos = item.position?.y
            if item.position == CGPoint.zero {
                xPos = CGFloat.random(in: tileSize...gameView.frame.size.width - 2 * tileSize)
                yPos = CGFloat.random(in: tileSize...gameView.frame.size.height - 2 * tileSize)
                item.position = CGPoint.init(x: xPos!, y: yPos!)
            }
            item.frame = CGRect.init(x: xPos!, y: yPos!, width: tileSize, height: tileSize)
            gameView.addSubview(item)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            item.addGestureRecognizer(tap)
        }
    }
    
    //********* HANDLE ACTIONS *****************
    
    //Начать игру
    @IBAction func startNewGame(_ sender: Any) {
        askUserForDimensionM(withText: "Enter maze width")
    }
    
    //Переход в другую комнату
    @IBAction func changeRoom(_ sender: UIButton) {
        if maze.stepsLeft > 0 {
            mapView.isHidden = true
            self.setNewRoom(newRoom: maze.goTo(direction: sender.tag))
            updateHealthLabel()
        } else {
            gameOver()                  //если шагов больше не осталось -> конец игры
        }
    }
    
    //показ мини карты
    @IBAction func showMap(_ sender: Any) {
        if mapView.isHidden {
            mapView.isHidden = false
        } else {
            mapView.isHidden = true
        }
    }
    
    //Применяем предмет
    @IBAction func useItem(_ sender: Any) {
        if selectedItem != nil {
            switch selectedItem?.texture {
            //ключ можно использовать если в комнате находится сундук
            case "key":
                let b = maze.currentRoom?.items.contains(where: {$0.texture == "chest"})
                if b! {
                    print("found chest YOU WON")
                    let ac = UIAlertController(title: "YOU WON", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "COOL!", style: .default))
                    present(ac, animated: true)
                    gameOver()
                } else {
                    print("no chest in the room")
                }
                
                //еда добавляет шагов
            case "apple":
                maze.addSteps(steps: 10)
                updateHealthLabel()
                discardCurrentItem()
            case "coffee":
                maze.addSteps(steps: 25)
                updateHealthLabel()
                discardCurrentItem()
            default:
                print("unusable item")
            }
        }
    }
    
    //Помещаем предмет обратно в комнату. Убираем из инвентаря и добавлем объекту Room и на gameView
    @IBAction func dropItem(_ sender: Any) {
        if selectedItem != nil {
            selectedItem?.removeFromSuperview()
            let xPos = CGFloat.random(in: tileSize...gameView.frame.size.width - 2 * tileSize)
            let yPos = CGFloat.random(in: tileSize...gameView.frame.size.height - 2 * tileSize)
            maze.currentRoom?.addItem(newItem: selectedItem!, position: CGPoint.init(x: xPos, y: yPos))
            selectedItem!.frame = CGRect.init(x: selectedItem!.position!.x, y: selectedItem!.position!.y, width: tileSize, height: tileSize)
            gameView.addSubview(selectedItem!)
            selectedItem = nil
            selectFrame?.removeFromSuperview()
            itemDescLabel.text = "Select item to see description."
            updateInventory()
        }
    }
    
    //Выбрасываем предмет. При этом ключ выбросить нельзя
    @IBAction func discardItem(_ sender: Any) {
        if selectedItem != nil {
            if selectedItem?.texture == "key" {
                print("you gonna need the key")
            } else {
                discardCurrentItem()
            }
        }
    }
    
    //Удаляем предмет из инвентаря при dsicard или use (еду)
    func discardCurrentItem() {
        selectedItem?.removeFromSuperview()
        selectedItem = nil
        selectFrame?.removeFromSuperview()
        itemDescLabel.text = "Select item to see description."
        updateInventory()
    }
    
    //Обновляем инвентарь, чтобы не было пустых мест
    func updateInventory() {
        let tempItems = inventoryView.subviews
        for view in inventoryView.subviews {
            view.removeFromSuperview()
        }
        var i = 0
        for item in tempItems {
            item.frame.origin.x = CGFloat(i) * tileSize
            inventoryView.addSubview(item)
            i += 1
        }
    }
    
    //Обрабатывает нажатие на предметы
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let touchedItem = sender.view as? Item {
            
            //Если предмет находится в комнате
            if touchedItem.superview == gameView {
                
                //Добавляем золото
                if touchedItem.texture == "gold" {
                    let touchedValItem = sender.view as? ValuableItem
                    maze.gold += (touchedValItem?.itemValue)!
                    goldLabel.text = "Gold: \(maze.gold)"
                    touchedValItem?.removeFromSuperview()
                    maze.currentRoom?.removeItem(thisItem: touchedValItem!)
                    
                    //Если это не сундук и инвентарь не заполнен, добавляем в инвентарь
                } else if touchedItem.texture != "chest" && inventoryView.subviews.count < 5 {
                        touchedItem.removeFromSuperview()
                        maze.currentRoom?.removeItem(thisItem: touchedItem)
                        inventoryView.addSubview(touchedItem)
                        var xCoor = inventoryView.subviews.count - 1
                        if inventoryView.subviews.contains(selectFrame!) {
                            xCoor -= 1
                        }
                        touchedItem.frame.origin = CGPoint.init(x: CGFloat(xCoor) * tileSize, y: 0)
                }
                
                //если предмет находится в инвентаре
            } else if touchedItem.superview == inventoryView {
                
                //делаем предмет выбранным или снимаем выбор
                if selectedItem != nil {
                    if selectedItem != touchedItem {
                        selectedItem = touchedItem
                        selectFrame?.frame.origin = touchedItem.frame.origin
                        itemDescLabel.text = touchedItem.useDesc
                    } else {
                        selectedItem = nil
                        selectFrame?.removeFromSuperview()
                        itemDescLabel.text = "Select item to see description."
                    }
                } else {
                    selectedItem = touchedItem
                    selectFrame?.frame = touchedItem.frame
                    itemDescLabel.text = touchedItem.useDesc
                    inventoryView.addSubview(selectFrame!)
                }
            }
        }
    }
}

