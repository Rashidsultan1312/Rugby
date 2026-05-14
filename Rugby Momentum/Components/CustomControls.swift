import SwiftUI

// MARK: - Custom Toggle (Rugby style)

struct CustomToggle: View {
    let title: String
    @Binding var isOn: Bool
    var icon: String = "hand.tap.fill"
    
    var body: some View {
        Button(action: {
            HapticService.shared.lightImpact()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                isOn.toggle()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.primaryRed)
                    .frame(width: 28, alignment: .center)
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                ZStack(alignment: isOn ? .trailing : .leading) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isOn ? Color.primaryRed.opacity(0.3) : Color.softGray)
                        .frame(width: 52, height: 28)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isOn ? Color.primaryRed : Color.gray.opacity(0.5))
                        .frame(width: 24, height: 24)
                        .padding(2)
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                }
                .frame(width: 52, height: 28)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Text Field (Rugby style)

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var alignment: TextAlignment = .leading
    
    var body: some View {
        ZStack(alignment: alignment == .trailing ? .trailing : .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.8))
                    .padding(.horizontal, 16)
            }
            
            TextField("", text: $text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(alignment)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.softGray)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryRed.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Custom Segmented Control (Rugby style)

struct RugbySegmentedControl<T: Hashable>: View {
    let options: [T]
    @Binding var selection: T
    var label: (T) -> String
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                let isSelected = selection == option
                Button(action: {
                    HapticService.shared.selectionChanged()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = option
                    }
                }) {
                    Text(label(option))
                        .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .pureWhite : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? LinearGradient.redGradient : LinearGradient(colors: [Color.softGray], startPoint: .leading, endPoint: .trailing))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.clear : Color.primaryRed.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Custom Confirm Popup (replaces system Alert)

struct CustomConfirmPopup: View {
    let title: String
    let message: String
    let confirmTitle: String
    let confirmRole: ConfirmRole
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    enum ConfirmRole {
        case destructive
        case `default`
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }
            
            VStack(spacing: 20) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 12) {
                    Button(action: {
                        HapticService.shared.lightImpact()
                        onCancel()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.softGray)
                            )
                    }
                    
                    Button(action: {
                        HapticService.shared.mediumImpact()
                        onConfirm()
                    }) {
                        Text(confirmTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.pureWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.primaryRed)
                            )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.pureWhite)
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            )
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Rugby Separator (replaces system Divider)

struct RugbySeparator: View {
    var body: some View {
        Rectangle()
            .fill(Color.primaryRed.opacity(0.15))
            .frame(height: 1)
            .padding(.leading, 46)
    }
}

// MARK: - Custom Sheet Header (back button + title, no system nav bar)

struct CustomSheetHeader: View {
    let title: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                HapticService.shared.lightImpact()
                onDismiss()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.primaryRed)
            }
            
            Spacer()
            
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Color.clear
                .frame(width: 70, height: 24)
            }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.pureWhite)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.softGray),
            alignment: .bottom
        )
    }
}

