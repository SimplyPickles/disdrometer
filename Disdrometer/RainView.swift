// Disdrometer
//
// Created by Dylan Fraser on 6/17/26.
//

import AppKit

// DropStyle enum for different rain styles
enum DropStyle: String, CaseIterable, Codable {
  case fineMist = "Fine Mist"
  case longStreaks = "Long Streaks"
  case heavyDrops = "Heavy Drops"
  case softBlur = "Soft Blur"
  case crispDrops = "Crisp Drops"

  var scale: CGFloat {
    switch self {
    case .fineMist: return 0.2
    case .longStreaks: return 0.4
    case .heavyDrops: return 0.6
    case .softBlur: return 0.3
    case .crispDrops: return 0.35
    }
  }

  var lifetime: CGFloat {
    switch self {
    case .fineMist: return 5.0
    case .longStreaks: return 8.0
    case .heavyDrops: return 10.0
    case .softBlur: return 6.0
    case .crispDrops: return 7.5
    }
  }

  var blurRadius: CGFloat {
    switch self {
    case .fineMist: return 2.0
    case .longStreaks: return 0.0
    case .heavyDrops: return 1.0
    case .softBlur: return 4.0
    case .crispDrops: return 0.0
    }
  }
}

final class RainView: NSView {
  private let rainEmitter = CAEmitterLayer()
  private let dimLayer = CALayer()

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

  var dimEnabled: Bool = false {
    didSet {
      dimLayer.isHidden = !dimEnabled
    }
  }

  var dimOpacity: CGFloat = 0.3 {
    didSet {
      dimLayer.backgroundColor = NSColor.black.cgColor.copy(alpha: dimOpacity)
    }
  }

  var dropStyle: DropStyle = .crispDrops {
    didSet {
      updateRainCell()
    }
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

    // Setup dim layer (behind rain)
    dimLayer.backgroundColor = NSColor.black.cgColor.copy(alpha: dimOpacity)
    dimLayer.isHidden = !dimEnabled
    rootLayer.addSublayer(dimLayer)

    // Setup rain emitter
    rainEmitter.emitterShape = .line
    updateEmitterSize()
    rainEmitter.renderMode = .additive
    rainEmitter.emitterCells = [makeRainCell()]
    rootLayer.addSublayer(rainEmitter)
  }

  override func layout() {
    super.layout()
    updateEmitterSize()
    dimLayer.frame = bounds
  }

  private func updateEmitterSize() {
    let angleRadians = angleDegrees * .pi / 180
    let horizontalDrift = sin(angleRadians) * bounds.height
    let totalWidth = bounds.width + abs(horizontalDrift) * 1.2
    let offsetX = horizontalDrift * -0.5
    rainEmitter.emitterPosition = CGPoint(x: bounds.midX + offsetX, y: bounds.maxY + 20)
    rainEmitter.emitterSize = CGSize(width: totalWidth, height: 1)
  }

  private func makeRainCell() -> CAEmitterCell {
    let cell = CAEmitterCell()
    let colorWithOpacity = dropColor.withAlphaComponent(opacity)
    cell.contents = RainView.dropImage(color: colorWithOpacity, style: dropStyle)
    cell.birthRate = intensity
    cell.lifetime = Float(dropStyle.lifetime)
    cell.lifetimeRange = Float(dropStyle.lifetime * 0.3)

    cell.velocity = fallSpeed
    cell.velocityRange = fallSpeed * 0.25

    cell.emissionLongitude = angleDegrees * .pi / 180
    cell.emissionRange = 0.05

    cell.scale = dropStyle.scale
    cell.scaleRange = dropStyle.scale * 0.1
    cell.alphaSpeed = -0.3
    cell.spin = 0

    // Apply blur for soft styles
    if dropStyle == .softBlur {
      cell.birthRate = intensity * 0.8
    }

    return cell
  }

  private func updateRainCell() {
    rainEmitter.emitterCells = [makeRainCell()]
  }

  static func dropImage(color: NSColor, style: DropStyle) -> CGImage {
    let size: CGSize
    let draw: (CGContext, CGSize) -> Void

    // Switch case to match the style to enum options
    switch style {
    case .fineMist:
      size = CGSize(width: 2, height: 4)
      draw = { context, size in
        let path = CGPath(
          roundedRect: CGRect(origin: .zero, size: size), cornerWidth: 1, cornerHeight: 1,
          transform: nil)
        context.addPath(path)
        context.fillPath()
      }
    case .longStreaks:
      size = CGSize(width: 1, height: 16)
      draw = { context, size in
        context.move(to: CGPoint(x: 0.5, y: 0))
        context.addLine(to: CGPoint(x: 0.5, y: size.height))
        context.setLineWidth(1)
        context.strokePath()
      }
    case .heavyDrops:
      size = CGSize(width: 4, height: 16)
      draw = { context, size in
        let path = CGPath(
          roundedRect: CGRect(origin: .zero, size: size), cornerWidth: 2, cornerHeight: 2,
          transform: nil)
        context.addPath(path)
        context.fillPath()
      }
    case .softBlur:
      size = CGSize(width: 3, height: 12)
      draw = { context, size in
        let path = CGPath(
          roundedRect: CGRect(origin: .zero, size: size), cornerWidth: 1.5, cornerHeight: 1.5,
          transform: nil)
        context.addPath(path)
        context.fillPath()
      }
    case .crispDrops:
      size = CGSize(width: 1, height: 12)
      draw = { context, size in
        let path = CGPath(
          roundedRect: CGRect(origin: .zero, size: size), cornerWidth: 0.5, cornerHeight: 0.5,
          transform: nil)
        context.addPath(path)
        context.fillPath()
      }
    }

    return renderCGImage(size: size, color: color, draw: draw)
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
    guard
      let context = CGContext(
        data: nil,
        width: pixelWidth,
        height: pixelHeight,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      )
    else {
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
