# Plan 04: 변수와 제어 흐름 (Ch 21~23)

## 목표

문 단위 파싱(print, 선언), 전역/지역 변수, if/else, and/or, while, for를 구현하고 공식 테스트 러너를 연동한다. SPEC의 R7, R8 구현.

## 컨텍스트

- plan 03 완료 상태: 표현식 + 문자열 + 해시 테이블. 아직 문(statement)이 없다.
- 교재: Ch 21 (Global Variables), Ch 22 (Local Variables), Ch 23 (Jumping Back and Forth).
- 이 plan부터 print 문이 생기므로 공식 Lox 테스트 스위트를 처음으로 돌릴 수 있다. 러너 연동이 이 plan의 부속 작업.

## 작업

1. 문 파싱 구조 - declaration/statement 구분, print 문, 표현식 문(OP_POP)
2. 패닉 모드 동기화 (synchronize) - 에러 후 문 경계까지 스킵, 연쇄 에러 방지
3. 전역 변수 - var 선언, OP_DEFINE_GLOBAL/GET_GLOBAL/SET_GLOBAL, vm.globals 테이블, 대입 표현식 (canAssign 전파)
4. 지역 변수 - Compiler 구조체(locals 배열, scopeDepth), 블록 `{}`, 선언/정의 2단계, 슬롯 인덱스로 OP_GET_LOCAL/SET_LOCAL, 스코프 종료 시 OP_POP
5. `var a = a;` 자기 초기화 감지 (depth -1 마커)
6. 제어 흐름 - OP_JUMP/JUMP_IF_FALSE/LOOP, emitJump/patchJump/emitLoop 백패칭
   - if/else, and/or (단락 평가), while, for (초기화/조건/증가 desugaring)
7. 점프 거리 16비트 초과 시 "Too much code to jump over." 컴파일 에러
8. 테스트 러너 연동 - `vendor/` 또는 `tests/`에 공식 craftinginterpreters `test/` 디렉토리 복사(또는 서브모듈), 러너 스크립트 준비
   - 공식 Dart 러너 사용 또는 expect 주석(`// expect: ...`, 에러 기대 포함)을 파싱하는 간단한 Python 러너 자작
   - 챕터 suite 필터 지원 (chap21_global, chap22_local, chap23_jumping)

## must-haves

- 지역 변수는 런타임 이름 조회 없음 (컴파일 타임 슬롯 해석 - clox 설계의 핵심)
- 전역과 지역의 의미론 차이 유지 (전역은 늦은 바인딩, 지역은 렉시컬)
- 러너가 통과/실패 개수를 요약 출력

## 검증

- [ ] 챕터 suite 필터 기준 `test/assignment/`, `test/variable/` 통과 (R7)
- [ ] 미정의 전역 참조가 "Undefined variable 'x'." 런타임 에러 + exit 70 (R7)
- [ ] `var a = a;` 가 컴파일 에러가 된다 (R7)
- [ ] 챕터 suite 필터 기준 `test/if/`, `test/logical_operator/`, `test/while/`, `test/for/` 통과 (R8)
- [ ] 점프 거리 16비트 초과 시 "Too much code to jump over." 컴파일 에러 (R8) - `test/limit/loop_too_large.lox`로 확인

검증 명령: 러너 실행 예 `python3 tools/run_tests.py --suite chap23_jumping` (자작 러너 기준, 실제 인터페이스는 구현 시 확정)
