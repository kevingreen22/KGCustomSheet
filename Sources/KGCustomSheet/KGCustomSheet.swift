//
//  CustomSheets.swift
//
//  Created by Kevin Green on 1/1/24.
//

import SwiftUI

@available(iOS 13.0, *)
private struct CustomBoolSheet<SheetContent>: View where SheetContent: View {
    @Binding var isPresented: Bool
    @ViewBuilder var sheetContent: ()->SheetContent
    
    @Environment(\.horizontalSizeClass) private var hz
    @Environment(\.verticalSizeClass) private var vz
    @GestureState private var dragState = SheetDragState.inactive
    @State private var position: SheetPositionState = .partiallyRevealed
    @State private var offset: CGSize = .zero
    @State private var opacity = 0.4
    var showDragIndicator: Visibility = .visible
    var showCloseButton: Visibility = .visible
    var cornerRadius: CGFloat = 30
    var animation: Animation {
        Animation.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)
    }
    
    init(isPresented: Binding<Bool>, sheetContent: @escaping ()->SheetContent) {
        _isPresented = isPresented
        self.sheetContent = sheetContent
    }
    
    init(isPresented: Binding<Bool>,
         showDragIndicator: Visibility = .visible,
         showCloseButton: Visibility = .visible,
         cornerRadius: CGFloat = 30,
         sheetContent: @escaping ()->SheetContent)
    {
        _isPresented = isPresented
        self.showDragIndicator = showDragIndicator
        self.showCloseButton = showCloseButton
        self.cornerRadius = cornerRadius
        self.sheetContent = sheetContent
    }
    
    var body: some View {
        if isPresented {
            ZStack(alignment: vz == .compact ? .leading : .bottom) {
                disabledPresentationView
                mainSheetView
                    .background(Color.white)
                    .mask(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .shadow(color: .black.opacity(0.5), radius: 10)
                    .offset(y: max(0, self.position.offsetFromTop() + self.dragState.translation.height))
                    .animation(self.dragState.isDragging ? nil : animation, value: position)
                    .gesture(
                        DragGesture()
                            .updating($dragState) { drag, state, transaction in state = .dragging(translation: drag.translation)
                            }
                            .onChanged {
                                self.offset = $0.translation
                            }
                            .onEnded(onDragEnded)
                    )
            }
            .onAppear {
                self.position = .fullscreen
                self.opacity = 0.4
            }
        }
        
    }
    
    fileprivate var disabledPresentationView: some View {
        Color.black
            .opacity(opacity)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                dismissSheet()
            }
    }
    
    fileprivate var header: some View {
        ZStack(alignment: .top) {
            shouldShowDragIndicator()
            shouldShowCloseButton()
        }
    }
    
    @ViewBuilder fileprivate var mainSheetView: some View {
        if vz == .compact {
            ZStack(alignment: .top) {
                sheetContent()
                header
            }
        } else {
            ZStack(alignment: .top) {
                sheetContent()
                header
            }
        }
    }
    
    @ViewBuilder fileprivate func shouldShowDragIndicator() -> some View {
        switch showDragIndicator {
        case .automatic: dragIndicator
        case .hidden: EmptyView()
        case .visible: dragIndicator
        }
    }
    
    fileprivate var dragIndicator: some View {
        let handleThickness = CGFloat(5.0)
        return RoundedRectangle(cornerRadius: handleThickness / 2.0)
            .frame(width: 40, height: handleThickness)
            .foregroundColor(Color.secondary)
            .padding(5)
    }
    
    @ViewBuilder fileprivate func shouldShowCloseButton() -> some View {
        switch showCloseButton {
        case .automatic, .visible: closeButton
        case .hidden: EmptyView()
        }
    }
    
    fileprivate var closeButton: some View {
        HStack {
            Spacer()
            Button(action: {
                dismissSheet()
            }, label: {
                Image(systemName: "xmark")
                    .padding(4)
                    .foregroundColor(Color.white)
                    .padding(4)
                    .background(Circle().fill(Color.black.opacity(0.6)))
                    .padding()
            })
        }
    }
    
    fileprivate func onDragEnded(drag: DragGesture.Value) {
        // Setting stops
        let higherStop: SheetPositionState
        let lowerStop: SheetPositionState
        
        // Nearest position for drawer to snap to.
        let nearestPosition: SheetPositionState
        
        // Determining the direction of the drag gesture and its distance from the top
        let dragDirection = drag.predictedEndLocation.y - drag.location.y
        let offsetFromTopOfView = position.offsetFromTop() + drag.translation.height
        
        // Determining whether drawer is above or below `.partiallyRevealed` threshold for snapping behavior.
        if offsetFromTopOfView <= SheetPositionState.partiallyRevealed.offsetFromTop() {
            higherStop = .fullscreen
            lowerStop = .partiallyRevealed
        } else {
            higherStop = .partiallyRevealed
            lowerStop = .hidden
        }
        
        // Determining whether drawer is closest to top or bottom
        if (offsetFromTopOfView - higherStop.offsetFromTop()) < (lowerStop.offsetFromTop() - offsetFromTopOfView) {
            nearestPosition = higherStop
        } else {
            nearestPosition = lowerStop
        }
        
        // Determining the drawer's position.
        if dragDirection > 0 {
            position = lowerStop
            if drag.velocity.height > 100000 {
                dismissSheet()
            }
        } else if dragDirection < 0 {
            position = higherStop
        } else {
            position = nearestPosition
        }
        
        // Full dismiss of view.
        if position == .hidden {
            dismissSheet()
        }
    }
    
    fileprivate func dismissSheet() {
        withAnimation(.easeInOut) {
            self.position = .hidden
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                isPresented = false
                self.opacity = 0
            }
        }
    }
    
}


@available(iOS 13.0, *)
private struct CustomItemSheet<Item, SheetContent>: View where Item: Identifiable, SheetContent: View {
    @Binding var item: Item?
    @ViewBuilder var sheetContent: ()->SheetContent
    
    @Environment(\.horizontalSizeClass) private var hz
    @Environment(\.verticalSizeClass) private var vz
    @GestureState private var dragState = SheetDragState.inactive
    @State private var position: SheetPositionState = .partiallyRevealed
    @State private var offset: CGSize = .zero
    @State private var opacity = 0.4
    var animation: Animation {
        Animation.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)
    }
    var showDragIndicator: Visibility = .visible
    var showCloseButton: Visibility = .visible
    var cornerRadius: CGFloat = 30
        
    init(item: Binding<Item?>, sheetContent: @escaping ()->SheetContent) {
        _item = item
        self.sheetContent = sheetContent
    }
    
    init(item: Binding<Item?>,
         showDragIndicator: Visibility = .visible,
         showCloseButton: Visibility = .visible,
         cornerRadius: CGFloat = 30,
         sheetContent: @escaping ()->SheetContent)
    {
        _item = item
        self.showDragIndicator = showDragIndicator
        self.showCloseButton = showCloseButton
        self.cornerRadius = cornerRadius
        self.sheetContent = sheetContent
    }
    
    public var body: some View {
        if item != nil {
            ZStack(alignment: vz == .compact ? .leading : .bottom) {
                disabledPresentationView
                mainSheetView
                    .background(Color.white)
                    .mask(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .shadow(color: .black.opacity(0.5), radius: 10)
                    .offset(y: max(0, self.position.offsetFromTop() + self.dragState.translation.height))
                    .animation(self.dragState.isDragging ? nil : animation, value: position)
                    .gesture(
                        DragGesture()
                            .updating($dragState) { drag, state, transaction in state = .dragging(translation: drag.translation)
                            }
                            .onChanged {
                                self.offset = $0.translation
                            }
                            .onEnded(onDragEnded)
                    )
            }
            .onAppear {
                self.position = .fullscreen
                self.opacity = 0.4
            }
        }
    }
    
    fileprivate var disabledPresentationView: some View {
        Color.black
            .opacity(opacity)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                dismissSheet()
            }
    }
    
    fileprivate var header: some View {
        ZStack(alignment: .top) {
            shouldShowDragIndicator()
            shouldShowCloseButton()
        }
    }
    
    @ViewBuilder fileprivate var mainSheetView: some View {
        if vz == .compact {
            ZStack(alignment: .top) {
                sheetContent()
                header
            }
        } else {
            ZStack(alignment: .top) {
                sheetContent()
                header
            }
        }
    }
    
    fileprivate func onDragEnded(drag: DragGesture.Value) {
        // Setting stops
        let higherStop: SheetPositionState
        let lowerStop: SheetPositionState
        
        // Nearest position for drawer to snap to.
        let nearestPosition: SheetPositionState
        
        // Determining the direction of the drag gesture and its distance from the top
        let dragDirection = drag.predictedEndLocation.y - drag.location.y
        let offsetFromTopOfView = position.offsetFromTop() + drag.translation.height
        
        // Determining whether drawer is above or below `.partiallyRevealed` threshold for snapping behavior.
        if offsetFromTopOfView <= SheetPositionState.partiallyRevealed.offsetFromTop() {
            higherStop = .fullscreen
            lowerStop = .partiallyRevealed
        } else {
            higherStop = .partiallyRevealed
            lowerStop = .hidden
        }
        
        // Determining whether drawer is closest to top or bottom
        if (offsetFromTopOfView - higherStop.offsetFromTop()) < (lowerStop.offsetFromTop() - offsetFromTopOfView) {
            nearestPosition = higherStop
        } else {
            nearestPosition = lowerStop
        }
        
        // Determining the drawer's position.
        if dragDirection > 0 {
            position = lowerStop
            if drag.velocity.height > 100000 {
                dismissSheet()
            }
        } else if dragDirection < 0 {
            position = higherStop
        } else {
            position = nearestPosition
        }
        
        // Full dismiss of view.
        if position == .hidden {
            dismissSheet()
        }
    }
    
    fileprivate func dismissSheet() {
        withAnimation(.easeInOut) {
            self.position = .hidden
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                item = nil
                self.opacity = 0
            }
        }
    }
    
    @ViewBuilder fileprivate func shouldShowDragIndicator() -> some View {
        switch showDragIndicator {
        case .automatic: dragIndicator
        case .hidden: EmptyView()
        case .visible: dragIndicator
        }
    }
    
    fileprivate var dragIndicator: some View {
        let handleThickness = CGFloat(5.0)
        return RoundedRectangle(cornerRadius: handleThickness / 2.0)
            .frame(width: 40, height: handleThickness)
            .foregroundColor(Color.secondary)
            .padding(5)
    }
    
    @ViewBuilder fileprivate func shouldShowCloseButton() -> some View {
        switch showCloseButton {
        case .automatic, .visible: closeButton
        case .hidden: EmptyView()
        }
    }
    
    fileprivate var closeButton: some View {
        HStack {
            Spacer()
            Button(action: {
                dismissSheet()
            }, label: {
                Image(systemName: "xmark")
                    .padding(4)
                    .foregroundColor(Color.white)
                    .padding(4)
                    .background(Circle().fill(Color.black.opacity(0.6)))
                    .padding()
            })
        }
    }
    
}


fileprivate enum SheetDragState {
    case inactive
    case dragging(translation: CGSize)

    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }

    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}

fileprivate enum SheetPositionState: CGFloat {
    case hidden, partiallyRevealed, fullscreen
    
    func offsetFromTop() -> CGFloat {
        switch self {
        case .hidden:
            return UIScreen.main.bounds.height + 42
        case .partiallyRevealed:
            return UIScreen.main.bounds.height/1.8
        case .fullscreen:
            return 40
        }
    }
}



// MARK: Public extensions
@available(iOS 13.0, *)
public extension View {
    /// Presents a sheet when a binding to a Boolean value that you provide is true.
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether to present the sheet that you create in the modifier’s content closure.
    ///   - onDismiss:  The closure to execute when dismissing the sheet.
    ///   - content: A closure that returns the content of the sheet.
    ///
    /// In vertically compact environments, such as iPhone in landscape orientation, a sheet presentation automatically adapts to appear with a smaller width aligned to the leading edge.
    @ViewBuilder func customSheet<Content>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping ()->Content) -> some View where Content: View {
        ZStack(alignment: .top) {
            self.frame(maxWidth: .infinity)
            
            if isPresented.wrappedValue {
                CustomBoolSheet(isPresented: isPresented) { content() }
                    .onDisappear(perform: onDismiss)
                    .frame(alignment: .top)
            }
        }
    }
    
    /// Presents a sheet using the given item as a data source for the sheet’s content.
    /// - Parameters:
    ///   - item: A binding to an optional source of truth for the sheet. When item is non-nil, the system passes the item’s content to the modifier’s closure. You display this content in a sheet that you create that the system displays to the user. If item changes, the system dismisses the sheet and replaces it with a new one using the same process.
    ///   - onDismiss:  The closure to execute when dismissing the sheet.
    ///   - content: A closure that returns the content of the sheet.
    ///
    /// In vertically compact environments, such as iPhone in landscape orientation, a sheet presentation automatically adapts to appear with a smaller width aligned to the leading edge.
    
    @ViewBuilder func customSheet<Item, Content>(item: Binding<Item?>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping (Item)->Content) -> some View where Item : Identifiable, Content : View {
        ZStack(alignment: .top) {
            self.frame(maxWidth: .infinity)
            
            if item.wrappedValue != nil {
                CustomItemSheet(item: item) { content(item.wrappedValue!) }
                    .onDisappear(perform: onDismiss)
            }
        }
    }
    
}


public enum Visibility {
    case automatic, visible, hidden
}



// MARK: Demo
fileprivate class MockData: Identifiable {
    var id: String
    var data = ["Item1, Item2, Item3, Item4"]
    init() { self.id = UUID().uuidString }
}

@available(iOS 13.0, *)
fileprivate struct ExampleView: View {
    @State var showSheet = false
    @State var item: MockData? = nil
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 20) {
                HStack(spacing: 0) {
                    Button("Bool Sheet") { showSheet.toggle() }
                    Text("(\(showSheet.description))")
                        .foregroundColor(Color.gray)
                }
                Spacer()
                Button("Item Sheet") {
                    item = MockData()
                }
            }
            Spacer()
        }.padding(.horizontal)
        
        .customSheet(isPresented: $showSheet, onDismiss: { print("custom sheet dismissed") }) {
            ZStack {
                Color.green.edgesIgnoringSafeArea(.all)
                Text("Bool Sheet Example").font(.largeTitle)
            }.edgesIgnoringSafeArea(.all)
        }
    
        .customSheet(item: $item, onDismiss: nil) { item in
            ZStack {
                Color.orange
                ForEach(item.data, id: \.self) { i in
                    Text(i).font(.largeTitle)
                }
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

@available(iOS 13.0.0, *)
fileprivate struct KGCustomSheet_Preview: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}

@available(iOS 13.0.0, *)
#Preview {
    ExampleView()
}

