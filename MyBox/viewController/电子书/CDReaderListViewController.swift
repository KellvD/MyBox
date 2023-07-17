//
//  CDReaderViewController.swift
//  MyBox
//
//  Created by changdong  on 2020/6/10.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit

class CDReaderListViewController: CDBaseAllViewController {

    private var tabView: UITableView!
    private var dataArr: [CDNovelInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        hiddBackbutton()
        tabView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH), style: .plain)
        tabView.delegate = self
        tabView.dataSource = self
        tabView.separatorStyle = .none
        view.addSubview(tabView)

        let rightItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNovelClick))
        rightItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = rightItem
        loadNovel()
    }

    @objc private func addNovelClick() {
        let documentTypes = ["public.text"]
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        if #available(iOS 11, *) {
            documentPicker.allowsMultipleSelection = true
        }
        CDSignalTon.shared.customPickerView = documentPicker
        self.present(documentPicker, animated: true, completion: nil)
    }

    private func loadNovel() {
        self.dataArr = CDSqlManager.shared.queryAllNovel()
        self.noMoreDataView.isHidden = self.dataArr.count > 0
        self.tabView.reloadData()
    }

    // MARK: UIDocumentPickerDelegate
    override func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        CDSignalTon.shared.customPickerView = nil
        var index = 0
        func handleAllDocumentPickerFiles(urlArr: [URL]) {
            DispatchQueue.global().async {
                var tmpUrlArr = urlArr
                if urlArr.count > 0 {
                    index += 1
                    let subUrl = urlArr.first!
                    let fileUrlAuthozied = subUrl.startAccessingSecurityScopedResource()
                    if fileUrlAuthozied {
                        let fileCoordinator = NSFileCoordinator()

                        fileCoordinator.coordinate(readingItemAt: subUrl, options: [], error: nil) {[unowned self] (newUrl) in
                            self.savelNovel(novelUrl: newUrl)
                            tmpUrlArr.removeFirst()
                            handleAllDocumentPickerFiles(urlArr: tmpUrlArr)
                        }
                    }
                    DispatchQueue.main.async {
                        CDHUDManager.shared.updateProgress(num: Float(index)/Float(urls.count), text: "\(index)/\(urls.count)")
                    }
                } else {
                    DispatchQueue.main.async { [self] in
                        CDHUDManager.shared.hideProgress()
                        CDHUDManager.shared.showComplete("导入完成".localize)
                        self.loadNovel()
                    }
                }
            }
        }
        handleAllDocumentPickerFiles(urlArr: urls)
        CDHUDManager.shared.showProgress("开始导入".localize)
    }

    private func savelNovel(novelUrl: URL) {
        do {
            let data = try Data(contentsOf: novelUrl)
            let path = novelUrl.absoluteString
            let novelName = path.fileName
            let suffix = path.suffix
            let novelPath = String.NovelPath().appendingFormat("%@.%@", novelName, suffix)
            try data.write(to: novelPath.url)
            let novelInfo = CDNovelInfo()
            novelInfo.importTime = GetTimestamp(nil)
            novelInfo.novelPath = novelPath.relativePath
            novelInfo.novelName = novelName
            CDSqlManager.shared.addNovelInfo(novel: novelInfo)
        } catch {
            CDPrintManager.log("保存小说失败:\(error.localizedDescription)", type: .ErrorLog)
        }

    }

}

extension CDReaderListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "ReadCellIde")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ReadCellIde")
            let view = UIView()
            cell.selectedBackgroundView = view
            cell.selectedBackgroundView?.backgroundColor = .cellSelectColor

            let headImage = UIImageView(frame: CGRect(x: 10, y: 10, width: 45, height: 45))
            headImage.tag = 101
            cell.contentView.addSubview(headImage)

            let fileNameL = UILabel(frame: CGRect(x: headImage.frame.maxX+10, y: 20, width: CDSCREEN_WIDTH-75, height: 25))
            fileNameL.textColor = .textBlack
            fileNameL.font = .mid
            fileNameL.lineBreakMode = .byTruncatingMiddle
            fileNameL.textAlignment = .left
            fileNameL.tag = 102
            cell.contentView.addSubview(fileNameL)

            let line = UIView(frame: CGRect(x: 5, y: 64, width: CDSCREEN_WIDTH-10, height: 1))
            line.backgroundColor = .separatorColor
            line.tag = 104
            cell.contentView.addSubview(line)
        }
        let headImage = cell.contentView.viewWithTag(101) as! UIImageView
        let fileNameL = cell.contentView.viewWithTag(102) as! UILabel
        let line = cell.contentView.viewWithTag(104)

        let gfile = dataArr[indexPath.row]
        headImage.image = LoadImage("file_txt_big")
        fileNameL.text = gfile.novelName
        line?.isHidden = indexPath.row == dataArr.count - 1
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let info = dataArr[indexPath.row]

        let readVC = CDReaderPageViewController()
        readVC.hidesBottomBarWhenPushed = true
        readVC.resource = info.novelPath.rootPath
        self.navigationController?.pushViewController(readVC, animated: true)

    }

    @available(iOS, introduced: 8.0, deprecated: 13.0)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let info = dataArr[indexPath.row]
        let detail = UITableViewRowAction(style: .normal, title: "删除".localize) { (_, _) in
            info.novelPath.rootPath.delete()
            CDSqlManager.shared.deleteOneNovel(novelId: info.novelId)
        }
        return [detail]
    }

    @available(iOS 11, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let info = dataArr[indexPath.row]

        let delete = UIContextualAction(style: .normal, title: "删除".localize) { (_, _, _) in
            info.novelPath.rootPath.delete()
            CDSqlManager.shared.deleteOneNovel(novelId: info.novelId)

        }
        delete.backgroundColor = .red
        let action = UISwipeActionsConfiguration(actions: [delete])
        return action
    }
}
