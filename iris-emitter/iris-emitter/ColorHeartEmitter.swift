//
//  ColorHeartEmitter.swift
//  iris-emitter
//
//  Created by Yinka Adepoju on 30/5/24.
//

import SwiftUI

struct ColorHeartEmitterView: View {
    enum HeartColor {
        case blue, white
    }

    struct ColorHeart: Identifiable {
        let id: UUID
        let size: CGFloat
        let speed: Double
        var position: CGPoint
        var endPoint: CGPoint
        var opacity: Double
        var scale: CGFloat
        var wiggleOffset: CGPoint
        let color: HeartColor
    }

    @State private var hearts: [ColorHeart] = []
    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            ForEach(hearts) { heart in
                HeartShape()
                    .fill(heart.color == .blue ? Color.blue : Color.white)
                    .frame(width: heart.size, height: heart.size)
                    .shadow(color: Color.white.opacity(0.6), radius: 10, x: 0, y: 0) // White inner glow
                    .shadow(color: heart.color == .blue ? Color.blue.opacity(0.6) : Color.gray.opacity(0.6), radius: 20, x: 0, y: 0) // Outer glow
                    .blur(radius: 3)
                    .position(x: heart.position.x, y: heart.position.y)
                    .opacity(heart.opacity)
                    .scaleEffect(heart.scale)
                    .offset(x: heart.wiggleOffset.x, y: heart.wiggleOffset.y)
                    .animation(Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: heart.wiggleOffset)
            }
        }
        .onReceive(timer) { _ in
            addHearts(color: .blue)
            addHearts(color: .white)
        }
        .onAppear {
            startWiggling()
        }
    }

    private func addHearts(color: HeartColor) {
        let numberOfHearts = Int.random(in: 1...3)
        for _ in 0..<numberOfHearts {
            addHeart(color: color)
        }
    }

    private func addHeart(color: HeartColor) {
        let size = CGFloat.random(in: 20...50) // Slightly smaller max size
        let speed = Double.random(in: 2...4) // Fast speed from the start
        let angle = Double.random(in: 0..<360) * .pi / 180 // Convert degrees to radians
        let radius = UIScreen.main.bounds.width * 1.5 // Radius to cover a larger area
        let endPoint = CGPoint(
            x: UIScreen.main.bounds.width / 2 + CGFloat(Darwin.cos(angle) * radius),
            y: UIScreen.main.bounds.height / 2 + CGFloat(Darwin.sin(angle) * radius)
        )

        let newHeart = ColorHeart(
            id: UUID(),
            size: size,
            speed: speed,
            position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2),
            endPoint: endPoint,
            opacity: 1.0,
            scale: 1.0,
            wiggleOffset: CGPoint.zero,
            color: color
        )

        hearts.append(newHeart)

        // Animate heart to end point and fade out before reaching it
        withAnimation(Animation.easeOut(duration: speed)) {
            if let index = hearts.firstIndex(where: { $0.id == newHeart.id }) {
                hearts[index].position = newHeart.endPoint
                hearts[index].opacity = 0.0
                hearts[index].scale = 0.1
            }
        }

        // Remove hearts that have moved out of view
        DispatchQueue.main.asyncAfter(deadline: .now() + speed) {
            self.hearts.removeAll { $0.id == newHeart.id }
        }
    }

    private func startWiggling() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            self.hearts = self.hearts.map {
                var heart = $0
                heart.wiggleOffset = CGPoint(x: CGFloat.random(in: -5...5), y: CGFloat.random(in: -5...5))
                return heart
            }
        }
    }
}

struct ColorHeartEmitterView_Previews: PreviewProvider {
    static var previews: some View {
        ColorHeartEmitterView()
    }
}
