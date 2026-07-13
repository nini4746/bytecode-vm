# Plan 07: mark-and-sweep GC (Ch 26)

## 목표

트라이컬러 mark-and-sweep GC를 구현해 도달 불가능한 객체만 회수한다. SPEC의 R11 구현.

## 컨텍스트

- plan 06 완료 상태: 클로저까지 완성. 객체는 vm.objects 리스트에 쌓이기만 하고 프로그램 종료 전엔 해제되지 않는다.
- 교재: Ch 26 (Garbage Collection).
- 버그가 가장 잠복하기 쉬운 챕터. GC 버그는 재현이 어렵기 때문에 `DEBUG_STRESS_GC`(모든 할당에서 GC 실행)를 개발 내내 켜고 작업하는 것이 책의 권장이자 이 plan의 규칙이다.
- 고전 함정: GC 도중 할당. 예를 들어 문자열 연결 중간값이나 테이블 리사이즈가 GC를 트리거하면, 아직 루트에서 도달할 수 없는 신생 객체가 회수될 수 있다. 해결은 임시 객체를 스택에 push해서 보호하는 것.

## 작업

1. `DEBUG_STRESS_GC`, `DEBUG_LOG_GC` 플래그 - reallocate에서 스트레스 트리거, 할당/해제/GC 단계 로그
2. collectGarbage 골격 + markRoots - 값 스택, CallFrame의 클로저, openUpvalues, vm.globals, 컴파일러 중간 객체(markCompilerRoots - 컴파일 중 함수 객체 체인)
3. markValue/markObject, isMarked 플래그
4. gray 스택 (worklist) - 별도 동적 배열, GC 관리 밖(realloc 직접 사용, 실패 시 exit)
5. blackenObject - 타입별 참조 추적 (클로저의 upvalue 배열, 함수의 상수 풀과 이름, upvalue의 closed 값, 테이블)
6. 인터닝 테이블 약한 참조 - sweep 직전 tableRemoveWhite로 마킹 안 된 문자열 제거
7. sweep - vm.objects 리스트 순회, 흰 객체 해제, isMarked 리셋
8. GC 스케줄링 - bytesAllocated / nextGC, GC_HEAP_GROW_FACTOR(2)
9. 중간값 보호 - concatenate 등에서 push/pop으로 신생 객체 보호 (책이 짚는 지점들 그대로)

## must-haves

- 개발 기간 내내 DEBUG_STRESS_GC 빌드로 테스트 (일반 빌드만 통과는 무효)
- 인터닝 테이블은 루트가 아니다 (강한 루트로 마킹하면 문자열이 영원히 안 죽음)
- gray 스택 할당 자체가 GC를 재귀 트리거하지 않는다

## 검증

- [ ] DEBUG_STRESS_GC 빌드로 chap21~chap25 suite 전체가 여전히 통과한다 (R11)
- [ ] stress 빌드에서 문자열 연결을 수천 회 반복하는 스크립트가 잘못된 값 없이 완주한다 - GC 중 할당 보호 검증 (R11)
- [ ] 인터닝 테이블만 참조하는 죽은 문자열이 회수된다 - DEBUG_LOG_GC 로그로 확인 (R11)
- [ ] 일반 빌드에서 반복 할당 스크립트의 메모리가 무한 증가하지 않는다 (GC 트리거 확인, LOG_GC 로그)

검증 명령: `make clean && make CFLAGS_EXTRA='-DDEBUG_STRESS_GC' && python3 tools/run_tests.py --suite chap25_closures`
