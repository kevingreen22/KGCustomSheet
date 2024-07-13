<!-- Badges -->
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/) [![Platform](https://img.shields.io/cocoapods/p/FloatingLabelTextFieldSwiftUI.svg?style=flat)](https://cocoapods.org/pods/FloatingLabelTextFieldSwiftUI) [![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

# KGCustomSheet

A basic custom sheet with two presentation options, boolean or item. Similar to Apple's own impementation. 
If you like the project, please do not forget to `star ★` this repository and follow me on GitHub.


## 📦 Requirements

- iOS 13.0+
- Xcode 11.2+
- Swift 5.0


## Screenshots

![App Screenshot](https://github.com/kevingreen22/KGCustomSheet/blob/main/resources/KGCustomSheet_example.gif)

## Installation 

To install the component add it to your project using Swift Package Manager with url below,

```
https://github.com/kevingreen22/KGCustonSheet
```

Import the package.

```swift
import KGCustonSheet
```


## 💻 Examples

Here is a simple demo struct you can copy and paste to see usage detail. however it is very straight forward.

Examples:

```swift
struct ExampleView: View {
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
```
