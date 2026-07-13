# Plan 03: 문자열 객체와 해시 테이블 (Ch 19~20)

## 목표

힙 할당 객체 시스템(ObjString)과 오픈 어드레싱 해시 테이블을 만들고 문자열을 인터닝한다. SPEC의 R6 구현.

## 컨텍스트

- plan 02 완료 상태: 표현식 평가 파이프라인 완성, Value는 nil/bool/number 태그드 유니언.
- 교재: Ch 19 (Strings), Ch 20 (Hash Tables).
- 여기서 만드는 Obj 헤더와 VM 객체 리스트가 Ch 26 GC의 기반이 된다. 해시 테이블은 이후 전역 변수(plan 04), 문자열 인터닝, 클래스 메서드(plan 08)에 재사용된다.

## 작업

1. `src/object.h/c` - Obj 헤더(type, next), ObjString(length, chars, hash), OBJ_TYPE/IS_STRING/AS_STRING 매크로
2. Value에 VAL_OBJ 추가, printObject
3. 문자열 리터럴 컴파일 (copyString) + OP_ADD의 문자열 연결 분기 (concatenate, takeString)
4. VM 객체 연결 리스트 - 모든 Obj를 vm.objects에 등록, freeObjects로 종료 시 일괄 해제
5. FNV-1a 해시 함수
6. `src/table.h/c` - Entry(key, value), 선형 탐사, 로드 팩터 0.75, adjustCapacity
   - tableSet / tableGet / tableDelete (툼스톤 방식) / tableAddAll / findEntry
7. 문자열 인터닝 - vm.strings 테이블, tableFindString, copyString/takeString에서 기존 문자열 재사용
8. 문자열 동등 비교를 포인터 비교로 단순화

## must-haves

- 모든 ObjString이 인터닝을 거친다 (예외 없음 - 이후 메서드 조회 성능과 == 의미론의 전제)
- 툼스톤이 삭제 후 탐사 체인을 끊지 않는다
- 모든 객체가 vm.objects 리스트에 연결된다 (GC의 sweep 대상 목록)

## 검증

- [ ] `"st" + "ri" + "ng"` 결과가 "string"으로 출력된다 (R6)
- [ ] 동일 내용 문자열의 `==` 비교가 true다 - 인터닝 확인 (R6)
- [ ] `"a" + 1` 이 "Operands must be two numbers or two strings." 런타임 에러가 된다
- [ ] 테이블 삽입/삭제/재삽입 반복 후에도 조회가 올바르다 - 임시 C 테스트 코드 또는 전역 변수 구현(plan 04) 후 스크립트로 확인 (R6)
- [ ] valgrind 또는 leaks로 종료 시 해제 확인 (freeObjects 동작, 이 시점 기준)

검증 명령: `echo 'print 대신 표현식' | ./clox` - 아직 print 문이 없으므로 REPL 표현식 결과 출력으로 확인. `leaks --atExit -- ./clox test.lox`
