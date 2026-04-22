import Foundation

// MARK: - Fledge Protocol Types

/// Every outbound message (plugin -> fledge) conforms to this.
protocol OutboundMessage: Encodable {
    var type: String { get }
}

/// Inbound `init` message sent by fledge on startup.
struct InitMessage: Decodable {
    let type: String
    let `protocol`: String
    let args: [String]
    let project: Project?
    let plugin: PluginInfo
    let fledge: FledgeInfo

    struct Project: Decodable {
        let name: String
        let root: String
        let language: String?
        let git: GitInfo?

        struct GitInfo: Decodable {
            let branch: String?
            let dirty: Bool?
            let remote: String?
            let remote_url: String?
        }
    }

    struct PluginInfo: Decodable {
        let name: String
        let version: String
        let dir: String
    }

    struct FledgeInfo: Decodable {
        let version: String
    }
}

/// Inbound `response` message from fledge.
struct ResponseMessage: Decodable {
    let type: String
    let id: String
    let value: ResponseValue
}

/// Response values can be strings, bools, arrays, or objects (for exec results).
enum ResponseValue: Decodable {
    case string(String)
    case bool(Bool)
    case strings([String])
    case object([String: AnyCodable])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let b = try? container.decode(Bool.self) {
            self = .bool(b)
        } else if let s = try? container.decode(String.self) {
            self = .string(s)
        } else if let arr = try? container.decode([String].self) {
            self = .strings(arr)
        } else if let obj = try? container.decode([String: AnyCodable].self) {
            self = .object(obj)
        } else {
            self = .null
        }
    }

    var stringValue: String? {
        if case .string(let s) = self { return s }
        return nil
    }

    var boolValue: Bool? {
        if case .bool(let b) = self { return b }
        return nil
    }
}

/// Lightweight type-erased Codable wrapper for heterogeneous JSON values.
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) { self.value = value }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = NSNull()
        } else if let b = try? container.decode(Bool.self) {
            value = b
        } else if let i = try? container.decode(Int.self) {
            value = i
        } else if let d = try? container.decode(Double.self) {
            value = d
        } else if let s = try? container.decode(String.self) {
            value = s
        } else if let arr = try? container.decode([AnyCodable].self) {
            value = arr.map(\.value)
        } else if let obj = try? container.decode([String: AnyCodable].self) {
            value = obj.mapValues(\.value)
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let b as Bool:
            try container.encode(b)
        case let i as Int:
            try container.encode(i)
        case let d as Double:
            try container.encode(d)
        case let s as String:
            try container.encode(s)
        default:
            try container.encodeNil()
        }
    }
}

// MARK: - Outbound Message Types

struct PromptMessage: OutboundMessage {
    let type = "prompt"
    let id: String
    let message: String
    var `default`: String?
    var validate: String?
}

struct ConfirmMessage: OutboundMessage {
    let type = "confirm"
    let id: String
    let message: String
    var `default`: Bool?
}

struct SelectMessage: OutboundMessage {
    let type = "select"
    let id: String
    let message: String
    let options: [String]
    var `default`: Int?
}

struct MultiSelectMessage: OutboundMessage {
    let type = "multi_select"
    let id: String
    let message: String
    let options: [String]
    var defaults: [Int]?
}

struct ProgressMessage: OutboundMessage {
    let type = "progress"
    var message: String?
    var current: Int?
    var total: Int?
    var done: Bool?
}

struct LogMessage: OutboundMessage {
    let type = "log"
    let level: String
    let message: String
}

struct OutputMessage: OutboundMessage {
    let type = "output"
    let text: String
}

struct StoreMessage: OutboundMessage {
    let type = "store"
    let key: String
    let value: String
}

struct LoadMessage: OutboundMessage {
    let type = "load"
    let id: String
    let key: String
}

struct ExecMessage: OutboundMessage {
    let type = "exec"
    let id: String
    let command: String
    var cwd: String?
    var timeout: Int?
}

struct MetadataMessage: OutboundMessage {
    let type = "metadata"
    let id: String
    let keys: [String]
}

// MARK: - Protocol IO

/// Handles JSON-lines communication with fledge over stdin/stdout.
final class FledgeProtocol {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var nextId: Int = 0

    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [] // compact, single-line
        decoder = JSONDecoder()
    }

    /// Generate a unique message ID.
    func makeId() -> String {
        nextId += 1
        return String(nextId)
    }

    /// Read one JSON line from stdin. Returns nil at EOF.
    func receive() -> Data? {
        guard let line = readLine(strippingNewline: true) else { return nil }
        return line.data(using: .utf8)
    }

    /// Read and decode a typed message from stdin.
    func receiveMessage<T: Decodable>(_ type: T.Type) -> T? {
        guard let data = receive() else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    /// Read the next response from stdin.
    func receiveResponse() -> ResponseMessage? {
        return receiveMessage(ResponseMessage.self)
    }

    /// Send an outbound message as a single JSON line to stdout.
    func send(_ message: some OutboundMessage) {
        guard let data = try? encoder.encode(message),
              let line = String(data: data, encoding: .utf8) else {
            debug("Failed to encode message of type: \(message.type)")
            return
        }
        print(line)
        fflush(stdout)
    }

    /// Write debug output to stderr (never captured by fledge).
    func debug(_ text: String) {
        FileHandle.standardError.write(Data((text + "\n").utf8))
    }

    // MARK: - Convenience: fire-and-forget messages

    func log(_ level: String, _ message: String) {
        send(LogMessage(level: level, message: message))
    }

    func output(_ text: String) {
        send(OutputMessage(text: text))
    }

    func progress(message: String, current: Int? = nil, total: Int? = nil) {
        send(ProgressMessage(message: message, current: current, total: total))
    }

    func progressDone() {
        send(ProgressMessage(done: true))
    }

    func store(key: String, value: String) {
        send(StoreMessage(key: key, value: value))
    }

    // MARK: - Convenience: request-response messages

    func prompt(_ message: String, default defaultValue: String? = nil, validate: String? = nil) -> String {
        let id = makeId()
        var msg = PromptMessage(id: id, message: message)
        msg.default = defaultValue
        msg.validate = validate
        send(msg)
        return receiveResponse()?.value.stringValue ?? ""
    }

    func confirm(_ message: String, default defaultValue: Bool? = nil) -> Bool {
        let id = makeId()
        var msg = ConfirmMessage(id: id, message: message)
        msg.default = defaultValue
        send(msg)
        return receiveResponse()?.value.boolValue ?? false
    }

    func select(_ message: String, options: [String], default defaultIndex: Int? = nil) -> String {
        let id = makeId()
        var msg = SelectMessage(id: id, message: message, options: options)
        msg.default = defaultIndex
        send(msg)
        return receiveResponse()?.value.stringValue ?? options[0]
    }

    func multiSelect(_ message: String, options: [String], defaults: [Int]? = nil) -> [String] {
        let id = makeId()
        var msg = MultiSelectMessage(id: id, message: message, options: options)
        msg.defaults = defaults
        send(msg)
        if let resp = receiveResponse(), case .strings(let arr) = resp.value {
            return arr
        }
        return []
    }

    func load(key: String) -> String? {
        let id = makeId()
        send(LoadMessage(id: id, key: key))
        return receiveResponse()?.value.stringValue
    }

    func exec(command: String, cwd: String? = nil, timeout: Int? = nil) -> ResponseMessage? {
        let id = makeId()
        var msg = ExecMessage(id: id, command: command)
        msg.cwd = cwd
        msg.timeout = timeout
        send(msg)
        return receiveResponse()
    }

    func metadata(keys: [String]) -> ResponseMessage? {
        let id = makeId()
        send(MetadataMessage(id: id, keys: keys))
        return receiveResponse()
    }
}

// MARK: - Main Plugin Logic

let fledge = FledgeProtocol()

// Step 0: Read the init message
guard let initMsg = fledge.receiveMessage(InitMessage.self) else {
    fledge.debug("Failed to read init message")
    exit(1)
}
fledge.debug("init received")

// Step 1: Log
fledge.log("info", "fledge-hello-swift plugin started")

// Step 2: Output
fledge.output("""

  Welcome to fledge-hello-swift!
  This plugin demonstrates every fledge-v1 protocol message.
  Written in Swift with Codable for JSON handling.

""")

// Step 3: Prompt -- ask for a name
let name = fledge.prompt("What is your name?", default: "world", validate: "non_empty")
fledge.output("  Hello, \(name)!\n\n")

// Step 4: Confirm
let runFullDemo = fledge.confirm("Run the full demo?", default: true)
if !runFullDemo {
    fledge.output("  Okay, exiting early. Bye!\n")
    exit(0)
}

// Step 5: Select
let color = fledge.select("Pick a color:", options: ["red", "green", "blue"], default: 1)
fledge.log("info", "You picked: \(color)")

// Step 6: Multi-select
let toppings = fledge.multiSelect(
    "Select toppings:",
    options: ["cheese", "pepperoni", "mushrooms", "olives"],
    defaults: [0, 1]
)
fledge.log("info", "Toppings selected: \(toppings.joined(separator: ", "))")

// Step 7: Progress bar
fledge.output("\n")
let total = 5
for i in 1...total {
    fledge.progress(message: "Baking pizza", current: i, total: total)
    Thread.sleep(forTimeInterval: 0.3)
}
fledge.progressDone()

// Step 8: Store and Load
fledge.store(key: "last_user", value: name)
fledge.store(key: "favorite_color", value: color)

let loaded = fledge.load(key: "last_user")
fledge.log("debug", "Store/load roundtrip: stored '\(name)', loaded '\(loaded ?? "nil")'")

// Step 9: Exec -- run a shell command
if let execResp = fledge.exec(command: "date +%Y-%m-%d", timeout: 5),
   case .object(let result) = execResp.value,
   let stdout = result["stdout"]?.value as? String {
    let date = stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    fledge.log("info", "Today is \(date)")
} else {
    fledge.log("warn", "Could not get date from exec")
}

// Step 10: Metadata -- query project info
if fledge.metadata(keys: ["git_tags", "fledge_config"]) != nil {
    fledge.log("debug", "Metadata response received")
}

// Step 11: Spinner progress (indeterminate)
fledge.progress(message: "Finishing up")
Thread.sleep(forTimeInterval: 1.0)
fledge.progressDone()

// Done
fledge.output("""

  All done! Every protocol message exercised successfully.

""")
fledge.log("info", "fledge-hello-swift plugin finished")
