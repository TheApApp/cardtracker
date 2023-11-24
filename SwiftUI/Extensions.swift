//
//  Extensions.swift
//  Card Tracker
//
//  Created by Michael Rowe on 9/22/23.
//  Copyright © 2023 Michael Rowe. All rights reserved.
//
// ToDo: DELETE THIS CODE

import SwiftUI


// Extension to safely access array elements
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

//extension View {
//    // MARK: Extracting View's Height and width with the Help of Hosting Control and ScrollView
//    func convertToScrollView<Content: View>(@ViewBuilder content: @escaping () -> Content ) -> UIScrollView {
//        let scrollView = UIScrollView()
//        // MARK: Converting SwiftUI View ot UIKit View
//        let hostingController = UIHostingController(rootView: content()).view!
//        hostingController.translatesAutoresizingMaskIntoConstraints = false
//
//        // MARK: Constraints
//        let constraints = [
//            hostingController.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            hostingController.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            hostingController.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            hostingController.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            // Width Anchor
//            hostingController.widthAnchor.constraint(equalToConstant: screenBounds().width)
//        ]
//
//        scrollView.addSubview(hostingController)
//        scrollView.addConstraints(constraints)
//        scrollView.layoutIfNeeded()
//
//        return scrollView
//    }
//
//    // MARK: Export to PDF
//    // MARK: Completion Handler will Send Status and URL
//    // swiftlint:disable line_length
//    func exportPDF<Content: View>(@ViewBuilder content: @escaping () -> Content, completion: @escaping (Bool, URL?) -> Void ) {
//        // MARK: Temp URL
//        let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
//        // MARK: To Generate New File whenever generated
//        let outputFileURL = documentDirectory.appendingPathComponent("Holiday-Tracker\(UUID().uuidString).pdf")
//
//        // MARK: PDF View
//        let pdfView = convertToScrollView {
//            content()
//        }
//        pdfView.tag = 1009
//        let size = pdfView.contentSize
//        print("Size is \(size)")
//        // Removing Safe Area Top Value
//        pdfView.frame = CGRect(x: 0, y: getSafeArea().top, width: size.width, height: size.height)
//
//        // MARK: Attaching to Root View and render
//        getRootController().view.insertSubview(pdfView, at: 0)
//
//        // MARK: Rendering PDF
//        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//        print("Renderer = \(renderer)")
//
//        do {
//            try renderer.writePDF(to: outputFileURL, withActions: { context in
//                print("Layering = \(context)")
//                context.beginPage()
//                print("Begin page = \(context.beginPage())")
//                pdfView.layer.render(in: context.cgContext)
//            })
//            print("Completion for file \(outputFileURL)")
//            completion(true, outputFileURL)
//
//        } catch {
//            print(error.localizedDescription)
//            completion(false, nil)
//        }
//        // Removing the added View
//        getRootController().view.subviews.forEach { view in
//            if view.tag == 1009 {
//                print("Removed")
//                view.removeFromSuperview()
//            }
//        }
//    }
//
//    func screenBounds() -> CGRect {
//        return UIScreen.main.bounds
//    }
//
//    func getRootController() -> UIViewController {
//        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
//            return .init()
//        }
//        guard let root = screen.windows.first?.rootViewController else {
//            return .init()
//        }
//        return root
//    }
//    
//    func getSafeArea() -> UIEdgeInsets {
//        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
//            return .zero
//        }
//        guard let safeArea = screen.windows.first?.safeAreaInsets else {
//            return .zero
//        }
//        return safeArea
//    }
//}
