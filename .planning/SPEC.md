# SPEC: 바이트코드 VM + 미니 언어 (clox)

> 토이 7번 (최종 보스). Crafting Interpreters 후반부(Part III, Ch 14~29)를 C로 완주하는 학습 프로젝트.
> 1인 개발, 사용자가 직접 타이핑. AI는 스펙/plan/리뷰만 담당. 기간 1~2개월.

## 목표

Lox 언어의 바이트코드 컴파일러 + 스택 VM을 C로 밑바닥부터 구현하고, 공식 Lox 테스트 스위트를 통과한다.
학습이 목적이므로 각 마일스톤은 책 챕터 묶음이며, 코드는 사용자가 직접 작성한다.

## 인터뷰 요약 (자문자답)

- 그린필드: 코드 0줄에서 시작. README.md만 존재.
- 완료 판정: munificent/craftinginterpreters 공식 저장소 `test/` 디렉토리의 clox 대상 테스트 통과 (benchmark 제외).
- 최소 버전: Ch 14~29 본편. Ch 30 최적화는 범위 외.
- 게이트 점수: 목표 0.90 / 경계 0.85 / 제약 0.80 / 수용 0.85 → 모호성 0.14 (통과).

## 제약

- 언어: C99. clox 바이너리는 외부 의존성 없음 (C 표준 라이브러리만). 테스트 러너 등 개발 도구는 이 제한과 무관 (Dart, Python 허용).
- 빌드: macOS(Darwin) clang + Makefile. `make` 한 번으로 `clox` 바이너리 생성.
- 종료 코드 규약 (책과 동일): 사용법 오류 64, 컴파일 에러 65, 런타임 에러 70, 정상 0.
- 개발 중 `DEBUG_STRESS_GC`(할당마다 GC)와 `DEBUG_LOG_GC`를 켤 수 있어야 한다 (컴파일 플래그).
- 테스트: 공식 `test/` 디렉토리의 .lox 파일 + 러너 (공식 Dart 러너 또는 expect 주석을 파싱하는 간단한 자체 스크립트). 챕터별 서브셋은 공식 러너의 챕터 suite 정의(chap21_global 등)를 필터 기준으로 사용한다 - "의존 파일 제외"의 판정 주체는 이 suite 정의다.
- 기간: 1~2개월, plan 8개, plan당 약 1주.

## 요구사항

각 항목: 검증 문장 / 현재 상태 / 목표 상태 / 수용 기준.

### R1. 바이트코드 청크와 디스어셈블러 (Ch 14)

- 검증 문장: 동적 배열 기반 Chunk에 opcode와 상수를 기록하고, 디스어셈블러가 사람이 읽을 수 있는 형태로 출력한다.
- 현재: 없음.
- 목표: chunk.c, value.c, memory.c, debug.c가 존재하고 OP_CONSTANT/OP_RETURN을 담은 청크를 디스어셈블 출력.
- 수용 기준:
  - [ ] 수작성 청크(상수 1.2 + OP_RETURN)의 디스어셈블 출력에 오프셋, 라인 번호, opcode 이름, 상수 값이 표시된다
  - [ ] 상수 257개 이상을 넣어도 동적 배열이 크래시 없이 성장한다

### R2. 스택 기반 VM 코어 (Ch 15)

- 검증 문장: VM이 디스패치 루프로 청크를 실행하고 값 스택으로 산술 연산을 수행한다.
- 현재: 없음.
- 목표: vm.c의 run() 루프가 OP_ADD/SUB/MUL/DIV/NEGATE를 스택 기반으로 실행.
- 수용 기준:
  - [ ] `-((1.2 + 3.4) / 5.6)`에 해당하는 수작성 청크 실행 결과가 -0.8214285714285714이다
  - [ ] `DEBUG_TRACE_EXECUTION` 플래그로 명령마다 스택 상태가 출력된다

### R3. 렉서 (Ch 16)

- 검증 문장: 소스 문자열을 온디맨드로 스캔해 Lox의 전체 토큰 종류를 라인 번호와 함께 생성한다.
- 현재: 없음.
- 목표: scanner.c가 키워드(trie 방식), 식별자, 숫자, 문자열, 2글자 연산자, 주석 스킵을 처리.
- 수용 기준:
  - [ ] 모든 Lox 키워드와 연산자가 올바른 TokenType으로 스캔된다 (임시 토큰 덤프 모드로 확인)
  - [ ] 닫히지 않은 문자열과 알 수 없는 문자가 TOKEN_ERROR로 보고된다

### R4. Pratt 파서와 표현식 컴파일 (Ch 17)

- 검증 문장: Pratt 파서(우선순위 등반)가 표현식을 단일 패스로 바이트코드로 컴파일한다.
- 현재: 없음.
- 목표: compiler.c의 ParseRule 테이블 + parsePrecedence()가 그루핑, 단항, 이항, 우선순위를 처리.
- 수용 기준:
  - [ ] `(-1 + 2) * 3 - -4` 평가 결과가 7이다
  - [ ] `1 * 2 + 3`과 `1 + 2 * 3`의 우선순위가 다르게 컴파일된다 (디스어셈블로 확인)
  - [ ] 문법 오류 시 라인 번호를 포함한 에러 메시지가 출력되고 exit 65로 종료된다

### R5. 값 체계와 런타임 에러 (Ch 18)

- 검증 문장: Value가 태그드 유니언(nil/bool/number)이 되고, 타입 오류는 런타임 에러로 보고된다.
- 현재: 없음 (R2 시점에는 double 단일 타입).
- 목표: 비교/동등/논리 부정 연산자 지원, runtimeError()가 라인 번호와 함께 보고.
- 수용 기준:
  - [ ] `!(5 - 4 > 3 * 2 == !nil)` 평가 결과가 true이다
  - [ ] `-"abc"` 류 타입 오류가 "Operand must be a number." 메시지 + exit 70으로 처리된다 (세그폴트 금지)
  - [ ] 정수 값 숫자는 소수점 없이 출력된다 (3.0 → "3", 공식 테스트가 기대하는 형식)

### R6. 문자열 객체, 인터닝, 해시 테이블 (Ch 19~20)

- 검증 문장: 힙 할당 문자열 객체와 오픈 어드레싱 해시 테이블이 동작하고 모든 문자열이 인터닝된다.
- 현재: 없음.
- 목표: object.c(ObjString, FNV-1a 해시), table.c(선형 탐사, 툼스톤, 0.75 로드 팩터), VM 전역 객체 리스트.
- 수용 기준:
  - [ ] `"st" + "ri" + "ng"` 연결 결과가 "string"이다
  - [ ] 동일 내용 문자열의 동등 비교가 포인터 비교로 true가 된다 (인터닝)
  - [ ] 테이블에 삽입/삭제/재삽입을 반복해도 (툼스톤 경유) 조회가 올바르다

### R7. 전역 변수와 지역 변수 (Ch 21~22)

- 검증 문장: print 문, 전역 변수(런타임 해시 테이블), 지역 변수(컴파일 타임 스택 슬롯 해석)가 동작한다.
- 현재: 없음.
- 목표: 문 단위 파싱(선언/문 구분, 패닉 모드 동기화), 스코프 깊이 추적, 슬롯 인덱스 접근.
- 수용 기준:
  - [ ] 공식 테스트 `test/assignment/`, `test/variable/` 통과 (클로저/클래스 의존 파일 제외)
  - [ ] 미정의 전역 참조가 "Undefined variable" 런타임 에러가 된다
  - [ ] `var a = a;` 형태의 자기 초기화가 컴파일 에러가 된다

### R8. 제어 흐름 (Ch 23)

- 검증 문장: if/else, and/or(단락 평가), while, for가 점프 백패칭으로 컴파일된다.
- 현재: 없음.
- 목표: emitJump()/patchJump()/emitLoop(), for 문의 desugaring.
- 수용 기준:
  - [ ] 공식 테스트 `test/if/`, `test/logical_operator/`, `test/while/`, `test/for/` 통과 (클로저/함수 의존 파일 제외)
  - [ ] 점프 거리가 16비트 한계를 넘으면 "Too much code to jump over." 컴파일 에러가 된다

### R9. 함수와 콜 프레임 (Ch 24)

- 검증 문장: 함수 선언/호출이 콜 프레임 스택으로 실행되고, 재귀와 네이티브 함수(clock)가 동작한다.
- 현재: 없음.
- 목표: ObjFunction, CallFrame 배열(FRAMES_MAX 64), 인자 개수 검증, return 문, 스택 트레이스.
- 수용 기준:
  - [ ] 공식 테스트 `test/function/`, `test/call/`, `test/return/` 통과 (클로저 의존 파일 제외)
  - [ ] fib(10) 재귀가 55를 출력한다
  - [ ] 콜 프레임 초과 시 "Stack overflow." 런타임 에러 + 스택 트레이스 + exit 70 (크래시 금지) - `test/limit/stack_overflow.lox` 통과
  - [ ] 인자 개수 불일치가 "Expected N arguments but got M." 런타임 에러가 된다

### R10. 클로저와 upvalue (Ch 25)

- 검증 문장: 클로저가 바깥 변수를 값이 아닌 변수로 캡처하고, 스택을 벗어난 변수는 힙으로 close된다.
- 현재: 없음.
- 목표: ObjClosure, ObjUpvalue(open/closed), 컴파일러 upvalue 해석 체인, VM open upvalue 정렬 리스트.
- 수용 기준:
  - [ ] 공식 테스트 `test/closure/` 전체 통과
  - [ ] 두 클로저가 같은 변수를 공유 캡처하면 한쪽의 대입이 다른 쪽에 보인다 (변수 캡처 검증)
  - [ ] 루프 안에서 만든 클로저가 close된 뒤에도 자신의 캡처 값을 유지한다

### R11. mark-and-sweep GC (Ch 26)

- 검증 문장: 트라이컬러 mark-and-sweep GC가 도달 불가능 객체만 회수하고, 할당량 기반으로 트리거된다.
- 현재: 없음.
- 목표: 루트 마킹(스택, 프레임, open upvalue, 전역, 컴파일러 중간 객체), gray 스택 추적, 인터닝 테이블 약한 참조 처리, GC_HEAP_GROW_FACTOR 스케줄링.
- 수용 기준:
  - [ ] `DEBUG_STRESS_GC`를 켠 상태로 R7~R10의 모든 테스트 서브셋이 여전히 통과한다
  - [ ] GC 도중 할당(테이블 리사이즈, 문자열 연결 중간값)에서 도달 가능한 신생 객체가 회수되지 않는다 (stress 모드에서 문자열 연결 반복 스크립트로 검증)
  - [ ] 인터닝 테이블만 참조하는 죽은 문자열이 회수된다 (DEBUG_LOG_GC로 확인)

### R12. 클래스, 인스턴스, 메서드 (Ch 27~28)

- 검증 문장: 클래스 선언, 인스턴스 필드, 메서드, this, init 생성자, 바운드 메서드가 동작한다.
- 현재: 없음.
- 목표: ObjClass/ObjInstance/ObjBoundMethod, OP_INVOKE 최적화 포함.
- 수용 기준:
  - [ ] 공식 테스트 `test/class/`, `test/field/`, `test/method/`, `test/this/`, `test/constructor/`, `test/operator/` 통과 (상속 의존 파일 제외)
  - [ ] init이 인스턴스를 암묵 반환하고, init 안의 `return 값;`이 컴파일 에러가 된다
  - [ ] 클래스 밖의 this 사용이 컴파일 에러가 된다

### R13. 상속과 super (Ch 29)

- 검증 문장: 단일 상속(메서드 복사 방식)과 super 호출이 동작한다.
- 현재: 없음.
- 목표: 슈퍼클래스 캡처용 합성 지역 변수, OP_GET_SUPER/OP_SUPER_INVOKE.
- 수용 기준:
  - [ ] 공식 테스트 `test/inheritance/`, `test/super/` 통과
  - [ ] `class A < A {}` 자기 상속이 컴파일 에러가 된다
  - [ ] 숫자 등 비클래스 상속이 "Superclass must be a class." 런타임 에러가 된다

### R14. 공식 테스트 스위트 전체 통과 (통합)

- 검증 문장: 공식 Lox 테스트 스위트의 clox 대상 테스트가 한 번의 러너 실행으로 전부 통과한다.
- 현재: 없음.
- 목표: 러너 한 방 실행 = 완료 판정. 이전 plan에서 제외했던 파일 전부 포함.
- 수용 기준:
  - [ ] 공식 러너의 clox suite 정의 기준 `test/` 전체가 통과한다 (benchmark, expressions, scanning 등 jlox 전용은 suite 정의가 자동 제외)
  - [ ] `test/limit/` 중 clox 해당 파일(loop_too_large, too_many_constants, too_many_locals, too_many_upvalues, stack_overflow)이 통과한다
  - [ ] `DEBUG_STRESS_GC` 빌드로도 전체 스위트가 통과한다 (시간이 걸려도 무방)

## 부정 수용 기준 (must-NOT)

아래 기준은 모든 plan에서 상시 준수하고, 최종 판정은 plan 08 검증에 귀속된다.

- [ ] 어떤 Lox 입력(악의적 입력 포함)에도 세그폴트나 크래시로 죽지 않는다. 항상 진단 메시지 + 규약된 종료 코드.
- [ ] 테스트 스위트가 부분 통과인 상태에서 완료를 선언하지 않는다. R14가 유일한 완료 판정이다.
- [ ] AI가 구현 코드를 대신 작성하지 않는다. 코드는 사용자가 직접 타이핑한다 (학습 목적). AI 역할은 스펙, plan, 질문 답변, 코드 리뷰까지.
- [ ] 외부 라이브러리 의존성을 추가하지 않는다.

## 경계

### 범위 내

- clox 본편 Ch 14~29 전체 (렉서 → Pratt 파서 → 단일 패스 바이트코드 컴파일 → 스택 VM → 객체/클로저 → mark-and-sweep GC → 클래스/상속)
- 공식 Lox 테스트 스위트 러너 연동
- REPL (기본형: fgets 한 줄 입력) + 파일 실행 모드
- 디버그 플래그 (TRACE_EXECUTION, PRINT_CODE, STRESS_GC, LOG_GC)
- 네이티브 함수 clock()

### 범위 외 (이유 포함)

- jlox (Java 트리워크 인터프리터) - 책 전반부, 이 토이의 목표가 아님
- Ch 30 최적화 (NaN boxing, 인라인 캐시) - 학습 핵심이 아니고 기간 제약. R14 통과 후 여유 시 선택
- 책의 챌린지 문제들 - 본편 완주가 우선. 흥미 있는 것만 개인 선택
- JVM 클래스파일 파서 + 미니 JVM 인터프리터 변형 - 확장 후보로만 기재 (README 참고)
- aver/achuk 방향 AI 언어 확장 - 확장 후보로만 기재. VM 기초 완성 후 별도 프로젝트로 승격 검토
- readline/히스토리 등 REPL 고도화 - 학습 가치 낮음
- Windows/Linux 포팅 - macOS clang만 지원

## 엣지 해소 기록

| 엣지 | 처리 | 근거 |
|---|---|---|
| 클로저가 값 캡처 vs 변수 캡처 | 명세에 추가 (R10) | Lox 의미론은 변수 캡처. 공유 대입 가시성 테스트로 검증 |
| GC 트리거 중 할당 시 신생 객체 회수 | 명세에 추가 (R11 부정 기준) | clox의 고전 함정. 스택 push로 임시 보호 + stress GC로 검증 |
| 콜 프레임 스택 오버플로 | 명세에 추가 (R9) | 크래시 금지. 런타임 에러 + 스택 트레이스 |
| 인터닝 테이블이 GC 강한 루트가 되는 문제 | 테스트로 방어 (R11) | sweep 직전 약한 참조 제거. LOG_GC로 확인 |
| 숫자 출력 형식 (정수는 소수점 없이) | 명세에 추가 (테스트 스위트가 강제) | printValue의 %g 계열 처리. 공식 테스트가 정확한 형식을 기대 |
| Ch 30 최적화 | 기각 | 학습 핵심 아님, 기간 제약. 범위 외에 기재 |

## plan 매핑

| Plan | 챕터 | 요구사항 |
|---|---|---|
| 01-chunk-vm-skeleton | Ch 14~15 | R1, R2 |
| 02-scanner-pratt-values | Ch 16~18 | R3, R4, R5 |
| 03-strings-hash-tables | Ch 19~20 | R6 |
| 04-variables-control-flow | Ch 21~23 | R7, R8 |
| 05-functions-calls | Ch 24 | R9 |
| 06-closures | Ch 25 | R10 |
| 07-garbage-collection | Ch 26 | R11 |
| 08-classes-inheritance-final | Ch 27~29 + 통합 | R12, R13, R14 |
