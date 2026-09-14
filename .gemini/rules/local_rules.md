# Project Local Rules for my-weather

## 1. Implementation Plan & Explicit Approval First (작업 계획 수립 및 명시적 승인 대기)
- 새로운 작업이나 기능 수정 지시를 받으면, **실제 코드 수정이나 빌드 작업을 바로 진행하지 않고 단계별 작업 계획(Implementation Plan)을 먼저 수립**합니다.
- 계획 수립 후 **사용자의 명시적인 승인("승인", "진행해", "확인" 등)이 있을 때까지 대기**하며, 승인 전에는 코드를 임의로 변경하지 않습니다.

## 2. Local Testing & Verification Policy (로컬 검증 원칙)
- 승인을 받아 코드를 수정한 후에는 반드시 **로컬 테스트(`flutter test`, `flutter analyze` 및 로컬 웹 실행)** 환경에서만 검증을 수행합니다.
- 수정 사항에 대한 결과와 검증 내용을 사용자에게 먼저 보고하고 피드백을 받습니다.

## 3. Release & Build Constraints (배포 및 APK 빌드 제약)
- 사용자의 **명시적인 배포 요청 또는 승인**이 있기 전까지는 `flutter build apk` 실행 및 GitHub Release 업로드를 절대 자동으로 진행하지 않습니다.
- 릴리즈 APK 빌드 및 원격 배포는 사용자가 "배포해줘", "APK 빌드해줘", "릴리즈 올려줘" 등 명시적으로 지시할 때만 실행합니다.
