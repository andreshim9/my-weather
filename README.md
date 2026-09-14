# ☀️ my-weather (날씨 & 일출·일몰 스마트 시계)

실시간 날씨 예보, 정밀 일출·일몰 시간, 24절기 달력, 탁상시계 가로 모드 및 안드로이드 홈 위젯을 제공하는 **플러터(Flutter) 기반 스마트 시계 & 날씨 앱**입니다.

---

## 🌟 주요 기능

1. **상단 대형 디지털 시계 & 상시 켜짐 (Wakelock)**
   - 초단위까지 실시간 표시되는 고해상도 디지털 시계
   - 화면 꺼짐 방지(Wakelock) 및 OLED 화면 잔상(번인) 방지 미세 픽셀 시프트 탑재
2. **가로 모드(Landscape) 탁상시계 특화 뷰**
   - 스마트폰을 가로로 눕히면 좌측(45%)에 웅장한 대형 시계와 실시간 요약 날씨 표출
   - 우측(55%)에서 하루/일주일/한달 상세 날씨 및 일출몰 정보 조회
3. **하루 / 일주일 / 한달(24절기) 다중 뷰 모드**
   - **하루 보기**: 24시간 기온 그래프, 태양 고도 궤적도(Sun Arc), 박명/남중 시각, 습도, 자외선, 풍속 상세
   - **일주일 보기**: 7일간의 날씨 예보 및 일출/일몰 비교표
   - **한달 보기**: 24절기 및 일별 낮/밤 길이 변화 천문 캘린더
4. **시인성 및 접근성 강화**
   - 화이트 모드 / 다크 모드 원클릭 테마 전환 (WCAG AAA 고대비)
   - 4단계 글자 크기(85%, 100%, 115%, 130%) 조절 및 큰 글씨에서도 UI 깨짐/오버플로우 방지
5. **원하는 위치 검색 및 즐겨찾기 저장 관리**
   - 전세계 도시 및 동/읍/면 검색 후 '내 저장된 위치'에 추가/삭제
   - 언제든 원터치로 현재 GPS 위치 복귀 지원
6. **안드로이드 홈 화면 바탕화면 위젯 3종**
   - **2x1 오늘 날씨 요약 위젯**: 현재 기온, 날씨 상태, 일출/일몰 시간
   - **4x2 태양 상세 종합 위젯**: 일출, 남중, 일몰 시각 및 낮의 총 길이
   - **4x2 3일간 예보 위젯**: 오늘, 내일, 모레의 기온/날씨/일출몰 3개 컬럼 예보
7. **GitHub 연동 인앱(In-App) 자동 업데이트**
   - 앱 실행 시 GitHub 최신 버전을 확인하여 원클릭으로 최신 APK 다운로드 및 덮어쓰기 설치

---

## 📁 프로젝트 구조

`
my-apps/
├── android/
│   ├── app/src/main/
│   │   ├── AndroidManifest.xml          # 권한(위치/설치/위젯) 및 AppWidgetProvider 등록
│   │   ├── kotlin/.../widget/           # Kotlin 위젯 프로바이더 (3종)
│   │   └── res/
│   │       ├── layout/                  # 위젯 레이아웃 XML (2x1, 4x2)
│   │       └── xml/                     # AppWidgetProviderInfo XML
├── lib/
│   ├── constants/
│   │   ├── api_constants.dart           # API 엔드포인트 및 위젯 상수
│   │   └── app_theme.dart               # 고대비 라이트/다크 테마
│   ├── models/                          # Weather, SunTime, MonthSunDay, LocationItem
│   ├── services/
│   │   ├── sun_calc_service.dart        # NOAA 천문 역학 정밀 일출/일몰 계산 엔진
│   │   ├── weather_service.dart         # Open-Meteo 글로벌 기상 데이터 조회
│   │   ├── location_service.dart        # 지오코딩 위치 검색 서비스
│   │   ├── update_service.dart          # GitHub Releases 자동 업데이트 검사 및 설치
│   │   └── widget_service.dart          # 안드로이드 홈 위젯 데이터 동기화
│   ├── providers/
│   │   └── app_state_provider.dart      # Provider 전역 상태 관리
│   ├── widgets/                         # DigitalClockHeader, SunArcWidget, WeatherDetailCard 등
│   ├── screens/                         # MainScreen, WidgetSettingsScreen
│   └── main.dart                        # 앱 엔트리포인트
└── pubspec.yaml
`

---

## 🚀 버전업(새 버전 배포) 작업 순서 가이드

새로운 기능을 추가하거나 수정 후 버전을 올려 배포할 때는 아래 순서대로 진행합니다.

### 1단계: pubspec.yaml의 버전 수정
pubspec.yaml 상단의 ersion 값을 올려줍니다:
`yaml
# versionName(버전명) + versionCode(정수형 빌드번호)
version: 1.0.1+2
`

### 2단계: 릴리즈 APK 빌드
터미널에서 릴리즈 모드로 APK를 빌드합니다:
`ash
flutter build apk --release
`
- 빌드 완료 파일: uild/app/outputs/flutter-apk/app-release.apk
- (선택) 식별하기 편하게 이름 복사:
  `powershell
  Copy-Item build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/my-weather-v1.0.1.apk
  `

### 3단계: Git 커밋 및 푸시
`ash
git add .
git commit -m feat: v1.0.1 업데이트 내용 요약
git push origin master
`

### 4단계: GitHub 릴리즈 생성 (APK 첨부)
GitHub CLI(gh)를 사용하여 새 버전을 등록하고 APK 파일을 업로드합니다:
`ash
gh release create v1.0.1 build/app/outputs/flutter-apk/my-weather-v1.0.1.apk --title my-weather v1.0.1 --notes - 신규 기능 추가
- 버그 수정 및 안정성 향상
`

> 💡 **자동 업데이트 동작 확인**:  
> GitHub에 새 릴리즈가 등록되면, 기존 앱을 실행하고 있는 모든 사용자의 스마트폰에 **새로운 버전 발견!** 팝업이 자동으로 표시되며 **[지금 업데이트]** 버튼 클릭 시 즉시 새 버전으로 업그레이드됩니다.

---

## 🛠️ 개발 환경 실행 방법

`ash
# 의존성 설치
flutter pub get

# 웹 브라우저 실행
flutter run -d chrome

# 안드로이드 기기/에뮬레이터 실행
flutter run
`
