//
//  PairPodView.swift
//  OmnipodKit
//
//  From OmniBLE/PumpManageUI/Views/PairPodView.swift
//  Created by Pete Schwamb on 2/5/20.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKitUI


struct PairPodView: View {

    @ObservedObject var viewModel: PairPodViewModel

    @State private var cancelModalIsPresented: Bool = false

    @Environment(\.appName) private var appName

    var body: some View {
        GuidePage(content: {
            VStack {
                PodChangeStepHeader(step: .fill)

                FillPodIllustration(podType: self.viewModel.podType)

                Text(self.viewModel.podType.description)
                    .font(.title2)
                HStack {
                    InstructionList(instructions: fillInstructions)
                        .disabled(viewModel.state.instructionsDisabled)
                }
                .padding(.bottom, 8)
            }
            .accessibility(sortPriority: 1)
        }) {
            VStack {
                if self.viewModel.state.showProgressDetail {
                    self.viewModel.error.map {
                        ErrorView($0, errorClass: $0.recoverable ? .normal : .critical)
                            .accessibility(sortPriority: 0)
                    }

                    if self.viewModel.error == nil {
                        VStack {
                            ProgressIndicatorView(state: self.viewModel.state.progressState)
                            if self.viewModel.state.isFinished {
                                FrameworkLocalText("Paired", comment: "Label text indicating pairing finished.")
                                    .bold()
                                    .padding(.top)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }

                if self.viewModel.error?.recoverable == true && self.viewModel.podIsActivated {
                    // A recoverable error with an active pod state, offer deactivate option
                    Button(action: {
                        self.viewModel.didRequestDeactivation?()
                    }) {
                        Text(LocalizedString("Deactivate Pod", comment: "Button text for deactivate pod button"))
                            .accessibility(identifier: "button_deactivate_pod")
                            .actionButtonStyle(.destructive)
                    }
                    .disabled(self.viewModel.state.isProcessing)
                }

                if (self.viewModel.error?.recoverable != false) {
                    // No errors or a recoverable error
                    Button(action: {
                        self.viewModel.continueButtonTapped()
                    }) {
                        Text(self.viewModel.state.nextActionButtonDescription)
                            .accessibility(identifier: "button_next_action")
                            .accessibility(label: Text(self.viewModel.state.actionButtonAccessibilityLabel))
                            .actionButtonStyle(.primary)
                    }
                    .disabled(self.viewModel.state.isProcessing)
                    .zIndex(1)
                }

                if (self.viewModel.error?.recoverable == false) {
                    Button(action: {
                        self.viewModel.continueButtonTapped()
                    }) {
                        Text("Abort")
                            .actionButtonStyle(self.viewModel.podIsActivated ?
                                .destructive : .primary)
                    }
                    .disabled(false)
                    .zIndex(1)
                }
            }
            .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
            .padding()
        }
        .alert(isPresented: $cancelModalIsPresented) { cancelPairingModal }

        .navigationBarTitleDisplayMode(.automatic)
        .navigationBarBackButtonHidden(self.viewModel.backButtonHidden)
        .navigationBarItems(trailing: self.viewModel.state.navBarVisible ? cancelButton : nil)

    }
        
    private var fillInstructions: [String] {
        var instructions = [
            LocalizedString("Use the syringe and needle that came with the pod. Draw a little over 100 units of insulin into the syringe.", comment: "Fill pod step: draw up insulin"),
            self.viewModel.podType.tabColor == "blue" ?
                LocalizedString("Find the fill port on the bottom of the pod, where the arrow points. Leave the blue needle cap on.", comment: "Fill pod step: find fill port (pod with blue needle cap)") :
                LocalizedString("Find the fill port on the bottom of the pod, where the arrow points. Leave the clear needle cap on.", comment: "Fill pod step: find fill port (pod with clear needle cap)"),
            LocalizedString("Insert the needle straight down into the fill port, completely vertical at 90 degrees.", comment: "Fill pod step: insert syringe needle at 90 degrees"),
            LocalizedString("Push the plunger slowly until the pod beeps 2 times.", comment: "Fill pod step: fill slowly until 2 beeps"),
        ]
        if self.viewModel.podType.isEros {
            instructions.append(LocalizedString("Keep the RileyLink about 6 inches from the pod during pairing.", comment: "Label text for step 2 of Eros pair pod instructions"))
        }
        instructions.append(String(format: LocalizedString("When you have heard the 2 beeps, keep the phone close to the pod and tap the button below to pair it with %1$@.", comment: "Fill pod step: pair after beeps (1: app name)"), appName))
        return instructions
    }

    var cancelButton: some View {
        Button(LocalizedString("Cancel", comment: "Cancel button text in navigation bar on pair pod UI")) {
            if viewModel.podIsActivated {
                cancelModalIsPresented = true
            } else {
                viewModel.didCancelSetup?()
            }
        }
        .accessibility(identifier: "button_cancel")
        .disabled(self.viewModel.state.isProcessing)
    }
    
    var cancelPairingModal: Alert {
        return Alert(
            title: FrameworkLocalText("Are you sure you want to cancel Pod setup?", comment: "Alert title for cancel pairing modal"),
            message: FrameworkLocalText("If you cancel Pod setup, the current Pod will be deactivated and will be unusable.", comment: "Alert message body for confirm pod attachment"),
            primaryButton: .destructive(FrameworkLocalText("Yes, Deactivate Pod", comment: "Button title for confirm deactivation option"), action: { viewModel.didRequestDeactivation?() }),
            secondaryButton: .default(FrameworkLocalText("No, Continue With Pod", comment: "Continue pairing button title of in pairing cancel modal"))
        )
    }

}
