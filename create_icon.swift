#!/usr/bin/env swift
// Generates AppIcon_1024.png using CGContext (no display required).
import CoreGraphics
import ImageIO
import Foundation

let size = 1024
let s    = CGFloat(size)

let space = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(
    data: nil,
    width: size, height: size,
    bitsPerComponent: 8,
    bytesPerRow: size * 4,
    space: space,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fputs("❌ CGContext konnte nicht erstellt werden\n", stderr)
    exit(1)
}

// ── Rounded-rect clip (Apple-Stil) ────────────────────────────────────────────
let radius  = s * 0.22
let bgRect  = CGRect(x: 0, y: 0, width: s, height: s)
let bgPath  = CGPath(roundedRect: bgRect, cornerWidth: radius, cornerHeight: radius, transform: nil)
ctx.addPath(bgPath)
ctx.clip()

// ── Blau-Indigo-Verlauf ───────────────────────────────────────────────────────
let gradColors = [CGColor(colorSpace: space, components: [0.14, 0.38, 0.92, 1.0])!,
                  CGColor(colorSpace: space, components: [0.40, 0.12, 0.80, 1.0])!] as CFArray
let locs: [CGFloat] = [0.0, 1.0]
let gradient = CGGradient(colorsSpace: space, colors: gradColors, locations: locs)!
ctx.drawLinearGradient(gradient,
                       start: CGPoint(x: 0, y: s),
                       end:   CGPoint(x: s, y: 0),
                       options: [])

// ── Hilfsfunktionen ───────────────────────────────────────────────────────────
func fillRoundedRect(_ rect: CGRect, cornerRadius cr: CGFloat, alpha: CGFloat) {
    let p = CGPath(roundedRect: rect, cornerWidth: cr, cornerHeight: cr, transform: nil)
    ctx.setFillColor(CGColor(colorSpace: space, components: [1, 1, 1, alpha])!)
    ctx.addPath(p)
    ctx.fillPath()
}

// ── Kanban-Spalten ────────────────────────────────────────────────────────────
let colW:  CGFloat = s * 0.20
let gapX:  CGFloat = s * 0.065
let baseY: CGFloat = s * 0.15
let colCR: CGFloat = s * 0.045

let x1 = s * 0.115
let x2 = x1 + colW + gapX
let x3 = x2 + colW + gapX

fillRoundedRect(CGRect(x: x1, y: baseY, width: colW, height: s * 0.67), cornerRadius: colCR, alpha: 0.18)
fillRoundedRect(CGRect(x: x2, y: baseY, width: colW, height: s * 0.50), cornerRadius: colCR, alpha: 0.18)
fillRoundedRect(CGRect(x: x3, y: baseY, width: colW, height: s * 0.33), cornerRadius: colCR, alpha: 0.18)

// ── Karten in den Spalten ─────────────────────────────────────────────────────
let cardW  = colW  - s * 0.04
let cardH  = s * 0.09
let cardCR = s * 0.025
let padY   = s * 0.04
let stepY  = cardH + s * 0.028

let cx1 = x1 + s * 0.02
let cx2 = x2 + s * 0.02
let cx3 = x3 + s * 0.02

// Spalte 1: 3 Karten
fillRoundedRect(CGRect(x: cx1, y: baseY + padY + stepY * 2, width: cardW, height: cardH), cornerRadius: cardCR, alpha: 0.90)
fillRoundedRect(CGRect(x: cx1, y: baseY + padY + stepY * 1, width: cardW, height: cardH), cornerRadius: cardCR, alpha: 0.72)
fillRoundedRect(CGRect(x: cx1, y: baseY + padY + stepY * 0, width: cardW, height: cardH), cornerRadius: cardCR, alpha: 0.55)

// Spalte 2: 2 Karten
fillRoundedRect(CGRect(x: cx2, y: baseY + padY + stepY * 1, width: cardW, height: cardH), cornerRadius: cardCR, alpha: 0.90)
fillRoundedRect(CGRect(x: cx2, y: baseY + padY + stepY * 0, width: cardW, height: cardH), cornerRadius: cardCR, alpha: 0.68)

// Spalte 3: 1 Karte
fillRoundedRect(CGRect(x: cx3, y: baseY + padY + stepY * 0, width: cardW, height: cardH), cornerRadius: cardCR, alpha: 0.90)

// ── Glanz-Effekt oben ─────────────────────────────────────────────────────────
let shineColors = [CGColor(colorSpace: space, components: [1, 1, 1, 0.18])!,
                   CGColor(colorSpace: space, components: [1, 1, 1, 0.00])!] as CFArray
let shineGrad = CGGradient(colorsSpace: space, colors: shineColors, locations: [0.0, 1.0])!
ctx.saveGState()
ctx.addPath(bgPath)
ctx.clip()
ctx.drawLinearGradient(shineGrad,
                       start: CGPoint(x: s * 0.5, y: s),
                       end:   CGPoint(x: s * 0.5, y: s * 0.55),
                       options: [])
ctx.restoreGState()

// ── PNG exportieren ───────────────────────────────────────────────────────────
guard let cgImage = ctx.makeImage() else {
    fputs("❌ CGImage konnte nicht erstellt werden\n", stderr)
    exit(1)
}

let outURL = URL(fileURLWithPath: "AppIcon_1024.png")
guard let dest = CGImageDestinationCreateWithURL(outURL as CFURL, "public.png" as CFString, 1, nil) else {
    fputs("❌ CGImageDestination konnte nicht erstellt werden\n", stderr)
    exit(1)
}
CGImageDestinationAddImage(dest, cgImage, nil)
guard CGImageDestinationFinalize(dest) else {
    fputs("❌ PNG konnte nicht geschrieben werden\n", stderr)
    exit(1)
}

print("✅ AppIcon_1024.png erstellt (\(size)×\(size) px)")
