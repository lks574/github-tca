import Foundation
import ComposableArchitecture
import SwiftUI

// MARK: - GitHub Client

/// GitHub API 클라이언트 (TCA Dependency)
@DependencyClient
public struct GitHubClient: Sendable {
  
  // MARK: - Repository Operations
  
  /// 레포지토리 검색
  public var searchRepositories: @Sendable (_ parameters: GitHubSearchParameters) async throws -> GitHubSearchResponse
  
  /// 특정 레포지토리 조회
  public var getRepository: @Sendable (_ owner: String, _ repo: String) async throws -> GitHubRepository
  
  // MARK: - User Operations
  
  /// 사용자 정보 조회
  public var getUser: @Sendable (_ username: String) async throws -> GitHubUser
  
  /// 현재 인증된 사용자 정보 조회
  public var getCurrentUser: @Sendable () async throws -> GitHubUser
  
  /// 사용자의 리포지토리 목록 조회
  public var getUserRepositories: @Sendable (_ username: String, _ page: Int, _ perPage: Int) async throws -> [GitHubRepository]
  
  /// 사용자가 별표 표시한 리포지토리 목록 조회
  public var getUserStarredRepositories: @Sendable (_ username: String, _ page: Int, _ perPage: Int) async throws -> [GitHubRepository]
  
  // MARK: - Convenience Methods
  
  /// 간단한 레포지토리 검색 (기본 파라미터 사용)
  public var searchRepositoriesSimple: @Sendable (_ query: String, _ page: Int, _ perPage: Int) async throws -> GitHubSearchResponse
}

// MARK: - Dependency Key

extension GitHubClient: DependencyKey {
  
  /// Live 구현체 (실제 API 호출)
  public static let liveValue: GitHubClient = {
    let service = GitHubService(authClient: GitHubAuthClient.liveValue)
    
    return GitHubClient(
      searchRepositories: { parameters in
        try await service.searchRepositories(parameters: parameters)
      },
      getRepository: { owner, repo in
        try await service.getRepository(owner: owner, repo: repo)
      },
      getUser: { username in
        try await service.getUser(username: username)
      },
      getCurrentUser: {
        try await service.getCurrentUser()
      },
      getUserRepositories: { username, page, perPage in
        try await service.getUserRepositories(username: username, page: page, perPage: perPage)
      },
      getUserStarredRepositories: { username, page, perPage in
        try await service.getUserStarredRepositories(username: username, page: page, perPage: perPage)
      },
      searchRepositoriesSimple: { query, page, perPage in
        let parameters = GitHubSearchParameters(
          query: query,
          sort: .stars,
          order: .desc,
          page: page,
          perPage: perPage
        )
        return try await service.searchRepositories(parameters: parameters)
      }
    )
  }()
  
  /// Test 구현체 (실제 API 사용하되 testValue용)
  public static let testValue: GitHubClient = {
    let service = GitHubService(authClient: GitHubAuthClient.testValue)
    
    return GitHubClient(
      searchRepositories: { parameters in
        try await service.searchRepositories(parameters: parameters)
      },
      getRepository: { owner, repo in
        try await service.getRepository(owner: owner, repo: repo)
      },
      getUser: { username in
        try await service.getUser(username: username)
      },
      getCurrentUser: {
        try await service.getCurrentUser()
      },
      getUserRepositories: { username, page, perPage in
        try await service.getUserRepositories(username: username, page: page, perPage: perPage)
      },
      getUserStarredRepositories: { username, page, perPage in
        try await service.getUserStarredRepositories(username: username, page: page, perPage: perPage)
      },
      searchRepositoriesSimple: { query, page, perPage in
        let parameters = GitHubSearchParameters(
          query: query,
          sort: .stars,
          order: .desc,
          page: page,
          perPage: perPage
        )
        return try await service.searchRepositories(parameters: parameters)
      }
    )
  }()
  
  /// Preview 구현체 (SwiftUI Preview용)
  public static let previewValue: GitHubClient = testValue
}

// MARK: - Dependency Values Extension

extension DependencyValues {
  
  /// GitHub 클라이언트 의존성
  public var gitHubClient: GitHubClient {
    get { self[GitHubClient.self] }
    set { self[GitHubClient.self] = newValue }
  }
}

// MARK: - Model Extensions for App Integration

extension GitHubRepository {
  
  /// ExploreModel.PopularRepository로 변환
  func toPopularRepository() -> ExploreModel.PopularRepository {
    let dateFormatter = ISO8601DateFormatter()
    let relativeFormatter = RelativeDateTimeFormatter()
    relativeFormatter.locale = Locale(identifier: "ko_KR")
    relativeFormatter.unitsStyle = .abbreviated
    
    let lastUpdateString: String
    if let date = dateFormatter.date(from: updatedAt) {
      lastUpdateString = relativeFormatter.localizedString(for: date, relativeTo: Date())
    } else {
      lastUpdateString = "알 수 없음"
    }
    
    return ExploreModel.PopularRepository(
      name: name,
      owner: owner.login,
      description: description ?? "설명이 없습니다.",
      language: language ?? "Unknown",
      stars: stargazersCount,
      lastUpdate: lastUpdateString,
      isReleased: topics?.isEmpty == false // 토픽이 있으면 릴리스된 것으로 간주
    )
  }
  
  /// ProfileModel.RepositoryItem으로 변환
  func toProfileRepositoryItem() -> ProfileModel.RepositoryItem {
    let dateFormatter = ISO8601DateFormatter()
    let relativeFormatter = RelativeDateTimeFormatter()
    relativeFormatter.locale = Locale(identifier: "ko_KR")
    relativeFormatter.unitsStyle = .abbreviated
    
    let lastUpdateString: String
    if let date = dateFormatter.date(from: updatedAt) {
      lastUpdateString = relativeFormatter.localizedString(for: date, relativeTo: Date())
    } else {
      lastUpdateString = "알 수 없음"
    }
    
    // 언어별 색상 매핑
    let languageColor: Color? = {
      switch language?.lowercased() {
      case "swift": return .githubOrange
      case "dart": return .githubInfo
      case "javascript": return .githubWarning
      case "typescript": return .githubBlue
      case "python": return .githubGreen
      case "java": return .githubRed
      case "kotlin": return .githubPurple
      case "go": return .githubSecondaryText
      default: return .githubTertiaryText
      }
    }()
    
    return ProfileModel.RepositoryItem(
      name: name,
      fullName: fullName,
      description: description,
      language: language,
      languageColor: languageColor,
      starCount: stargazersCount,
      forkCount: forksCount,
      isPrivate: isPrivate,
      updatedAt: lastUpdateString
    )
  }
}

extension GitHubUser {
  
  /// ProfileModel.UserProfile로 변환
  func toUserProfile() -> ProfileModel.UserProfile {
    let dateFormatter = ISO8601DateFormatter()
    let displayFormatter = DateFormatter()
    displayFormatter.locale = Locale(identifier: "ko_KR")
    displayFormatter.dateFormat = "yyyy년부터 GitHub 사용"
    
    let joinDateString: String
    if let createdAt, let date = dateFormatter.date(from: createdAt) {
      joinDateString = displayFormatter.string(from: date)
    } else {
      joinDateString = "알 수 없음"
    }
    
    return ProfileModel.UserProfile(
      username: login,
      displayName: name ?? login,
      bio: bio,
      avatar: avatarUrl,
      company: company,
      location: location,
      followerCount: followers ?? 0,
      followingCount: following ?? 0,
      publicRepos: publicRepos ?? 0,
      privateRepos: 0, // GitHub API에서 제공하지 않음
      starredRepos: 0, // 별도 API 호출 필요
      organizations: 0, // 별도 API 호출 필요
      isVerified: siteAdmin,
      joinDate: joinDateString
    )
  }
}

// MARK: - Usage Examples

/*
 
 ## GitHub Client 사용 예제
 
 ### 1. 기본 검색
 ```swift
 @Dependency(\.gitHubClient) var gitHubClient
 
 let parameters = GitHubSearchParameters(
   query: "swift",
   sort: .stars,
   order: .desc,
   page: 1,
   perPage: 10
 )
 
 let result = try await gitHubClient.searchRepositories(parameters)
 let repositories = result.items.map { $0.toPopularRepository() }
 ```
 
 ### 2. 간단한 검색
 ```swift
 @Dependency(\.gitHubClient) var gitHubClient
 
 let result = try await gitHubClient.searchRepositoriesSimple("TCA", 1, 10)
 ```
 
 ### 3. 특정 레포지토리 조회
 ```swift
 @Dependency(\.gitHubClient) var gitHubClient
 
 let repo = try await gitHubClient.getRepository("pointfreeco", "swift-composable-architecture")
 ```
 
 ### 4. 사용자 정보 조회
 ```swift
 @Dependency(\.gitHubClient) var gitHubClient
 
 let user = try await gitHubClient.getUser("pointfreeco")
 ```
 
 ### 5. 에러 처리
 ```swift
 do {
   let result = try await gitHubClient.searchRepositoriesSimple(query, page, perPage)
   // 성공 처리
 } catch let error as GitHubError {
   // GitHub 에러 처리
   print(error.localizedDescription)
   
   if error.shouldRetry {
     // 재시도 로직
   }
 } catch {
   // 기타 에러 처리
   print("알 수 없는 오류: \(error)")
 }
 ```
 
 ### 6. TCA Reducer에서 사용
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
     case repositoriesResponse(Result<GitHubSearchResponse, Error>)
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
         if let gitHubError = error as? GitHubError {
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
 
 */
