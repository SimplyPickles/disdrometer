//
//  RainView.swift
//  Disdrometer
//
//  Created by Dylan Fraser on 6/17/26.
//

import AppKit

final class RainView: NSView {

    private let rainEmitter = CAEmitterLayer()

    var intensity: Float = 20 {
        didSet { rainEmitter.birthRate = intensity }
    }
    var fallSpeed: CGFloat = 200 {
        didSet { updateRainCell() }
    }
    var angleDegrees: CGFloat = -30 {
        didSet {
            updateRainCell()
            updateEmitterSize()
        }
    }
    var dropColor: NSColor = NSColor(calibratedRed: 0.7, green: 0.85, blue: 1.0, alpha: 0.4) {
        didSet { updateRainCell() }
    }
    var opacity: CGFloat = 0.4 {
        didSet { updateRainCell() }
    }
    var lifetime: CGFloat = 7.5 {
        didSet { updateRainCell() }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        setupLayers()
    }

    private func setupLayers() {
        guard let rootLayer = layer else { return }

        rainEmitter.emitterShape = .line
        updateEmitterSize()
        rainEmitter.renderMode = .additive
        rainEmitter.emitterCells = [makeRainCell()]
        rootLayer.addSublayer(rainEmitter)
    }

    override func layout() {
        super.layout()
        updateEmitterSize()
    }

    private func updateEmitterSize() {
        let angleRadians = angleDegrees * .pi / 180
        let horizontalDrift = sin(angleRadians) * bounds.height
        let totalWidth = bounds.width + abs(horizontalDrift) * 1.2
        let offsetX = horizontalDrift * 0.5
        rainEmitter.emitterPosition = CGPoint(x: bounds.midX + offsetX, y: bounds.maxY + 20)
        rainEmitter.emitterSize = CGSize(width: totalWidth, height: 1)
    }

    private func makeRainCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        let colorWithOpacity = dropColor.withAlphaComponent(opacity)
        cell.contents = RainView.dropImage(color: colorWithOpacity)
        cell.birthRate = intensity
        cell.lifetime = Float(lifetime)
        cell.lifetimeRange = Float(lifetime * 0.3)

        cell.velocity = fallSpeed
        cell.velocityRange = fallSpeed * 0.25

        cell.emissionLongitude = angleDegrees * 0.2
        cell.emissionRange = 0.05

        cell.scale = 0.3
        cell.scaleRange = 0.1
        cell.alphaSpeed = -0.3

        cell.spin = 0

        return cell
    }

    private func updateRainCell() {
        rainEmitter.emitterCells = [makeRainCell()]
    }

    static func dropImage(color: NSColor) -> CGImage {
        renderCGImage(size: CGSize(width: 1, height: 12), color: color) { context, size in
            let path = CGPath(
                roundedRect: CGRect(origin: .zero, size: size),
                cornerWidth: 0.5, cornerHeight: 0.5, transform: nil
            )
            context.addPath(path)
            context.fillPath()
        }
    }

    private static func renderCGImage(
        size: CGSize,
        color: NSColor,
        draw: (CGContext, CGSize) -> Void
    ) -> CGImage {
        let scale: CGFloat = 2.0
        let pixelWidth = Int(size.width * scale)
        let pixelHeight = Int(size.height * scale)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            fatalError("RainView: failed to create CGContext for procedural image")
        }

        context.scaleBy(x: scale, y: scale)

        let rgbColor = color.usingColorSpace(.deviceRGB) ?? color
        context.setFillColor(rgbColor.cgColor)
        draw(context, size)

        guard let image = context.makeImage() else {
            fatalError("RainView: failed to render procedural image")
        }
        return image
    }
}
