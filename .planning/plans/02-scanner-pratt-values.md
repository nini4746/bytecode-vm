# Plan 02: 렉서, Pratt 파서, 값 체계 (Ch 16~18)

## 목표

소스 코드를 스캔하고 Pratt 파서로 표현식을 바이트코드로 컴파일하며, Value를 태그드 유니언으로 확장한다. SPEC의 R3, R4, R5 구현.

## 컨텍스트

- plan 01 완료 상태: 청크, VM 디스패치 루프, 디스어셈블러, 산술 opcode가 존재. main.c는 수작성 청크 데모.
- 교재: Ch 16 (Scanning on Demand), Ch 17 (Compiling Expressions), Ch 18 (Types of Values).
- 이 plan이 끝나면 "문자열 소스 → 토큰 → 바이트코드 → 실행" 파이프라인이 완성된다. 아직 문(statement)은 없고 표현식 하나만 평가.

## 작업

1. `src/main.c` 개편 - REPL(fgets 한 줄) + 파일 실행 모드, 종료 코드 64/65/70/0
2. `src/scanner.h/c` - Scanner(start/current/line), 온디맨드 scanToken
   - 1~2글자 연산자, 문자열, 숫자, 식별자
   - 키워드는 trie 방식 분기 (checkKeyword)
   - 주석/공백 스킵, TOKEN_ERROR (닫히지 않은 문자열, 알 수 없는 문자)
3. `src/compiler.h/c` - Parser(current/previous, hadError/panicMode), advance/consume/errorAt
4. Pratt 파서 코어 - Precedence 열거형, ParseRule 테이블(prefix/infix/우선순위), parsePrecedence, expression
   - number, grouping, unary, binary
5. `DEBUG_PRINT_CODE` 플래그 - 컴파일 직후 청크 디스어셈블
6. Value를 태그드 유니언으로 - VAL_BOOL/VAL_NIL/VAL_NUMBER, IS_/AS_/BOOL_VAL 매크로
7. 새 opcode - OP_NIL/TRUE/FALSE, OP_NOT, OP_EQUAL/GREATER/LESS (>=는 NOT+LESS 합성)
8. runtimeError() - 가변 인자, ip에서 라인 역산, 피연산자 타입 검사
9. printValue 확장 - bool/nil, 숫자는 %g 계열로 정수면 소수점 없이 출력

## must-haves

- 단일 패스: AST 없이 파싱과 코드 생성이 동시에 (책의 설계 그대로)
- 컴파일 에러는 exit 65, 런타임 에러는 exit 70
- 타입 오류에서 절대 세그폴트 금지 (peek로 검사 후 pop)

## 검증

- [ ] 모든 Lox 키워드/연산자가 올바른 TokenType으로 스캔된다 - 임시 토큰 덤프 모드로 확인 후 제거 (R3)
- [ ] 닫히지 않은 문자열, 알 수 없는 문자가 TOKEN_ERROR로 보고된다 (R3)
- [ ] `(-1 + 2) * 3 - -4` 평가 결과가 7이다 (R4)
- [ ] `1 * 2 + 3`과 `1 + 2 * 3`이 다르게 컴파일된다 - DEBUG_PRINT_CODE 디스어셈블로 확인 (R4)
- [ ] 문법 오류 시 라인 번호 포함 에러 메시지 + exit 65 (R4)
- [ ] `!(5 - 4 > 3 * 2 == !nil)` 평가 결과가 true이다 (R5)
- [ ] `-"abc"` 류가 "Operand must be a number." + exit 70, 세그폴트 없음 (R5) - 주의: 문자열 객체는 plan 03이므로 이 시점엔 `-true`, `-nil`로 검증
- [ ] 3.0이 "3"으로 출력된다 (R5)

검증 명령: `echo '(-1 + 2) * 3 - -4' | ./clox` (REPL) 또는 임시 .lox 파일로 `./clox test.lox; echo $?`
