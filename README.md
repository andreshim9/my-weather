# 🐾 펫웨더 & 산책일출몰 (Pet Weather & Walk Sunset/Sunrise Widget App)

위치 기반 실시간 날씨, 정밀 일출·일몰 시간, 반려견 산책 골든아워 분석과 함께 공공데이터포털(전국 동물병원 및 한국관광공사 반려동물 동반 여행지)을 연동한 **안드로이드 바탕화면 다중 위젯 플러터(Flutter) 앱**입니다.

---

## 🌟 주요 기능

1. **실시간 날씨 & 천문 일출·일몰 정보**
   - 현재 GPS 위치 기반 실시간 기온, 체감온도, 습도, 풍속, 강수확률, 자외선 지수 표출
   - 천문 역학 알고리즘(줄리안 일 기반)을 통한 일출, 일몰, 남중, 시민 박명 시각 정밀 계산
   - 시각적 태양 궤적 호(Arc) 및 남은 시간 카운트다운

2. **반려견 산책 골든아워(Golden Hour) 분석**
   - 아침/저녁 일출·일몰 전후 지열 및 자외선 상태를 고려한 최적의 산책 시간대 산출
   - 기온, 강수, 풍속을 종합한 실시간 산책 지수(최적 / 양호 / 주의 / 위험) 제공

3. **공공데이터포털 API 연동**
   - **전국 동물병원 정보 (`/1741000/animal_hospitals`)**: 내 위치 기준 거리순 정렬, 영업 상태 확인 및 원터치 비상 전화 연결
   - **한국관광공사 반려동물 동반 여행 정보 (`/B551011/KorPetTourService2`)**: 반려견 동반 가능 공원, 산책로, 카페, 숙소 및 견종 제한 안내 정보

4. **안드로이드 홈 화면 바탕화면 위젯 3종 (`home_widget`)**
   - **2x1 컴팩트 위젯**: 위치, 날씨, 기온, 일출/일몰 요약
   - **4x2 종합 산책 위젯**: 실시간 산책 지수, 아침/저녁 골든아워, 일출몰 상세
   - **4x2 펫 안심 위젯**: 가장 가까운 비상 동물병원 바로 전화 걸기 및 추천 동반 명소

---

## 📁 프로젝트 구조

```
my-apps/
├── android/
│   ├── app/src/main/
│   │   ├── AndroidManifest.xml          # 권한(위치/전화/위젯) 및 AppWidgetProvider 등록
│   │   ├── kotlin/.../widget/           # Kotlin 위젯 프로바이더 (3종)
│   │   └── res/
│   │       ├── layout/                  # 위젯 레이아웃 XML (2x1, 4x2)
│   │       └── xml/                     # AppWidgetProviderInfo XML
├── lib/
│   ├── constants/
│   │   ├── api_constants.dart           # 공공데이터포털 API 키 및 엔드포인트
│   │   └── app_theme.dart               # 다크 테마 & 컬러 팔레트
│   ├── models/                          # Weather, SunTime, AnimalHospital, PetTour
│   ├── services/
│   │   ├── sun_calc_service.dart        # 일출/일몰/골든아워 천문 계산 엔진
│   │   ├── weather_service.dart         # 실시간 기상 데이터 및 산책 지수 평가
│   │   ├── public_data_service.dart     # 공공데이터포털 API 클라이언트
│   │   └── widget_service.dart          # 안드로이드 홈 위젯 동기화 서비스
│   ├── providers/
│   │   └── app_state_provider.dart      # Provider 상태 관리
│   ├── widgets/                         # SunArcWidget, GoldenHourCard, WeatherDetailCard
│   ├── screens/                         # 날씨/일출몰, 동물병원, 동반명소, 위젯설정 화면
│   └── main.dart                        # 앱 엔트리포인트
└── pubspec.yaml
```

---

## 🚀 실행 및 빌드 방법

1. **의존성 패키지 설치**
   ```bash
   flutter pub get
   ```

2. **안드로이드 기기 또는 에뮬레이터에서 실행**
   ```bash
   flutter run
   ```

3. **안드로이드 APK 빌드**
   ```bash
   flutter build apk --release
   ```
