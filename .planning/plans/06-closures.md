# Plan 06: 클로저와 upvalue (Ch 25)

## 목표

클로저가 바깥 함수의 변수를 캡처하고, 스택을 벗어난 변수는 힙으로 close되게 한다. SPEC의 R10 구현.

## 컨텍스트

- plan 05 완료 상태: 함수, 콜 프레임, 네이티브 함수. 함수는 아직 바깥 지역 변수를 참조할 수 없다.
- 교재: Ch 25 (Closures).
- clox에서 개념적으로 가장 어려운 챕터. 핵심 설계: upvalue는 처음엔 스택 슬롯을 가리키는 포인터(open), 변수가 스택에서 사라질 때 값을 upvalue 안으로 복사(closed). Lox 의미론은 값 캡처가 아니라 변수 캡처다 - 같은 변수를 캡처한 두 클로저는 대입을 서로 본다.

## 작업

1. ObjClosure - function + upvalue 포인터 배열. 모든 함수 참조를 클로저로 감싸도록 개편 (OP_CLOSURE)
2. 컴파일러 upvalue 해석 - resolveUpvalue 재귀 (enclosing의 local → enclosing의 upvalue 순서), Upvalue{index, isLocal} 배열, 중복 캡처 방지
3. ObjUpvalue - location 포인터, closed 값, next (정렬 연결 리스트)
4. OP_GET_UPVALUE / OP_SET_UPVALUE
5. captureUpvalue - vm.openUpvalues 정렬 리스트에서 기존 upvalue 재사용 (같은 변수 = 같은 upvalue 객체)
6. OP_CLOSE_UPVALUE - 스코프/함수 종료 시 closeUpvalues (location 값을 closed로 복사하고 포인터 재지정)
7. 컴파일러가 스코프 종료 시 캡처된 지역만 OP_CLOSE_UPVALUE, 나머지는 OP_POP (isCaptured 플래그)
8. 러너 suite 갱신 - chap25_closures

## must-haves

- 변수 캡처 의미론 (값 복사 아님) - 공유 대입 가시성
- 같은 지역 변수에 대한 upvalue 객체는 VM 전체에서 유일 (openUpvalues 리스트로 보장)
- 함수 return 시에도 closeUpvalues 호출 (블록 종료만이 아님)

## 검증

- [ ] `test/closure/` 전체 통과 (R10)
- [ ] 두 클로저가 같은 변수를 공유 캡처하면 한쪽의 대입이 다른 쪽에 보인다 (R10)
- [ ] 루프 안에서 만든 클로저가 close된 뒤에도 자신의 캡처 값을 유지한다 (R10)
- [ ] `test/for/closure_in_body.lox`, `test/while/closure_in_body.lox` 통과

검증 명령: `python3 tools/run_tests.py --suite chap25_closures`
