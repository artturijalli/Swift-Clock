//
//  Clock.swift
//  ClockVisualization
//
//  Created by Artturi Jalli on 25.1.2021.
//

import Foundation
import SpriteKit

let angleOffset = -Double.pi / 2

func circleEdgePos(r: Double, phi: Double) -> CGPoint {
    return CGPoint(x: r * cos(phi), y: r * sin(phi))
}

func degsToRads(_ degrees: Double) -> Double {
    return 2 * Double.pi * degrees / 360
}

func hoursToRad(_ hours: Double) -> Double {
    let hourDegrees = 360.0 / 12.0
    return degsToRads(hourDegrees) * hours + angleOffset
}

func minsToRad(_ minutes: Double) -> Double {
    let minuteDegrees = 360.0 / 60.0
    return degsToRads(minuteDegrees) * minutes + angleOffset
}

func secsToRad(_ seconds: Double) -> Double {
    let secondDegrees = 360.0 / 60.0
    return degsToRads(secondDegrees) * seconds + angleOffset
}

enum Time: String, CaseIterable {
    case Second = "second"
    case Minute = "minute"
    case Hour = "hour"
}

struct Clock {
    var scene: SKScene
    
    var center: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var radius: Double = 140.0
        
    private func getTime(unit: Time) -> Double {
        let dateTime = Date()
        switch unit {
        case .Second:
            return Double(Calendar.current.component(.second, from: dateTime))
        case .Minute:
            return Double(Calendar.current.component(.minute, from: dateTime))
        case .Hour:
            return Double(Calendar.current.component(.hour, from: dateTime))
        }
    }
    
    private var seconds: Double {
        get {
            return getTime(unit: .Second)
        }
    }
    private var minutes: Double {
        get {
            let minutes = getTime(unit: .Minute)
            return minutes + seconds / 60
        }
    }
    private var hours: Double {
        get {
            let hours = getTime(unit: .Hour)
            let fullHours: Int = Int(hours) % 12 // 15:00 -> 3:00
            return Double(fullHours) + minutes / 60 + seconds / 3600
        }
    }
    
    private func drawDot(atPos: CGPoint) {
        let circle = SKShapeNode(circleOfRadius: 2)
        circle.fillColor = .white
        circle.position = atPos
        scene.addChild(circle)
    }
    
    private func drawTimeSlots() {
        let numHours = 12
        for i in 1 ... numHours {
            let rads = degsToRads(Double((360 / numHours) * i))
            drawDot(atPos: circleEdgePos(r: radius, phi: rads))
        }
    }
    
    private func drawHand(component: Time, center: CGPoint, edge: CGPoint) {
        let handPath = CGMutablePath()
        handPath.move(to: center)
        handPath.addLine(to: edge)

        var lineWidth: CGFloat {
            switch component {
            case .Second: return 2.0
            case .Minute: return 3.0
            case .Hour: return 4.0
            }
        }

        let line = SKShapeNode()
        line.path = handPath
        line.lineWidth = lineWidth
        line.strokeColor = .white
        line.name = component.rawValue
        scene.addChild(line)
    }
        
    private func drawCurrentTime() {
        clearPreviousTime()

        let secPos = circleEdgePos(r: radius, phi: -secsToRad(seconds))
        let minPos = circleEdgePos(r: radius, phi: -minsToRad(minutes))
        let hourPos = circleEdgePos(r: radius * 0.8, phi: -hoursToRad(hours))
        
        drawHand(component: .Second, center: center, edge: secPos)
        drawHand(component: .Minute, center: center, edge: minPos)
        drawHand(component: .Hour, center: center, edge: hourPos)
    }
    
    private func clearPreviousTime() {
        for timeComponent in Time.allCases {
            let handInScene = scene.childNode(withName: timeComponent.rawValue)
            handInScene?.removeFromParent()
        }
    }
    
    func start() {
        drawTimeSlots()
        drawCurrentTime()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            drawCurrentTime()
        }
    }
}
