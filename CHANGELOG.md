# 변경 이력

이 프로젝트의 주요 변경 사항을 기록합니다. 형식은 [Keep a Changelog](https://keepachangelog.com/ko/1.1.0/)를 따릅니다.

## 2026-11-18
### 문서
- README를 구조도와 흐름도 중심으로 다시 썼습니다.
- 요구사항 명세(SRS)와 설계 명세(SDS)를 추가했습니다.

## 2026-07-16
### 문서
- 공식 craftinginterpreters 테스트 스위트 검증 결과(246/246, 568 expectations)와 재현 절차를 README에 기록했습니다. 공식 Dart 러너는 Dart 2.19.6이 필요합니다.

## 2026-07-13
### 추가
- Lox 바이트코드 컴파일러와 스택 VM(C99, 외부 의존성 없음). 렉서, Pratt 파서, 값과 문자열 인터닝, 해시 테이블, 전역/지역 변수, 제어 흐름, 함수, 클로저, mark-and-sweep GC, 클래스와 상속(`super`)을 지원합니다.
- REPL과 파일 실행 모드, 네이티브 함수 `clock()`.
- 종료 코드: 사용법 오류 64, 컴파일 에러 65, 런타임 에러 70.
- 디버그 컴파일 플래그 `DEBUG_STRESS_GC`, `DEBUG_LOG_GC`.
