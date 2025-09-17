# GitHub API Core Module

GitHub API와 상호작용하기 위한 공용 모듈입니다. TCA(The Composable Architecture) 의존성 시스템을 활용하여 설계되었습니다.

## 📁 구조

```
Core/
├── GitHub.swift              # 공용 익스포트 파일
├── README.md                 # 이 파일
├── Client/
│   └── GitHubClient.swift    # TCA 의존성 클라이언트
├── Services/
│   └── GitHubService.swift   # 실제 API 서비스 구현
├── Models/
│   └── GitHubModels.swift    # GitHub API 응답 모델들
└── Errors/
    └── GitHubError.swift     # 에러 타입 정의
```

## 🚀 사용법

### 1. 기본 import

```swift
import ComposableArchitecture
// GitHub 모듈의 모든 기능이 자동으로 import됩니다
```

### 2. TCA Reducer에서 사용

```swift
@Reducer
struct ExploreReducer {
  struct State: Equatable {
    var repositories: [ExploreModel.PopularRepository] = []
    var isLoading = false
    var error: String?
  }
  
  enum Action {
    case searchRepositories(String)
    case repositoriesResponse(Result<GitHub.SearchResponse, Error>)
  }
  
  @Dependency(\.gitHubClient) var gitHubClient
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .searchRepositories(query):
        state.isLoading = true
        state.error = nil
        
        return .run { send in
          await send(.repositoriesResponse(
            Result {
              try await gitHubClient.searchRepositoriesSimple(query, 1, 20)
            }
          ))
        }
        
      case let .repositoriesResponse(.success(response)):
        state.isLoading = false
        state.repositories = response.items.map { $0.toPopularRepository() }
        return .none
        
      case let .repositoriesResponse(.failure(error)):
        state.isLoading = false
        if let gitHubError = error as? GitHub.Error {
          state.error = gitHubError.localizedDescription
        } else {
          state.error = "알 수 없는 오류가 발생했습니다."
        }
        return .none
      }
    }
  }
}
```

### 3. 다양한 검색 방법

```swift
@Dependency(\.gitHubClient) var gitHubClient

// 1. 간단한 검색
let result = try await gitHubClient.searchRepositoriesSimple("swift", 1, 10)

// 2. 파라미터를 통한 상세 검색
let parameters = GitHub.SearchParameters(
  query: "language:swift",
  sort: .stars,
  order: .desc,
  page: 1,
  perPage: 20
)
let result = try await gitHubClient.searchRepositories(parameters)

// 3. 편의 메서드 사용
let swiftRepos = try await gitHubClient.searchRepositories(.swiftRepositories())
let iOSRepos = try await gitHubClient.searchRepositories(.iOSRepositories())
let tcaRepos = try await gitHubClient.searchRepositories(.tcaRepositories())
```

### 4. 에러 처리

```swift
do {
  let result = try await gitHubClient.searchRepositoriesSimple(query, page, perPage)
  // 성공 처리
} catch let error as GitHub.Error {
  // GitHub 특화 에러 처리
  print("에러 코드: \(error.errorCode)")
  print("메시지: \(error.localizedDescription)")
  
  if error.shouldRetry {
    // 재시도 가능한 에러 (네트워크, 타임아웃 등)
    print("재시도 가능한 에러입니다.")
  }
  
  if error.isRecoverable {
    // 복구 가능한 에러
    print("복구 가능한 에러입니다.")
  }
} catch {
  // 기타 에러 처리
  print("알 수 없는 오류: \(error)")
}
```

### 5. 특정 레포지토리/사용자 조회

```swift
// 레포지토리 조회
let repo = try await gitHubClient.getRepository("pointfreeco", "swift-composable-architecture")

// 사용자 조회
let user = try await gitHubClient.getUser("pointfreeco")
```

## 🧪 테스트

### Unit Test에서 사용

```swift
@testable import YourApp
import ComposableArchitecture
import XCTest

final class ExploreReducerTests: XCTestCase {
  
  func testSearchRepositories() async {
    let store = TestStore(initialState: ExploreReducer.State()) {
      ExploreReducer()
    } withDependencies: {
      $0.gitHubClient = .testValue  // Mock 데이터 사용
    }
    
    await store.send(.searchRepositories("swift")) {
      $0.isLoading = true
      $0.error = nil
    }
    
    await store.receive(.repositoriesResponse(.success(/* mock response */))) {
      $0.isLoading = false
      $0.repositories = [/* expected repositories */]
    }
  }
}
```

### SwiftUI Preview에서 사용

```swift
struct ExplorePagePreviews: PreviewProvider {
  static var previews: some View {
    ExplorePage(
      store: Store(initialState: ExploreReducer.State()) {
        ExploreReducer()
      } withDependencies: {
        $0.gitHubClient = .previewValue  // Preview용 데이터 사용
      }
    )
  }
}
```

## 🔧 고급 설정

### 커스텀 URLSession 사용

```swift
// AppDelegate 또는 App.swift에서
let customSession = URLSession(configuration: .default)
let customService = GitHub.Service(session: customSession)

// 의존성 등록
DependencyValues.live.gitHubClient = GitHubClient(
  searchRepositories: { parameters in
    try await customService.searchRepositories(parameters: parameters)
  },
  // ... 다른 메서드들
)
```

## 📊 지원하는 기능

- ✅ 레포지토리 검색 (정렬, 페이징 지원)
- ✅ 특정 레포지토리 조회
- ✅ 사용자 정보 조회
- ✅ 상세한 에러 처리
- ✅ 자동 재시도 로직
- ✅ 한국어 에러 메시지
- ✅ TCA 의존성 시스템 통합
- ✅ 테스트용 Mock 데이터
- ✅ SwiftUI Preview 지원

## 🛡️ 에러 타입

| 에러 타입 | 설명 | 재시도 가능 | 복구 가능 |
|-----------|------|-------------|-----------|
| `invalidURL` | 잘못된 URL | ❌ | ❌ |
| `emptyQuery` | 빈 검색어 | ❌ | ❌ |
| `networkError` | 네트워크 오류 | ✅ | ✅ |
| `timeout` | 타임아웃 | ✅ | ✅ |
| `rateLimitExceeded` | API 한도 초과 | ✅ | ✅ |
| `unauthorized` | 인증 필요 | ❌ | ❌ |
| `forbidden` | 접근 권한 없음 | ❌ | ❌ |
| `notFound` | 리소스 없음 | ❌ | ❌ |
| `decodingError` | 파싱 오류 | ❌ | ❌ |

## 📝 주의사항

1. **Rate Limiting**: GitHub API는 시간당 60번의 요청 제한이 있습니다. (인증 시 5000번)
2. **네트워크 상태**: 네트워크 연결 상태를 확인하고 적절한 에러 처리를 구현하세요.
3. **Caching**: 필요에 따라 응답 결과를 캐싱하여 API 호출을 줄이세요.
4. **User-Agent**: 적절한 User-Agent 헤더를 설정하여 GitHub API 정책을 준수하세요.

## 🔗 관련 링크

- [GitHub REST API 문서](https://docs.github.com/en/rest)
- [TCA 공식 문서](https://pointfreeco.github.io/swift-composable-architecture/)
- [Swift Concurrency](https://developer.apple.com/documentation/swift/concurrency)
