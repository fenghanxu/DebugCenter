

// 该文件只会在FHXLog用，FHXLog提供给外面用

import Foundation

final class FHXLogStore {
    
    // MARK: - Data

    /// 当前运行日志
    private var currentLogList: [FHXLogModel] = []

    /// 历史持久化日志
    private var historyLogList: [FHXLogModel] = []
    
    /// 创建串行队列
    private let queue = DispatchQueue(label: "fhx.log.queue")
    
    // MARK: - File路径

    private lazy var fileURL: URL = {
        let document = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        return document.appendingPathComponent(
            "fhx_logs.json"
        )
    }()

    // MARK: - Init

    init() {
        loadHistory()
    }

}

// MARK: - 读取

private extension FHXLogStore {
    private func loadHistory() {
        queue.sync {
            guard FileManager.default.fileExists(
                atPath: fileURL.path
            ) else {
                return
            }

            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                historyLogList = try decoder.decode([FHXLogModel].self,from: data)
            } catch {
                print("FHXLog load error:", error)

            }
        }
    }
}

// MARK: 新增日志

extension FHXLogStore {
    func append(
        _ log: FHXLogModel,
        maxCount: Int
    ) {
        queue.async {
            self.currentLogList.append(log)
            self.historyLogList.append(log)
            if self.currentLogList.count > maxCount {
                let overflow = self.currentLogList.count - maxCount
                self.currentLogList.removeFirst(overflow)
            }

            if self.historyLogList.count > maxCount {
                let overflow = self.historyLogList.count - maxCount
                self.historyLogList.removeFirst(overflow)
            }

            self.saveHistoryData()
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .logDidAppendCurrentData,
                    object: log
                )
            }
        }
    }
}

// MARK: 查询

extension FHXLogStore {

    /// 获取当前日志
    func currentLogs() -> [FHXLogModel] {
        queue.sync {
            currentLogList
        }
    }

    /// 获取历史日志
    func historyLogs() -> [FHXLogModel] {
        queue.sync {
            historyLogList
        }
    }

    /// 获取当前日志数量
    func currentCount() -> Int {
        queue.sync {
            currentLogList.count
        }
    }

    /// 获取历史日志数量
    func historyCount() -> Int {
        queue.sync {
            historyLogList.count
        }
    }

    /// 获取当前日志第一个模型
    func currentFirst() -> FHXLogModel? {
        queue.sync {
            currentLogList.first
        }
    }

    /// 获取当前日志最后一个模型
    func currentLast() -> FHXLogModel? {
        queue.sync {
            currentLogList.last
        }
    }

    /// 获取历史第一个模型
    func historyFirst() -> FHXLogModel? {
        queue.sync {
            historyLogList.first
        }
    }

    /// 获取历史最后一个模型
    func historyLast() -> FHXLogModel? {
        queue.sync {
            historyLogList.last
        }
    }
}

// MARK: 删除单条

extension FHXLogStore {

    func deleteCurrentLog(
        id: String
    ) {
        queue.async {
            self.currentLogList.removeAll {$0.id == id}
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .fhxLogDidDelete,
                    object: id
                )
            }
        }
    }
    
    func deleteHistoryLog(
        id: String
    ) {
        queue.async {
            self.historyLogList.removeAll { $0.id == id }
            self.saveHistoryData()
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .fhxLogDidDelete,
                    object: id
                )
            }
        }
    }
    
}

// MARK: 删除多条

extension FHXLogStore {

    /// 清空当前日志
    func deleteCurrentLogs(
        ids: [String]
    ) {
        queue.async {
            self.currentLogList.removeAll {
                ids.contains($0.id)
            }
        }
    }
    
    /// 清空历史数据 = 删除全部历史日志
    func deleteHistoryLogs(
        ids: [String]
    ) {
        queue.async {
            self.historyLogList.removeAll {
                ids.contains($0.id)
            }
            self.saveHistoryData()
        }
    }
    
}

// MARK: 清空

extension FHXLogStore {

    func clearCurrentLogs() {

        queue.async {

            self.currentLogList.removeAll()

            DispatchQueue.main.async {

                NotificationCenter.default.post(
                    name: .logDidClearCurrentData,
                    object: nil
                )
            }
        }
    }
    
    func clearHistoryLogs() {

        queue.async {

            self.historyLogList.removeAll()

            self.saveHistoryData()

            DispatchQueue.main.async {

                NotificationCenter.default.post(
                    name: .logDidClearHistoryData,
                    object: nil
                )
            }
        }
    }
    
}

// MARK: 更新（虽然日志通常不会更新，备用）

extension FHXLogStore {

    func update(
        _ model: FHXLogModel
    ) {

        queue.async {
            if let index =
                self.currentLogList.firstIndex(
                    where: { $0.id == model.id }
                ) {
                self.currentLogList[index] = model
            }

            if let index =
                self.historyLogList.firstIndex(
                    where: { $0.id == model.id }
                ) {
                self.historyLogList[index] = model
            }

            self.saveHistoryData()

            DispatchQueue.main.async {

                NotificationCenter.default.post(
                    name: .fhxLogDidUpdate,
                    object: model
                )
            }
        }
    }
}

// MARK: 保存

private extension FHXLogStore {

    func saveHistoryData() {

        do {

            let encoder = JSONEncoder()

            encoder.dateEncodingStrategy = .iso8601

            let data =
            try encoder.encode(historyLogList)

            try data.write(
                to: fileURL,
                options: .atomic
            )

        } catch {

            print(
                "FHXLog save error:",
                error
            )
        }
    }
}
