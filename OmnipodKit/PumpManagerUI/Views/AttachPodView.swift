//
//  AttachPodView.swift
//  OmnipodKit
//
//  From OmniBLE/PumpManageUI/Views/AttachPodView.swift
//  Created by Pete Schwamb on 2/23/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKitUI


struct AttachPodView: View {
    
    enum Modal: Int, Identifiable {
        var id: Int { rawValue }
        
        case attachConfirmationModal
        case cancelModal
    }
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var didConfirmAttachment: () -> Void
    var didRequestDeactivation: () -> Void
    var podType: PodType
    
    @State private var activeModal: Modal?
    
    var body: some View {
        GuidePage(content: {
            VStack {
                PodChangeStepHeader(step: .attach)

                AttachPodIllustration(podType: podType)

                HStack {
                    InstructionList(instructions: [
                        podType.tabColor == "blue" ?
                            LocalizedString("Snap off the blue needle cap from the pod. Check that the cannula is not sticking out.", comment: "Attach pod step: remove blue needle cap") :
                            LocalizedString("Remove the clear needle cap from the pod. Check that the cannula is not sticking out.", comment: "Attach pod step: remove clear needle cap"),
                        LocalizedString("Peel off the paper backing that covers the adhesive.", comment: "Attach pod step: remove adhesive backing"),
                        LocalizedString("Prepare the site on your body where the pod will go. The skin should be clean and dry.", comment: "Attach pod step: prepare site"),
                        LocalizedString("Stick the pod on. Make sure all the adhesive edges lie as flat and smooth as possible, with no folds.", comment: "Attach pod step: apply pod with smooth edges"),
                        LocalizedString("If it went on crooked, it is fine to peel part of it off and stick it down again.", comment: "Attach pod step: reapplying is fine"),
                    ])
                }
                .padding(.bottom, 8)
            }
            .accessibility(sortPriority: 1)
        }) {
            Button(action: {
                activeModal = .attachConfirmationModal
            }) {
                FrameworkLocalText("Continue", comment: "Action button title for attach pod view")
                    .accessibility(identifier: "button_next_action")
                    .actionButtonStyle(.primary)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .zIndex(1)
        }
        .alert(item: $activeModal, content: self.alert(for:))
        .navigationTitle(LocalizedString("Attach Pod", comment: "navigation bar title attach pod"))
        .navigationBarTitleDisplayMode(.automatic)
        .navigationBarItems(trailing: cancelButton)
        .navigationBarBackButtonHidden(true)
    }
    
    var cancelButton: some View {
        Button(LocalizedString("Cancel", comment: "Cancel button text in navigation bar on pair pod UI")) {
            activeModal = .cancelModal
        }
        .accessibility(identifier: "button_cancel")
    }

    private func alert(for modal: Modal) -> Alert {
        switch modal {
        case .attachConfirmationModal:
            return confirmationModal
        case .cancelModal:
            return cancelPairingModal
        }
    }
    
    var confirmationModal: Alert {
        return Alert(
            title: FrameworkLocalText("Confirm Pod Attachment", comment: "Alert title for confirm pod attachment"),
            message: FrameworkLocalText("Please confirm that the Pod is securely attached to your body.\n\nThe cannula can be inserted only once with each Pod. Tap “Confirm” when Pod is attached.", comment: "Alert message body for confirm pod attachment"),
            primaryButton: .default(FrameworkLocalText("Confirm", comment: "Button title for confirm attachment option"), action: didConfirmAttachment),
            secondaryButton: .cancel()
        )
    }
    
    var cancelPairingModal: Alert {
        return Alert(
            title: FrameworkLocalText("Are you sure you want to cancel Pod setup?", comment: "Alert title for cancel pairing modal"),
            message: FrameworkLocalText("If you cancel Pod setup, the current Pod will be deactivated and will be unusable.", comment: "Alert message body for confirm pod attachment"),
            primaryButton: .destructive(FrameworkLocalText("Yes, Deactivate Pod", comment: "Button title for confirm deactivation option"), action: didRequestDeactivation),
            secondaryButton: .default(FrameworkLocalText("No, Continue With Pod", comment: "Continue pairing button title of in pairing cancel modal"))
        )
    }
}

struct AttachPodView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ZStack {
                Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all)
                AttachPodView(didConfirmAttachment: {}, didRequestDeactivation: {}, podType: PodType(podType: .productIdDash))
            }
        }
    }
}
