import Foundation
import SwiftUI

// MARK: - 네트워크 로그 모델
public struct NetworkLog: Identifiable, Equatable {
  public let id = UUID()
  let method: String
  let url: String
  let statusCode: Int?
  let responseTime: TimeInterval?
  let requestHeaders: [String: String]
  let responseHeaders: [String: String]
  let requestBody: String?
  let responseBody: String?
  let error: String?
  let timestamp: Date
  
  var statusDisplay: String {
    if let statusCode = statusCode {
      return "\(statusCode)"
    } else if error != nil {
      return "ERROR"
    } else {
      return "PENDING"
    }
  }
  
  var statusColor: Color {
    guard let statusCode = statusCode else {
      return error != nil ? .red : .orange
    }
    
    switch statusCode {
    case 200..<300: return .green
    case 300..<400: return .blue
    case 400..<500: return .orange
    case 500...: return .red
    default: return .gray
    }
  }
  
  var formattedResponseBody: String? {
    guard let responseBody = responseBody else { return nil }
    return prettyPrintJSON(from: responseBody) ?? responseBody
  }
}

// MARK: - 네트워크 로거
@MainActor
public class NetworkLogger: ObservableObject {
  public static let shared = NetworkLogger()
  
  @Published public var logs: [NetworkLog] = []
  private let maxLogs = 100
  
  private init() {}
  
  public func logRequest(
    method: String,
    url: URL,
    headers: [String: String] = [:],
    body: Data? = nil
  ) -> NetworkLog {
    let log = NetworkLog(
      method: method,
      url: url.absoluteString,
      statusCode: nil,
      responseTime: nil,
      requestHeaders: headers,
      responseHeaders: [:],
      requestBody: body.flatMap { String(data: $0, encoding: .utf8) },
      responseBody: nil,
      error: nil,
      timestamp: Date()
    )
    
    addLog(log)
    return log
  }
  
  public func updateLogWithResponse(
    logId: UUID,
    statusCode: Int,
    responseTime: TimeInterval,
    responseHeaders: [String: String] = [:],
    responseBody: Data? = nil
  ) {
    guard let index = logs.firstIndex(where: { $0.id == logId }) else { return }
    
    let updatedLog = NetworkLog(
      method: logs[index].method,
      url: logs[index].url,
      statusCode: statusCode,
      responseTime: responseTime,
      requestHeaders: logs[index].requestHeaders,
      responseHeaders: responseHeaders,
      requestBody: logs[index].requestBody,
      responseBody: responseBody.flatMap { String(data: $0, encoding: .utf8) },
      error: nil,
      timestamp: logs[index].timestamp
    )
    
    logs[index] = updatedLog
  }
  
  public func updateLogWithError(logId: UUID, error: Error) {
    guard let index = logs.firstIndex(where: { $0.id == logId }) else { return }
    
    let updatedLog = NetworkLog(
      method: logs[index].method,
      url: logs[index].url,
      statusCode: nil,
      responseTime: nil,
      requestHeaders: logs[index].requestHeaders,
      responseHeaders: [:],
      requestBody: logs[index].requestBody,
      responseBody: nil,
      error: error.localizedDescription,
      timestamp: logs[index].timestamp
    )
    
    logs[index] = updatedLog
  }
  
  private func addLog(_ log: NetworkLog) {
    logs.insert(log, at: 0)
    
    // 최대 로그 수 제한
    if logs.count > maxLogs {
      logs = Array(logs.prefix(maxLogs))
    }
  }
  
  public func clearLogs() {
    logs.removeAll()
  }
}

// MARK: - 네트워크 로거 뷰
public struct NetworkLoggerView: View {
  @StateObject private var logger = NetworkLogger.shared
  @State private var selectedLog: NetworkLog?
  
  public init() {}
  
  public var body: some View {
    NavigationView {
      List(logger.logs) { log in
        NetworkLogRow(log: log)
          .onTapGesture {
            selectedLog = log
          }
      }
      .navigationTitle("네트워크 로그")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("클리어") {
            logger.clearLogs()
          }
        }
      }
      .sheet(item: $selectedLog) { log in
        NetworkLogDetailView(log: log)
      }
    }
  }
}

// MARK: - 네트워크 로그 행
private struct NetworkLogRow: View {
  let log: NetworkLog
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(log.method)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.blue)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Color.blue.opacity(0.1))
          .cornerRadius(4)
        
        Text(log.statusDisplay)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.white)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(log.statusColor)
          .cornerRadius(4)
        
        if let responseTime = log.responseTime {
          Text("\(Int(responseTime * 1000))ms")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        Spacer()
        
        Text(DateFormatter.timeFormatter.string(from: log.timestamp))
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Text(log.url)
        .font(.system(size: 12, design: .monospaced))
        .foregroundColor(.primary)
        .lineLimit(2)
    }
    .padding(.vertical, 2)
  }
}

// MARK: - 네트워크 로그 상세 뷰
private struct NetworkLogDetailView: View {
  let log: NetworkLog
  @State private var showPrettyResponse = true
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          // 기본 정보
          VStack(alignment: .leading, spacing: 8) {
            Text("요청 정보")
              .font(.headline)
            
            InfoRow(title: "Method", value: log.method)
            InfoRow(title: "URL", value: log.url)
            InfoRow(title: "Status", value: log.statusDisplay)
            
            if let responseTime = log.responseTime {
              InfoRow(title: "Response Time", value: "\(Int(responseTime * 1000))ms")
            }
            
            InfoRow(title: "Timestamp", value: DateFormatter.detailFormatter.string(from: log.timestamp))
          }
          
          // 요청 헤더
          if !log.requestHeaders.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
              Text("요청 헤더")
                .font(.headline)
              
              ForEach(log.requestHeaders.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                InfoRow(title: key, value: value)
              }
            }
          }
          
          // 요청 바디
          if let requestBody = log.requestBody {
            VStack(alignment: .leading, spacing: 8) {
              Text("요청 바디")
                .font(.headline)
              
              Text(requestBody)
                .font(.system(size: 12, design: .monospaced))
                .textSelection(.enabled)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
          }
          
          // 응답 헤더
          if !log.responseHeaders.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
              Text("응답 헤더")
                .font(.headline)
              
              ForEach(log.responseHeaders.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                InfoRow(title: key, value: value)
              }
            }
          }
          
          // 응답 바디
          if let responseBody = log.responseBody {
            VStack(alignment: .leading, spacing: 8) {
              Text("응답 바디")
                .font(.headline)

              Picker("보기", selection: $showPrettyResponse) {
                Text("포맷").tag(true)
                Text("원본").tag(false)
              }
              .pickerStyle(.segmented)

              Text(showPrettyResponse ? (log.formattedResponseBody ?? responseBody) : responseBody)
                .font(.system(size: 12, design: .monospaced))
                .textSelection(.enabled)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
          }
          
          // 에러
          if let error = log.error {
            VStack(alignment: .leading, spacing: 8) {
              Text("에러")
                .font(.headline)
                .foregroundColor(.red)
              
              Text(error)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.red)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
          }
        }
        .padding()
      }
      .navigationTitle("로그 상세")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("완료") {
            // 모달 닫기는 부모에서 처리
          }
        }
      }
    }
  }
}

// MARK: - 정보 행
private struct InfoRow: View {
  let title: String
  let value: String
  
  var body: some View {
    HStack(alignment: .top) {
      Text("\(title):")
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.secondary)
        .frame(width: 80, alignment: .leading)
      
      Text(value)
        .font(.caption)
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

// MARK: - Date Formatter Extension
private extension DateFormatter {
  static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    return formatter
  }()
  
  static let detailFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
  }()
}

// MARK: - JSON Pretty Print Helper
fileprivate func prettyPrintJSON(from string: String) -> String? {
  guard let data = string.data(using: .utf8) else { return nil }
  do {
    let object = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
    let prettyData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
    return String(data: prettyData, encoding: .utf8)
  } catch {
    return nil
  }
}
