# CSL304: Compiler Design - Assignment 3

* Paritosh Lahre

---

### Directory Content
1. `lex.l` (Lexical Analyzer)
2. `parser.y` (Syntax Analyzer / Parser)
3. `symbol.c` (Symbol Table Implementation)
4. `symbol.h` (Symbol Table Header)
5. `README.md` (Project Documentation)
6. `input.txt` (Test Case 1 - gemini)
7. `bigger_testcase.txt` (Test Case 2 - Dungeon Simulation - gemini)

---

## 1. Transition: From Syntax Analysis (Assign 2) to Code Generation (Assign 3)

The previous assignment focused solely on validating the grammatical structure of the code. To evolve this into a compiler front-end that generates Three-Address Code (TAC), two major architectural changes were made:

* **Data Passing:** The Lexer was updated to pass actual semantic values (variable names, literals) to the parser using `yylval.str`, rather than just returning token types.
* **Semantic Memory:** We integrated a Symbol Table to track variable declarations, ensuring the parser has "memory" of what has been defined.

## 2. Key Technical Implementation: The "Marker" Strategy

A critical challenge in generating TAC for control flow (loops/conditionals) using a bottom-up parser (Bison) is that the body of a loop is parsed *before* the reduction of the loop statement itself.

* **Solution:** We implemented Marker Non-Terminals (M).
* **Function:** These are empty rules inserted into `if`, `while`, and `for` grammar productions. They force the compiler to generate labels and conditional jumps immediately after the condition is evaluated, ensuring the linear flow of the generated TAC is correct.

## 3. Task Compliance & Features

This implementation fulfills the specific semantic requirements outlined in the assignment:

* **TAC Generation:** Successfully takes an input program and outputs Three-Address Code for the main function.
* **Symbol Table Integration:** Enforces that all identifiers are declared before access and prevents duplicate declarations.
* **Control Flow:** Handles the "Dangling Else" ambiguity by associating `else` with the nearest `if`.
* **Logic & Precedence:** Logical AND/OR operators are evaluated without short-circuiting, and operators follow standard C-language precedence.
* **Arrays:** Fully supports `NewArray` declarations and index-based referencing.

---

## Execution Instructions

To compile and run the project:

```bash
lex lex.l
yacc -d parser.y
gcc lex.yy.c y.tab.c symbol.c -o out
./out < input.txt
```

Bigger testcase - Dungeon Simulation

```bash
./out < bigger_testcase.txt
```

Output for input.txt(testcase):

```bash
Inserted: area, Type: double, Scope: 0
t0 = 3.14 * r
t1 = t0 * r
area = t1
Inserted: x, Type: int, Scope: 0
Inserted: y, Type: int, Scope: 0
t2 = x * x
t3 = y * y
t4 = t2 + t3
return t4
Inserted: i, Type: int, Scope: 0
Inserted: j, Type: int, Scope: 0
Inserted: count, Type: int, Scope: 0
Inserted: result, Type: double, Scope: 0
Inserted: isValid, Type: bool, Scope: 0
Inserted: finished, Type: bool, Scope: 0
Inserted: v1, Type: Vector, Scope: 0
v1 = new Vector
Inserted: g1, Type: Geometry, Scope: 0
Inserted: numbers, Type: Array, Scope: 0
numbers = newArray(20, int)
Inserted: weights, Type: Array, Scope: 0
weights = newArray(10, double)
i = 0
count = 0
isValid = true
finished = false
result = 0.0
i = 0
L0:
t5 = i < 10
L1:
t6 = i + 1
i = t6
ifFalse t5 goto L3
goto L2
L1:
goto L0
L2:
t7 = numbers[i]
t8 = i * 2
t9 = t8 + 5
t7 = t9
goto L1
L3:
i = 0
L4:
t10 = i < 10
ifFalse t10 goto L5
t11 = numbers[i]
t12 = 10.5 * 2.0
t13 = t11 + t12
t14 = 4.0 / 2.0
t15 = t13 - t14
result = t15
t16 = result > 50.0
ifFalse t16 goto L6
t17 = count + 1
count = t17
t18 = count >= 5
ifFalse t18 goto L7
isValid = false
goto L_BREAK
L7:
goto L8
L6:
t19 = v1.x
t19 = i
t20 = v1.y
t20 = count
t21 = g1.area
t21 = result
L8:
t22 = i + 1
i = t22
goto L4
L5:
j = 10
L9:
t23 = j - 1
j = t23
t24 = weights[j]
t24 = result
t25 = j > 0
if t25 goto L9
t26 = isValid == true
t27 = count < 10
t28 = t26 && t27
t29 = i > 5
t30 = t28 || t29
ifFalse t30 goto L10
t31 = -1.0
result = t31
L10:
return 0
```
