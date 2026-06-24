#!/usr/bin/env swift
// Generates AppIcon_1024.png — a modern Apple-style Kanban board icon.
// Run via: swift create_icon.swift
import AppKit

let size = 1024
let s = CGFloat(size)

let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
defer { image.unlockFocus() }

guard let ctx = NSGraphicsContext.current?.cgContext else { exit(1) }

// ── Background: rounded square with blue-to-indigo gradient ──────────────────
let radius = s * 0.22
let bgPath = CGPath(roundedRect: CGRect(x: 0, y: 0, width: size, height: size),
                    cornerWidth: radius, cornerHeight: radius, transform: nil)
ctx.addPath(bgPath)
ctx.clip()

let space  = CGColorSpaceCreateDeviceRGB()
let colors = [CGColor(red: 0.14, green: 0.38, blue: 0.92, alpha: 1.0),
              CGColor(red: 0.40, green: 0.12, blue: 0.80, alpha: 1.0)] as CFArray
let locs: [CGFloat] = [0.0, 1.0]
let gradient = CGGradient(colorsSpace: space, colors: colors, locations: locs)!
ctx.drawLinearGradient(gradient,
                       start: CGPoint(x: 0,    y: s),
                       end:   CGPoint(x: s,    y: 0),
                       options: [])

// ── Column helper ─────────────────────────────────────────────────────────────
func drawColumn(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat,
                alpha: CGFloat, ctx: CGContext) {
    let cr = s * 0.045
    let rect = CGRect(x: x, y: y, width: w, height: h)
    let p = CGPath(roundedRect: rect, cornerWidth: cr, cornerHeight: cr, transform: nil)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: alpha))
    ctx.addPath(p)
    ctx.fillPath()
}

// ── Card helper ───────────────────────────────────────────────────────────────
func drawCard(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat,
              alpha: CGFloat, ctx: CGContext) {
    let cr = s * 0.025
    let rect = CGRect(x: x, y: y, width: w, height: h)
    let p = CGPath(roundedRect: rect, cornerWidth: cr, cornerHeight: cr, transform: nil)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: alpha))
    ctx.addPath(p)
    ctx.fillPath()
}

// ── Layout constants ──────────────────────────────────────────────────────────
let colW:  CGFloat = s * 0.20
let gapX:  CGFloat = s * 0.065
let baseY: CGFloat = s * 0.15
let topY:  CGFloat = s * 0.82    // columns grow upward (macOS coord)

let x1 = s * 0.115
let x2 = x1 + colW + gapX
let x3 = x2 + colW + gapX

// Column heights (ToDo tallest, Done shortest)
let h1: CGFloat = s * 0.67
let h2: CGFloat = s * 0.50
let h3: CGFloat = s * 0.33

drawColumn(x: x1, y: baseY,       w: colW, h: h1, alpha: 0.18, ctx: ctx)
drawColumn(x: x2, y: baseY,       w: colW, h: h2, alpha: 0.18, ctx: ctx)
drawColumn(x: x3, y: baseY,       w: colW, h: h3, alpha: 0.18, ctx: ctx)

// ── Cards inside columns ──────────────────────────────────────────────────────
let cardW  = colW  - s * 0.04
let cardH  = s * 0.09
let cardX1 = x1 + s * 0.02
let cardX2 = x2 + s * 0.02
let cardX3 = x3 + s * 0.02
let padY   = s * 0.04
let stepY  = cardH + s * 0.028

// Column 1: 3 cards
drawCard(x: cardX1, y: baseY + padY + stepY * 2, w: cardW, h: cardH, alpha: 0.90, ctx: ctx)
drawCard(x: cardX1, y: baseY + padY + stepY * 1, w: cardW, h: cardH, alpha: 0.72, ctx: ctx)
drawCard(x: cardX1, y: baseY + padY + stepY * 0, w: cardW, h: cardH, alpha: 0.55, ctx: ctx)

// Column 2: 2 cards
drawCard(x: cardX2, y: baseY + padY + stepY * 1, w: cardW, h: cardH, alpha: 0.90, ctx: ctx)
drawCard(x: cardX2, y: baseY + padY + stepY * 0, w: cardW, h: cardH, alpha: 0.68, ctx: ctx)

// Column 3: 1 card
drawCard(x: cardX3, y: baseY + padY + stepY * 0, w: cardW, h: cardH, alpha: 0.90, ctx: ctx)

// ── Subtle shine at top ───────────────────────────────────────────────────────
let shineColors = [CGColor(red: 1, green: 1, blue: 1, alpha: 0.18),
                   CGColor(red: 1, green: 1, blue: 1, alpha: 0.00)] as CFArray
let shineGrad = CGGradient(colorsSpace: space, colors: shineColors, locations: [0, 1])!
ctx.saveGState()
ctx.addPath(bgPath)
ctx.clip()
ctx.drawLinearGradient(shineGrad,
                       start: CGPoint(x: s * 0.5, y: s),
                       end:   CGPoint(x: s * 0.5, y: s * 0.55),
                       options: [])
ctx.restoreGState()

// ── Export PNG ────────────────────────────────────────────────────────────────
guard let tiff = image.tiffRepresentation,
      let rep  = NSBitmapImageRep(data: tiff),
      let png  = rep.representation(using: .png, properties: [:]) else { exit(1) }

let url = URL(fileURLWithPath: "AppIcon_1024.png")
try! png.write(to: url)
print("✅ AppIcon_1024.png erstellt (\(size)×\(size) px)")
