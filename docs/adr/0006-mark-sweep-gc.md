# 0006. mark-and-sweep GC: 단일 할당 경로와 할당량 기반 트리거

- 상태: 채택
- 날짜: 2026-07-13

## 맥락
클로저, 클래스, 인스턴스 등 힙 객체를 회수해야 한다. GC 도중 할당이 신생 객체를 회수하는 것은 clox의 고전 함정이다.
개발 중 `DEBUG_STRESS_GC`(할당마다 GC)와 `DEBUG_LOG_GC`를 켤 수 있어야 한다.

## 결정
- 모든 할당은 `reallocate`를 거쳐 `bytesAllocated`를 세고, 이곳에서만 GC를 트리거한다.
- gray 스택은 `reallocate`가 아닌 시스템 `realloc`을 직접 쓴다.
- 인터닝 테이블은 약한 참조로, sweep 직전 `tableRemoveWhite`로 마킹되지 않은 문자열을 지운다.
- 첫 임계값은 1MB이고, GC 후 `nextGC = bytesAllocated * 2`(`GC_HEAP_GROW_FACTOR`)로 정한다.

## 대안
- 곳곳에서 `malloc`/`free`: 할당량을 정확히 셀 수 없고 트리거 지점이 흩어진다.
- gray 스택에 `reallocate` 사용: GC 도중 gray 스택 확장이 GC를 재귀 트리거한다.
- 인터닝 테이블을 루트로 마킹: 한 번 만든 문자열이 영원히 회수되지 않는다.
- 고정 주기, 객체 수 기준 트리거: 살아 있는 힙 크기에 비례해 빈도를 조절하는 쪽을 택했다.

## 결과
- 장점: GC 빈도가 살아 있는 힙 크기에 맞춰 조절된다. stress GC로 신생 객체 회수 버그를 잡을 수 있다.
- 단점/감수한 점: 할당 중 아직 루트에 닿지 않은 객체는 스택에 push해 직접 보호해야 한다.
