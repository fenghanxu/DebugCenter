

import UIKit

// 日志等级：
public enum FHXLogType: Int, Codable {
    case debug = 0 // 日志
    case network   // 网络
    case error     // 错误
    case crash     // 崩溃
    
    var color: UIColor {
        switch self {
        case .debug:
            return Self.debugColor
        case .network:
            return Self.networkColor
        case .error:
            return Self.errorColor
        case .crash:
            return Self.crashColor
        }
    }


    private static let debugColor = UIColor(
        red: 0,
        green: 211 / 255,
        blue: 221 / 255,
        alpha: 1
    )

    private static let networkColor = UIColor(
        red: 0,
        green: 170 / 255,
        blue: 0,
        alpha: 1
    )

    private static let errorColor = UIColor(
        red: 255 / 255,
        green: 204 / 255,
        blue: 34 / 255,
        alpha: 1
    )

    private static let crashColor = UIColor(
        red: 255 / 255,
        green: 51 / 255,
        blue: 51 / 255,
        alpha: 1
    )
}

struct FHXLogHeightResult {

    /// 不限制情况下真实高度
    let normalHeight: CGFloat

    /// UITableView实际高度
    let cellHeight: CGFloat
}

struct FHXLogModel: Codable {

    /// 唯一标识
    let id: String
    
    /// Cell高度
    let cellHeight: CGFloat
    
    /// 内容真实高度，目的：控制展开按键是否显示
    let contentFullHeight: CGFloat

    /// (不用)日志内容
    let message: String
    
    /// 日志内容(富文本)
    let messageAttributed: NSAttributedString
    
    

    /// (不用)时间(不用，用timeString代替)
    let time: Date
    
    /// 时间字符串
    let timeString: String

    

    /// (不用)文件
    let file: String

    /// (不用)方法
    let function: String

    /// (不用)行数
    let line: Int
    
    /// 方法名
    let methodString: String
    
   
    
    /// (不会用)日志等级
    let level: FHXLogType

    init(
        id: String = UUID().uuidString,
        message: String,
        level: FHXLogType,
        time: Date,
        file: String,
        function: String,
        line: Int,
    ) {
        self.id = id
        self.message = message
        self.level = level
        self.time = time
        self.file = file
        self.function = function
        self.line = line
        self.timeString = Self.formatter.string(from: time)
        self.messageAttributed = NSAttributedString(string: message,attributes: Self.normalAttributes)
        self.methodString = "\(file)." + "\(function):" + "[\(line)] "
        let result = Self.calculateCellHeight(message: self.messageAttributed)
        self.contentFullHeight = result.normalHeight
        self.cellHeight = result.cellHeight
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        message = try container.decode(String.self, forKey: .message)
        level = try container.decode(FHXLogType.self, forKey: .level)
        time = try container.decode(Date.self, forKey: .time)
        timeString = try container.decode(String.self, forKey: .timeString)
        file = try container.decode(String.self, forKey: .file)
        function = try container.decode(String.self, forKey: .function)
        line = try container.decode(Int.self, forKey: .line)
        cellHeight = try container.decode(CGFloat.self, forKey: .cellHeight)
        methodString = try container.decode(String.self, forKey: .methodString)
        messageAttributed = NSAttributedString(string: message, attributes: Self.normalAttributes)
        contentFullHeight = try container.decode(CGFloat.self, forKey: .contentFullHeight)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(message, forKey: .message)
        try container.encode(level, forKey: .level)
        try container.encode(time, forKey: .time)
        try container.encode(timeString, forKey: .timeString)
        try container.encode(file, forKey: .file)
        try container.encode(function, forKey: .function)
        try container.encode(line, forKey: .line)
        try container.encode(cellHeight, forKey: .cellHeight)
        try container.encode(methodString, forKey: .methodString)
        try container.encode(contentFullHeight, forKey: .contentFullHeight)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case message
        case level
        case time
        case timeString
        case file
        case function
        case line
        case cellHeight
        case methodString
        case contentFullHeight
    }
    
    private static let maxCellHeight: CGFloat = 200
    
    // 初始化富文本 paragraphStyle 目的不用每次重复创建
    private static let paragraphStyle: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 8
        return style

    }()
    
    // 初始化富文本 paragraphStyle 目的不用每次重复创建
    private static let normalAttributes: [NSAttributedString.Key: Any] = [
        .paragraphStyle: paragraphStyle,
        .font: UIFont.systemFont(ofSize: 14),
        .foregroundColor: UIColor.black
    ]
    
    /// DateFormatter（全局只创建一次）
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        return formatter
    }()
    
    // 计算Cell的高度
    private static func calculateCellHeight(message: NSAttributedString) -> FHXLogHeightResult {
        let width = UIScreen.main.bounds.width - 20

        let rect = message.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        let contentHeight = ceil(rect.height)

        let normalHeight =
            10 +      // top
            22 +      // level
            5 +       // spacing
            20 +      // method
            5 +       // spacing
            contentHeight +
            10 +      // bottom
            1
        
        return FHXLogHeightResult(
            normalHeight: normalHeight, //真实高度
            cellHeight: min(normalHeight, maxCellHeight) // 最大限制200
        )
    }
    
}

public class FHXLog {

    // MARK: - singleton
    public static let shared = FHXLog()
    private init() {}

    // MARK: - storage
    private let store = FHXLogStore()

    // MARK: - config（来自 SPLogs 思想）
    
    /// 总开关
    var isEnabled: Bool = true

    /// 最大日志数量
    var maxCount: Int = 1000

    /// 输出等级控制
    var logLevel: FHXLogType = .debug
    
    private var lastNetworkURL: String?
    private var lastNetworkTime: TimeInterval = 0

    // MARK: - MARK: logging core
    
    public func log(
        _ message: Any,
        _ level: FHXLogType = .debug,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {

        saveLog(
            String(describing: message),
            level: level,
            file: file,
            function: function,
            line: line
        )
    }

}

// MARK: - 备用
extension FHXLog {
    public func network(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        saveLog(message, level: .network, file: file, function: function, line: line)
    }

    public func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        saveLog(message, level: .debug, file: file, function: function, line: line)
    }

    public func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        saveLog(message, level: .crash, file: file, function: function, line: line)
    }

    public func error(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        saveLog(message, level: .error, file: file, function: function, line: line)
    }
}

extension FHXLog {

    /// 获取当前日志数据
    func currentLogs() -> [FHXLogModel] {
        store.currentLogs()
    }

    /// 获取历史日志数据
    func historyLogs() -> [FHXLogModel] {
        store.historyLogs()
    }
    
    /// 清空当前日志
    func clearCurrentLogs() {
        store.clearCurrentLogs()
    }
    
    /// 清空历史日志
    func clearHistoryLogs() {
        store.clearHistoryLogs()
    }
    
    /// 删除当前日志单条数据
    func deleteCurrentLog(id: String) {
        store.deleteCurrentLog(id: id)
    }
    
    /// 删除历史日志单条数据
    func deleteHistoryLog(id: String) {
        store.deleteHistoryLog(id: id)
    }

    /// 删除当前日志多条数据
    func deleteCurrentLogs(ids: [String]) {
        store.deleteCurrentLogs(ids: ids)
    }
    
    /// 删除当历史志多条数据
    func deleteHistoryLogs(ids: [String]) {
        store.deleteHistoryLogs(ids: ids)
    }
    
    /// 获取当前日志数量
    func currentLogCount() -> Int {
        store.currentCount()
    }
    
    /// 获取历史日志数量
    func historyLogCount() -> Int {
        store.historyCount()
    }

    /// 更新日志(当前日志 +  历史日志)
    func updateLog(
        _ model: FHXLogModel
    ) {
        store.update(model)
    }


}

// MARK: 导出功能
extension FHXLog {

    /// 整理 TXT
    private func organizeTXT(logs: [FHXLogModel]) -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return logs.map {

            """
            [\(formatter.string(from: $0.time))]
            [\($0.level)]
            \($0.file).\($0.function):[\($0.line)]
            \($0.message)

            """
        }
        .joined(separator: "\n")
    }

    /// 导出 TXT
    private func exportTXTFile(
        logs: [FHXLogModel],
        prefix: String
    ) throws -> URL {

        let txt = organizeTXT(logs: logs)

        let fileURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(
                "\(prefix)_\(Int(Date().timeIntervalSince1970)).txt"
            )

        try txt.write(
            to: fileURL,
            atomically: true,
            encoding: .utf8
        )

        return fileURL
    }

    /// 导出 JSON
    private func exportJSONFile(
        logs: [FHXLogModel],
        prefix: String
    ) throws -> URL {

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(logs)

        let fileURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(
                "\(prefix)_\(Int(Date().timeIntervalSince1970)).json"
            )

        try data.write(to: fileURL)

        return fileURL
    }
    
    private func extractURL(from message: String) -> String? {

        let pattern = #"URL\s*:?\s*(https?://[^\s]+)"#

        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: []
        ) else {
            return nil
        }


        let range = NSRange(
            message.startIndex..<message.endIndex,
            in: message
        )


        guard let result = regex.firstMatch(
            in: message,
            options: [],
            range: range
        ) else {
            return nil
        }


        guard let urlRange = Range(
            result.range(at: 1),
            in: message
        ) else {
            return nil
        }


        return String(message[urlRange])
    }
}

extension FHXLog {

    // MARK: 当前日志

    func exportCurrentLogsTXTFile() throws -> URL {
        try exportTXTFile(
            logs: currentLogs(),
            prefix: "FHXCurrentLog"
        )
    }

    func exportCurrentLogsJSONFile() throws -> URL {
        try exportJSONFile(
            logs: currentLogs(),
            prefix: "FHXCurrentLog"
        )
    }

    // MARK: 历史日志

    func exportHistoryLogsTXTFile() throws -> URL {
        try exportTXTFile(
            logs: historyLogs(),
            prefix: "FHXHistoryLog"
        )
    }

    func exportHistoryLogsJSONFile() throws -> URL {
        try exportJSONFile(
            logs: historyLogs(),
            prefix: "FHXHistoryLog"
        )
    }
}

private extension FHXLog {

    func saveLog(
        _ message: String,
        level: FHXLogType,
        file: String,
        function: String,
        line: Int
    ) {

        // 开关
        guard isEnabled else { return }
        
        if level == .network {

            let now = Date().timeIntervalSince1970


            // 提取URL
            let url = extractURL(from: message)


            print("========== URL去重测试 ==========")
            print("URL:", url ?? "nil")
            print("lastURL:", lastNetworkURL ?? "nil")
            print("时间差:", now - lastNetworkTime)
            print("=============================")


            if let url = url,
               url == lastNetworkURL,
               now - lastNetworkTime < 1.5 { // 1.5秒
                print("网络日志URL去重成功")
                return
            }

            lastNetworkURL = url
            lastNetworkTime = now
        }

        let fileName = URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent

        let model = FHXLogModel(
            message: message,
            level: level,
            time: Date(),
            file: fileName,
            function: function,
            line: line,
        )

        // 存储
        store.append(model, maxCount: maxCount)

    }
}
