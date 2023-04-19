//
//  ContentView.swift
//  snake_swiftUI
//
//  Created by Bartosz Seweryn on 17/02/2023.
//

import SwiftUI

enum Constants{
    static let boardSize: Int = 15 // <= 20
    static let moveTime: Double = 0.3 * (10 / Double(boardSize))
    static let foodSpawnTime: Double = 4.0
}



struct ContentView: View {
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: Constants.boardSize)
    @State private var tab:[Square?] = Array(repeating: nil, count: Constants.boardSize * Constants.boardSize)
    @State private var isGameStarted = false
    @State private var currentDirection: Direction = .none
    @State private var Snake: SnakeBody = SnakeBody()
    @State private var StartEndLabel = "Start"
    @State private var isEnded = false
    @State private var startButtonCliked = false

    
    
    let timer = Timer.publish(every: Constants.moveTime
                              , on: .main, in: .common).autoconnect()
    let timerFood = Timer.publish(every: Constants.foodSpawnTime, on: .main, in: .common).autoconnect()


    var body: some View {
        GeometryReader{geometry in
            
            VStack {
                
                Spacer()
                
                Button(isEnded ? "Restart" : " ") {
                    Restart()
                }
                .font(.largeTitle)
                .foregroundColor(.black)
                .disabled(!isEnded)

                Button(isGameStarted == false ? StartEndLabel : " ") {
                    StartGame()
                }
                .font(.largeTitle)
                .foregroundColor(.black)
                .disabled(startButtonCliked)
                .onReceive(timer) { _ in
                    if(isGameStarted)
                    {
                        MoveSnakeAuto()
                    }
                }
                .onReceive(timerFood) { _ in
                    if(isGameStarted && currentDirection != .none)
                    {
                        SpawnFood()
                    }
                }
                
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<(Constants.boardSize * Constants.boardSize)){i in
                        
                        ZStack{
                            Rectangle()
                                .foregroundColor(.blue).opacity(0.5)
                                .frame(width: geometry.size.width / CGFloat(Constants.boardSize), height: geometry.size.width / CGFloat(Constants.boardSize))
                                .border(.black).opacity(0.5)
                            if(tab[i]?.indicator == "heart.fill")
                            {
                                Image(systemName: tab[i]?.indicator ?? " ")
                                    .resizable()
                                    .frame(width: 250 / CGFloat(Constants.boardSize), height: 250 / CGFloat(Constants.boardSize))
                                    .foregroundColor(.red).opacity(0.5)
                            }
                            else
                            {
                                Image(systemName: tab[i]?.indicator ?? " ")
                                    .resizable()
                                    .frame(width: 250 / CGFloat(Constants.boardSize), height: 250 / CGFloat(Constants.boardSize))
                                    .foregroundColor(.green).opacity(0.5)
                            }
                        }
                    }
                }

                Spacer()
                
                HStack {
                    
                    Button("Left") {
                        currentDirection = .left
                        //Move()
                    }
                    .buttonBorderShape(.roundedRectangle)
                    .border(.black)
                    .frame(width: 100, height: 50)
                    
                    VStack {
                        
                        Button("Up") {
                            currentDirection = .up
                            //Move()
                        }
                        .buttonBorderShape(.roundedRectangle)
                        .border(.black)
                        .frame(width: 100, height: 50)
                        
                        Button("Down") {
                            currentDirection = .down
                           // Move()
                        }
                        .buttonBorderShape(.roundedRectangle)
                        .border(.black)
                        .frame(width: 100, height: 50)
                        
                    }
                    
                    Button("Right") {
                        currentDirection = .right
                       // Move()
                    }
                    .buttonBorderShape(.roundedRectangle)
                    .border(.black)
                    .frame(width: 100, height: 50)
                    
                }
                .font(.title)
                .foregroundColor(.black)
                .disabled(!isGameStarted)

                
            }
            .padding()
        }
    }

    func StartGame() {
        startButtonCliked = true
        isGameStarted = true
        isEnded = false
        
        tab[0] = Square(contains: .snake)
        Snake.Coordinates[0] = 0
        
    }
    func Move() {
        if(currentDirection == .left)
        {
            if(Snake.Coordinates[0] % Constants.boardSize == 0)
            {
               GameOver()
                return
            }
            EatingCheck()
            InsertToTab()
        }
        else if(currentDirection == .right)
        {
            if(Snake.Coordinates[0] % Constants.boardSize == Constants.boardSize - 1)
            {
                GameOver()
                return
            }
            EatingCheck()
            InsertToTab()
        }
        else if(currentDirection == .up)
        {
            if(Snake.Coordinates[0] < Constants.boardSize)
            {
                GameOver()
                return
            }
            EatingCheck()
            InsertToTab()
        }
        else if(currentDirection == .down)
        {
            if(Snake.Coordinates[0] > Constants.boardSize * Constants.boardSize - Constants.boardSize - 1)
            {
                GameOver()
                return
            }
            EatingCheck()
            InsertToTab()
        }
        
    }
    func InsertToTab() {
        for i in (1..<Snake.CurrenLen)  // indeksy poprawic
        {
            Snake.Coordinates[Snake.CurrenLen - i] = Snake.Coordinates[Snake.CurrenLen - i - 1]
        }
        Snake.Coordinates[Snake.CurrenLen] = -1
        switch(currentDirection)
        {
        case .left:
            Snake.Coordinates[0] -= 1
            break
        case .up:
            Snake.Coordinates[0] -= Constants.boardSize
            break
        case .down:
            Snake.Coordinates[0] += Constants.boardSize
        case .right:
            Snake.Coordinates[0] += 1
            break
        case .none:
            return
        }
        Draw()
    }
    func Draw() {
        UpdateBoard()
        for i in (0..<Snake.Coordinates.count)
        {
            if(Snake.Coordinates[i] >= 0)
            {
                tab[Snake.Coordinates[i]] = Square(contains: .snake)
            }
        }
    }
    func UpdateBoard() {
        for i in 0..<tab.count
        {
            if(tab[i]?.contains == .snake)
            {
                tab[i] = Square(contains: .empty)
            }
        }
    }
    func MoveSnakeAuto() {
        if(currentDirection == .left)
        {
            if(Snake.Coordinates[0] % Constants.boardSize == 0)
            {
                GameOver()
                return
            }
            EatingCheck()
            // Win
            if(Snake.CurrenLen >= Constants.boardSize * Constants.boardSize)
            {
                GameOver()
                return
            }
            InsertToTab()
        }
        if(currentDirection == .right)
        {
            if(Snake.Coordinates[0] % Constants.boardSize == Constants.boardSize - 1)
            {
                GameOver()
                return
            }
            EatingCheck()
            // Win
            if(Snake.CurrenLen >= Constants.boardSize * Constants.boardSize)
            {
                GameOver()
                return
            }
            InsertToTab()
        }
        if(currentDirection == .up)
        {
            if(Snake.Coordinates[0] < Constants.boardSize)
            {
                GameOver()
                return
            }
            EatingCheck()
            // Win
            if(Snake.CurrenLen >= Constants.boardSize * Constants.boardSize)
            {
                StartEndLabel = "You won!"
                isGameStarted = false
                isEnded = true
                return
            }
            InsertToTab()
        }
        if(currentDirection == .down)
        {
            if(Snake.Coordinates[0] > Constants.boardSize * Constants.boardSize - Constants.boardSize - 1)
            {
                GameOver()
                return
            }
            EatingCheck()
            // Win
            if(Snake.CurrenLen >= Constants.boardSize * Constants.boardSize)
            {
                StartEndLabel = "You won!"
                isGameStarted = false
                isEnded = true
                return
            }
            InsertToTab()
        }
    }
    func SpawnFood() {
        var ind = Int.random(in: 0..<(Constants.boardSize * Constants.boardSize))
        while(tab[ind]?.contains == .snake)
        {
            ind = Int.random(in: 0..<(Constants.boardSize * Constants.boardSize))
        }
        tab[ind] = Square(contains: .food)
    }
    func EatingCheck() {
        if(currentDirection == .left)
        {
            if(tab[Snake.Coordinates[0] - 1]?.contains == .snake)
            {
                GameOver()
                return
            }
            if(tab[Snake.Coordinates[0] - 1]?.contains == .food)
            {
                Snake.CurrenLen += 1
            }
        }
        else if(currentDirection == .right)
        {
            if(tab[Snake.Coordinates[0] + 1]?.contains == .snake)
            {
                GameOver()
                return
            }
            if(tab[Snake.Coordinates[0] + 1]?.contains == .food)
            {
                Snake.CurrenLen += 1
            }
        }
        else if(currentDirection == .up)
        {
            if(tab[Snake.Coordinates[0] - Constants.boardSize]?.contains == .snake)
            {
                GameOver()
                return
            }
            if(tab[Snake.Coordinates[0] - Constants.boardSize]?.contains == .food)
            {
                Snake.CurrenLen += 1
            }
        }
        else if(currentDirection == .down)
        {
            if(tab[Snake.Coordinates[0] + Constants.boardSize]?.contains == .snake)
            {
                GameOver()
                return
            }
            if(tab[Snake.Coordinates[0] + Constants.boardSize]?.contains == .food)
            {
                Snake.CurrenLen += 1
            }
        }
    }
    func Restart() {
        startButtonCliked = false
        isEnded = false
        for i in 0..<tab.count
        {
            tab[i] = Square(contains: .empty)
        }
        for i in 0..<Snake.Coordinates.count
        {
            Snake.Coordinates[i] = -1
        }
        Snake.CurrenLen = 1
        currentDirection = .none
        StartEndLabel = "Start"
    }
    func GameOver() {
        StartEndLabel = "Game over!"
        isGameStarted = false
        isEnded = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum Contain {
    case empty, food, snake
}

enum Direction {
    case left, up, down, right, none
}

struct SnakeBody {
    var Coordinates: [Int] = Array(repeating: -1, count: Constants.boardSize * Constants.boardSize)
    var CurrenLen = 1
    
}

struct Square {
    let contains: Contain
    
    var indicator: String {
        
        if(contains == .food)
        {
            return "heart.fill"
        }
        else if(contains == .snake)
        {
            return "square.fill"
        }
        else
        {
            return " "
        }
    }
}

