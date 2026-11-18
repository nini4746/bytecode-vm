# 설계 결정 기록 (ADR)

| 번호 | 결정 | 상태 | 날짜 |
|------|------|------|------|
| [0001](0001-single-pass-compiler-and-stack-vm.md) | 단일 패스 컴파일러와 스택 기반 VM | 채택 | 2026-07-13 |
| [0002](0002-textbook-core-scope.md) | 범위는 교재 본편: 태그드 유니언 Value, 1바이트 상수 인덱스 | 채택 | 2026-07-13 |
| [0003](0003-call-frames-inside-run.md) | 함수 호출은 `run()` 안의 프레임 전환 | 채택 | 2026-07-13 |
| [0004](0004-upvalues-open-closed.md) | 클로저: open/closed upvalue와 주소순 정렬 리스트 | 채택 | 2026-07-13 |
| [0005](0005-string-interning-open-addressing.md) | 문자열 인터닝과 오픈 어드레싱 해시 테이블 | 채택 | 2026-07-13 |
| [0006](0006-mark-sweep-gc.md) | mark-and-sweep GC: 단일 할당 경로와 할당량 기반 트리거 | 채택 | 2026-07-13 |
| [0007](0007-inheritance-copy-and-op-invoke.md) | 클래스: 상속은 메서드 복사, 메서드 호출은 `OP_INVOKE` 융합 | 채택 | 2026-07-13 |
