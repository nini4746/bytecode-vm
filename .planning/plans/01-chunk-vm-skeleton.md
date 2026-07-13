# Plan 01: 바이트코드 청크와 VM 골격 (Ch 14~15)

## 목표

동적 배열 기반 바이트코드 청크, 디스어셈블러, 스택 기반 디스패치 루프를 만든다. SPEC의 R1, R2 구현.

## 컨텍스트

- 그린필드. 저장소에 README.md만 있음. 이 plan이 프로젝트 뼈대(git, Makefile, 디렉토리)를 만든다.
- 교재: Crafting Interpreters Ch 14 (Chunks of Bytecode), Ch 15 (A Virtual Machine).
- 이 단계에서 언어는 아직 없다. main.c에서 청크를 수작성해서 VM에 먹인다.
- 학습 규칙: 코드는 사용자가 직접 타이핑. AI는 질문 답변과 리뷰만.

## 작업

1. 프로젝트 셋업: `git init`, `.gitignore`(clox, *.o), `Makefile` (clang, -std=c99 -Wall -Wextra, `make` 한 번으로 `clox` 생성)
2. `src/common.h` - 공용 include, 디버그 플래그 매크로 자리
3. `src/chunk.h/c` - Chunk 구조체 (code 동적 배열, 라인 정보, 상수 풀), writeChunk, addConstant
4. `src/memory.h/c` - GROW_CAPACITY, GROW_ARRAY, reallocate (이후 GC의 단일 관문이 될 함수)
5. `src/value.h/c` - Value(당장은 double 별칭), ValueArray, printValue
6. `src/debug.h/c` - disassembleChunk, disassembleInstruction (OP_CONSTANT, OP_RETURN)
7. `src/vm.h/c` - VM 구조체 (ip, 값 스택 256), run() 디스패치 루프, push/pop
8. 산술 opcode: OP_ADD, OP_SUBTRACT, OP_MULTIPLY, OP_DIVIDE, OP_NEGATE
9. `DEBUG_TRACE_EXECUTION` 플래그 - 명령마다 스택 덤프 + 디스어셈블
10. `src/main.c` - 수작성 청크로 산술 식 실행 데모

## must-haves

- reallocate 하나로 모든 할당/해제가 지나가는 구조 (Ch 26 GC의 전제)
- 청크가 라인 번호를 보존 (에러 보고의 전제)
- 값 스택 기반 실행 (레지스터 방식 아님)

## 검증

- [ ] `make` 한 번으로 clox 빌드 성공, 경고 0
- [ ] 상수 1.2 + OP_RETURN 청크의 디스어셈블 출력에 오프셋, 라인 번호, opcode 이름, 상수 값이 표시된다 (R1)
- [ ] 상수 257개 이상 추가해도 크래시 없이 동적 배열이 성장한다 (R1) - main.c에 임시 루프로 확인
- [ ] `-((1.2 + 3.4) / 5.6)` 수작성 청크 실행 결과가 -0.8214285714285714이다 (R2)
- [ ] `DEBUG_TRACE_EXECUTION` 활성화 시 명령마다 스택 상태가 출력된다 (R2)

검증 명령: `make && ./clox` (main.c 데모), 트레이스 빌드는 `make clean && make CFLAGS_EXTRA=-DDEBUG_TRACE_EXECUTION` 형태로.
