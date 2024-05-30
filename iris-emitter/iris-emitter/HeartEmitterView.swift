//
//  HeartEmitterView.swift
//  iris-emitter
//
//  Created by Yinka Adepoju on 30/5/24.
//

import SwiftUI

struct HeartEmitterView: View {
    @State private var hearts: [Heart] = []
    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect() // Slower interval for fewer hearts

    var body: some View {
        ZStack {
            ForEach(hearts) { heart in
                HeartShape()
                    .fill(Color.red)
                    .frame(width: heart.size, height: heart.size)
                    .shadow(color: Color.white.opacity(0.6), radius: 10, x: 0, y: 0) // White inner glow
                    .shadow(color: Color.red.opacity(0.6), radius: 20, x: 0, y: 0) // Red outer glow
                    .blur(radius: 3)
                    .position(x: heart.position.x, y: heart.position.y)
                    .animation(.easeIn(duration: heart.speed), value: heart.position) // Gradually increase speed
                    .opacity(heart.opacity)
                    .animation(Animation.linear(duration: heart.speed / 2).delay(heart.speed / 2), value: heart.opacity)
                    .scaleEffect(heart.scale)
                    .animation(Animation.linear(duration: heart.speed / 2).delay(heart.speed / 2), value: heart.scale)
            }
        }
        .onReceive(timer) { _ in
            addHearts()
        }
    }

    private func addHearts() {
        let numberOfHearts = Int.random(in: 1...4) // Add 1 to 2 hearts each time
        for _ in 0..<numberOfHearts {
            addHeart()
        }
    }

    private func addHeart() {
        let size = CGFloat.random(in: 20...60)
        let initialSpeed = Double.random(in: 5...8) // Initial slow speed
        let maxSpeed = Double.random(in: 1...6) // Max speed it will reach
        let xOffset = CGFloat.random(in: -UIScreen.main.bounds.width / 8...UIScreen.main.bounds.width / 8)
        let endPoint = CGPoint(x: UIScreen.main.bounds.width / 10 + xOffset, y: -UIScreen.main.bounds.height * 5) // Disappear before reaching the top left

        let newHeart = Heart(
            id: UUID(),
            size: size,
            speed: initialSpeed,
            position: CGPoint(x: UIScreen.main.bounds.width / 2 + xOffset, y: UIScreen.main.bounds.height),
            endPoint: endPoint,
            opacity: 1.0,
            scale: 1.0
        )

        hearts.append(newHeart)

        // Animate heart to end point and gradually increase speed
        withAnimation(Animation.easeIn(duration: initialSpeed).speed(1 / maxSpeed)) {
            hearts = hearts.map {
                var heart = $0
                if heart.id == newHeart.id {
                    heart.position = heart.endPoint
                    heart.opacity = 0.0
                    heart.scale = 0.1
                }
                return heart
            }
        }

        // Remove hearts that have moved out of view
        DispatchQueue.main.asyncAfter(deadline: .now() + maxSpeed) {
            self.hearts.removeAll { $0.id == newHeart.id }
        }
    }
}

struct Heart: Identifiable {
    let id: UUID
    let size: CGFloat
    let speed: Double
    var position: CGPoint
    var endPoint: CGPoint
    var opacity: Double
    var scale: CGFloat
}

struct HeartEmitterView_Previews: PreviewProvider {
    static var previews: some View {
        HeartEmitterView()
    }
}
