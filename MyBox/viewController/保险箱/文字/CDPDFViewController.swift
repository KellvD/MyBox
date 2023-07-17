//
//  CDPDFViewController.swift
//  MyBox
//
//  Created by changdong on 2020/7/13.
//  Copyright changdong 2012-2019. All rights reserved.
//

import UIKit
import PDFKit

@available(iOS 11.0, *)
class CDPDFViewController: UIViewController {

    var filePath: String!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(pdfView)
        let pdfDoc = PDFDocument(url: filePath.url)
        pdfView.document = pdfDoc

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ddeko))
    }

    lazy private var pdfView: PDFView = {
        // 展示PDF
        let g_pdfView = PDFView(frame: view.bounds)
        g_pdfView.displayMode = .singlePage
        g_pdfView.displayDirection = .horizontal
        g_pdfView.usePageViewController(true, withViewOptions: [UIPageViewController.OptionsKey.interPageSpacing: 20])
        g_pdfView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
        return g_pdfView
    }()

    lazy var thumbView: PDFThumbnailView = {
        let g_thumbView = PDFThumbnailView(frame: self.view.bounds)
        g_thumbView.pdfView = pdfView
        g_thumbView.thumbnailSize = CGSize(width: (self.view.frame.width - 50)/4, height: 208)
        g_thumbView.backgroundColor = .red
        return g_thumbView
    }()

    @objc func onTap() {

    }

    @objc func ddeko() {
        pdfView.isHidden = true
        self.view .addSubview(thumbView)
    }
}
