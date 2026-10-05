//
//  PodChangeIllustrations.swift
//  OmnipodKit
//
//  Step header and drawings for the Start New Pod guide:
//  deactivate → fill → attach → insert cannula.
//

import SwiftUI

/// The four steps of changing a pod, shown as "Step N of 4" on each guide screen.
enum PodChangeStep: Int, CaseIterable {
    case deactivate = 1
    case fill
    case attach
    case insert
}

struct PodChangeStepHeader: View {
    var step: PodChangeStep

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(format: LocalizedString("Step %1$d of %2$d", comment: "Step counter in the start new pod guide (1: current step) (2: number of steps)"), step.rawValue, PodChangeStep.allCases.count))
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
            HStack(spacing: 4) {
                ForEach(PodChangeStep.allCases, id: \.rawValue) { s in
                    Capsule()
                        .fill(s.rawValue <= step.rawValue ? Color.accentColor : Color.secondary.opacity(0.25))
                        .frame(height: 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// Numbered marker placed on a photo so it matches a line in the instruction list below.
private struct StepBadge: View {
    var number: Int

    var body: some View {
        Text("\(number)")
            .font(.caption.weight(.bold))
            .foregroundColor(.white)
            .frame(width: 22, height: 22)
            .background(Circle().fill(Color.accentColor))
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(radius: 1)
    }
}

/// Places `content` at a fractional position of the view it overlays.
private struct FractionalPosition<Content: View>: View {
    var x: CGFloat
    var y: CGFloat
    @ViewBuilder var content: Content

    var body: some View {
        GeometryReader { geo in
            content.position(x: geo.size.width * x, y: geo.size.height * y)
        }
    }
}

// MARK: - Fill

/// Pod bottom with the fill port ringed, next to a side view of the syringe going in at 90°.
struct FillPodIllustration: View {
    var podType: PodType

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var pulse = false

    private var height: CGFloat { verticalSizeClass == .compact ? 70 : 130 }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(frameworkImage: podType.podBottomTabImage, decorative: true)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(
                    // Fill port, top right of the pod bottom photo (where the printed arrow points).
                    FractionalPosition(x: 0.785, y: 0.295) {
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 3)
                            .frame(width: 30, height: 30)
                            .scaleEffect(pulse ? 1.25 : 0.9)
                            .opacity(pulse ? 0.5 : 1)
                    }
                )
            SyringeSideView()
                .frame(width: height * 0.75)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .padding(.vertical, verticalSizeClass == .compact ? 0 : 8)
        .accessibilityHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

/// Side view: syringe straight above the pod, needle in the fill port, right-angle mark and "90°".
private struct SyringeSideView: View {
    @State private var push = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cx = w * 0.42
            let podTop = h * 0.80
            let barrelW = w * 0.22
            let barrelTop = h * 0.16
            let barrelBottom = h * 0.56
            let plungerTravel = h * 0.08

            ZStack {
                // Pod, seen from the side
                RoundedRectangle(cornerRadius: h * 0.06)
                    .fill(Color(UIColor.systemGray4))
                    .frame(width: w * 0.92, height: h * 0.16)
                    .position(x: w * 0.5, y: podTop + h * 0.08)

                // Needle
                Path { p in
                    p.move(to: CGPoint(x: cx, y: barrelBottom + h * 0.04))
                    p.addLine(to: CGPoint(x: cx, y: podTop + h * 0.03))
                }
                .stroke(Color.secondary, lineWidth: 1.5)

                // Needle hub
                Rectangle()
                    .fill(Color.secondary)
                    .frame(width: barrelW * 0.35, height: h * 0.04)
                    .position(x: cx, y: barrelBottom + h * 0.02)

                // Barrel with insulin and scale marks
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(UIColor.systemBackground))
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.35))
                        .frame(height: (barrelBottom - barrelTop) * (push ? 0.35 : 0.75))
                    VStack(spacing: (barrelBottom - barrelTop) / 6) {
                        ForEach(0..<5, id: \.self) { _ in
                            Rectangle().fill(Color.secondary).frame(width: barrelW * 0.35, height: 1)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.secondary, lineWidth: 1.5)
                }
                .frame(width: barrelW, height: barrelBottom - barrelTop)
                .position(x: cx, y: (barrelTop + barrelBottom) / 2)

                // Plunger rod and thumb rest, moving down slowly
                Group {
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(width: barrelW * 0.25, height: h * 0.16)
                        .position(x: cx, y: barrelTop - h * 0.06)
                    Capsule()
                        .fill(Color.secondary)
                        .frame(width: barrelW * 1.3, height: h * 0.03)
                        .position(x: cx, y: barrelTop - h * 0.14)
                }
                .offset(y: push ? plungerTravel : 0)

                // Right-angle mark where the needle meets the pod
                Path { p in
                    let s = w * 0.09
                    p.move(to: CGPoint(x: cx, y: podTop - s))
                    p.addLine(to: CGPoint(x: cx + s, y: podTop - s))
                    p.addLine(to: CGPoint(x: cx + s, y: podTop))
                }
                .stroke(Color.accentColor, lineWidth: 1.5)

                Text("90°")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.accentColor)
                    .position(x: cx + w * 0.30, y: podTop - h * 0.10)

                // "Slowly" arrow next to the barrel
                Image(systemName: "arrow.down")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.accentColor)
                    .position(x: cx + w * 0.32, y: barrelTop + h * 0.10)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: false)) {
                push = true
            }
        }
    }
}

// MARK: - Attach

/// Pod bottom with numbered markers for the cap (1) and the adhesive backing (2),
/// then the pod top as it sits on the body (4).
struct AttachPodIllustration: View {
    var podType: PodType

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var height: CGFloat { verticalSizeClass == .compact ? 70 : 120 }

    var body: some View {
        HStack(spacing: 10) {
            Image(frameworkImage: podType.podBottomTabImage, decorative: true)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(
                    ZStack {
                        FractionalPosition(x: 0.20, y: 0.48) { StepBadge(number: 1) }
                        FractionalPosition(x: 0.62, y: 0.80) { StepBadge(number: 2) }
                    }
                )
            Image(systemName: "arrow.right")
                .font(.title3.weight(.semibold))
                .foregroundColor(.secondary)
            Image(frameworkImage: "Pod", decorative: true)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(
                    FractionalPosition(x: 0.88, y: 0.15) { StepBadge(number: 4) }
                )
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .padding(.vertical, verticalSizeClass == .compact ? 0 : 8)
        .accessibilityHidden(true)
    }
}

// MARK: - Insert

/// Pod on the body with a countdown ring: slide, the pod counts down, then the needle goes in.
struct InsertCannulaIllustration: View {
    /// Once the cannula is in, the loop stops on a checkmark.
    var isFinished: Bool = false

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var height: CGFloat { verticalSizeClass == .compact ? 70 : 130 }

    var body: some View {
        HStack(spacing: 14) {
            Image(frameworkImage: "Pod", decorative: true)
                .resizable()
                .aspectRatio(contentMode: .fit)
            if isFinished {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(.accentColor)
                    .frame(width: height * 0.5, height: height * 0.5)
            } else {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                // 3, 2, 1, then the needle, on a loop
                let tick = Int(context.date.timeIntervalSinceReferenceDate) % 4
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: CGFloat(3 - min(tick, 3)) / 3)
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.9), value: tick)
                    if tick < 3 {
                        Text("\(3 - tick)")
                            .font(.title2.weight(.bold).monospacedDigit())
                    } else {
                        Image(systemName: "arrow.down.to.line")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.accentColor)
                    }
                }
                .frame(width: height * 0.5, height: height * 0.5)
            }
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .padding(.vertical, verticalSizeClass == .compact ? 0 : 8)
        .accessibilityHidden(true)
    }
}

struct PodChangeIllustrations_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            PodChangeStepHeader(step: .fill)
            FillPodIllustration(podType: PodType(podType: .productIdDash))
            AttachPodIllustration(podType: PodType(podType: .productIdDash))
            InsertCannulaIllustration()
        }
        .padding()
    }
}
