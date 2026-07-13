# Plan 05: 함수와 콜 프레임 (Ch 24)

## 목표

함수 선언/호출을 콜 프레임 스택으로 실행하고 네이티브 함수와 스택 트레이스를 만든다. SPEC의 R9 구현.

## 컨텍스트

- plan 04 완료 상태: 변수, 제어 흐름, print 문, 공식 테스트 러너 연동 완료.
- 교재: Ch 24 (Calls and Functions).
- 구조 대수술 챕터: "청크 하나"에서 "함수마다 청크"로, "ip 하나"에서 "CallFrame 배열"로 바뀐다. 컴파일러도 함수 단위로 중첩된다(enclosing 체인). 최상위 코드 자체가 암묵적 함수가 된다.

## 작업

1. ObjFunction - arity, chunk, name. 컴파일러가 ObjFunction을 반환하도록 개편
2. Compiler 구조체에 enclosing 포인터, FunctionType(TYPE_FUNCTION/TYPE_SCRIPT), 슬롯 0 예약
3. CallFrame - function, ip, slots(값 스택 창). FRAMES_MAX 64, 프레임별 상대 슬롯 접근으로 OP_GET_LOCAL 등 수정
4. fun 선언 파싱, 매개변수, OP_CALL, callValue/call - 인자 개수 검증
5. return 문 - OP_RETURN 개편 (프레임 pop, 결과 push), 최상위 return 금지 컴파일 에러
6. 스택 트레이스 - runtimeError가 프레임 역순으로 "[line N] in fnName" 출력
7. 콜 프레임 초과 시 "Stack overflow." 런타임 에러 (크래시 금지)
8. 네이티브 함수 - ObjNative, defineNative, clock() 등록
9. 러너 suite 갱신 - chap24_calls

## must-haves

- 함수 호출이 C 재귀가 아닌 같은 run() 루프 안의 프레임 전환 (성능과 스택 오버플로 제어의 전제)
- 비호출 가능 값 호출("abc"())이 "Can only call functions and classes." 런타임 에러
- 슬롯 0 예약 유지 (Ch 28에서 this가 들어갈 자리)

## 검증

- [ ] 챕터 suite 기준 `test/function/`, `test/call/`, `test/return/` 통과 (R9)
- [ ] fib(10) 재귀가 55를 출력한다 (R9)
- [ ] `test/limit/stack_overflow.lox` 통과 - "Stack overflow." + 스택 트레이스 + exit 70, 크래시 없음 (R9)
- [ ] 인자 개수 불일치가 "Expected N arguments but got M." 런타임 에러 (R9)
- [ ] clock()으로 경과 시간 측정이 동작한다

검증 명령: `python3 tools/run_tests.py --suite chap24_calls` (러너 인터페이스는 plan 04에서 확정된 형태를 따름)
