# Plan 08: 클래스, 상속, 최종 통합 (Ch 27~29)

## 목표

클래스/인스턴스/메서드/init/상속/super를 완성하고 공식 테스트 스위트 전체를 통과시켜 프로젝트를 완료한다. SPEC의 R12, R13, R14 구현.

## 컨텍스트

- plan 07 완료 상태: GC까지 완성된 함수형 Lox. 객체지향 기능만 남았다.
- 교재: Ch 27 (Classes and Instances), Ch 28 (Methods and Initializers), Ch 29 (Superclasses).
- 새 객체 타입이 GC 이후에 추가되므로, 각 타입마다 blackenObject/freeObject 분기를 함께 추가해야 한다 (빠뜨리면 GC 버그).
- 이 plan의 마지막 작업이 R14 최종 판정: 러너 한 방 실행으로 clox suite 전체 통과.

## 작업

1. Ch 27 - ObjClass, ObjInstance(fields 테이블), class 선언, OP_CLASS, OP_GET_PROPERTY/SET_PROPERTY
   - 비인스턴스 프로퍼티 접근 "Only instances have properties." 런타임 에러
2. Ch 28 - 메서드: OP_METHOD, klass->methods 테이블, ObjBoundMethod
   - this: TYPE_METHOD 컴파일러의 슬롯 0 = this, 클래스 밖 this 컴파일 에러 (currentClass 체인)
   - init: TYPE_INITIALIZER, 암묵 this 반환, `return 값;` 컴파일 에러, 인자 개수 검증
   - 최적화: OP_INVOKE (프로퍼티 조회 + 호출 융합), 필드가 메서드를 가리는 경우 처리
3. Ch 29 - 상속: `class A < B`, 메서드 복사(tableAddAll), 자기 상속 컴파일 에러, 비클래스 상속 런타임 에러
   - super: 합성 지역 변수 "super"로 슈퍼클래스 캡처(스코프), OP_GET_SUPER, OP_SUPER_INVOKE
   - 클래스 밖/슈퍼클래스 없는 클래스의 super 컴파일 에러
4. 새 객체 타입 4종의 GC 통합 - blackenObject, freeObject, 스트레스 빌드로 즉시 검증
5. 최종 통합 - 러너를 clox 전체 suite로 실행, 실패 케이스 잡기 (limit 계열: too_many_constants, too_many_locals, too_many_upvalues 등)
6. must-NOT 최종 점검

## must-haves

- OP_INVOKE가 있어도 바운드 메서드 의미론 유지 (`var m = obj.method; m();` 동작)
- 상속이 메서드 복사 방식 (런타임 슈퍼클래스 체인 탐색 아님 - clox 설계)
- 새 객체 타입 전부 GC 추적 대상

## 검증

- [ ] 챕터 suite 기준 `test/class/`, `test/field/`, `test/method/`, `test/this/`, `test/constructor/`, `test/operator/` 통과 (R12)
- [ ] init의 `return 값;`이 컴파일 에러, init은 인스턴스를 암묵 반환 (R12)
- [ ] 클래스 밖 this가 컴파일 에러 (R12)
- [ ] `test/inheritance/`, `test/super/` 통과 (R13)
- [ ] `class A < A {}` 컴파일 에러 (R13)
- [ ] 비클래스 상속이 "Superclass must be a class." 런타임 에러 (R13)
- [ ] 공식 러너의 clox suite 정의 기준 `test/` 전체 통과 - 이전 plan에서 제외했던 파일 전부 포함 (R14)
- [ ] `test/limit/` 중 clox 해당 파일(loop_too_large, too_many_constants, too_many_locals, too_many_upvalues, stack_overflow) 통과 (R14)
- [ ] DEBUG_STRESS_GC 빌드로도 전체 suite 통과 (R14)
- [ ] must-NOT 점검: 세그폴트 없음(퍼징성 이상 입력 몇 개 수동 확인), 외부 의존성 0 (Makefile에 -l 플래그 없음), 부분 통과 상태 아님 (R14가 완료 판정)

검증 명령: `python3 tools/run_tests.py --suite clox` 그리고 `make clean && make CFLAGS_EXTRA='-DDEBUG_STRESS_GC' && python3 tools/run_tests.py --suite clox`

## 완료 후

R14 통과 = 프로젝트 완료. 이후 선택 확장 (범위 외, 별도 스펙 필요):
- Ch 30 최적화 (NaN boxing, 인라인 캐시)
- JVM 클래스파일 파서 + 미니 JVM 인터프리터 변형
- aver/achuk 방향 AI 언어 확장
