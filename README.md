# CSL304: Compiler Design - Object Oriented Language Compiler

**Course:** CSL304: Compiler Design  
* **Paritosh Lahre** (12341550)

---

## 📖 Project Overview

This repository contains the progressive development of a compiler front-end for a variant of an Object-Oriented Programming language (similar to C++/Java). The project was developed in three phases, evolving from a lexical analyzer to a syntax analyzer, and finally into an Intermediate Code Generator producing Three-Address Code (TAC).

### 🚀 Development Phases

#### Phase 1: Lexical Analysis (Assignment 1)
* **Goal:** Tokenize raw source code into a sequence of valid tokens.
* **Implementation:** Built using **Flex**.
* **Features:**
    * Identifies Keywords (`class`, `int`, `void`, `if`, etc.) and Operators.
    * Handles Constants: Integers (Decimal & Hexadecimal), Doubles (Scientific notation), and Strings.
    * Strips whitespace and comments (Single-line `//` and Multi-line `/* ... */`).

#### Phase 2: Syntax Analysis (Assignment 2)
* **Goal:** Validate the grammatical structure of the code against defined production rules.
* **Implementation:** Built using **Bison (Yacc)** and **Flex**.
* **Features:**
    * Defines the program structure: Global `main` function, Class declarations, and Variable/Function declarations.
    * Enforces operator precedence (e.g., `*` over `+`) and associativity.
    * Validates complex control flow structures: `If-Else`, `While`, `Do-While`, and `For` loops.

#### Phase 3: Intermediate Code Generation (Assignment 3 - Final Build)
* **Goal:** Generate Three-Address Code (TAC) and perform semantic checks.
* **Implementation:** Integrated **Symbol Table**, **Semantic Actions**, and **Marker Non-Terminals**.
* **Key Transitions from Phase 2:**
    1.  **Data Passing:** Upgraded the Lexer to pass actual semantic values (literals, variable names) to the parser using `yylval.str` instead of just token types.
    2.  **Memory:** Implemented a **Symbol Table** using hashing to track variable scope and types.

---

## 🛠️ Key Technical Features (Final Build)

### 1. Symbol Table Integration
A custom symbol table (implemented in C) is integrated to handle semantics:
* **Declaration Check:** Ensures all variables are declared before use.
* **Duplicate Check:** Prevents redeclaration of variables within the same scope.

### 2. The "Marker" Strategy for Control Flow
Generating linear TAC using a bottom-up parser (Bison) is challenging because loop bodies are reduced *before* the loop condition logic.
* **Solution:** We injected **Marker Non-Terminals (`M`)** into the grammar rules.
* **Result:** These empty rules force the compiler to generate labels (`L0`, `L1`) and conditional jumps (`ifFalse ... goto`) *immediately* after evaluating conditions, ensuring correct logical flow.

### 3. Semantic Rules
* **Dangling Else:** Resolved by associating the `else` with the most immediate `if`.
* **Logical Operators:** Implemented without short-circuit evaluation (both sides of `&&`/`||` are computed).
* **Array Support:** Supports `NewArray` allocation and index-based access logic.

---

## 📂 Directory Structure

```text
├── 1-assignment             # Phase 1: Lexical Analysis
│   ├── CSL302_Assignment-1.pdf
│   ├── README
│   └── solution.l
├── 2-assignment             # Phase 2: Syntax Analysis
│   ├── CSL302_Assignment-2.pdf
│   ├── input.txt
│   ├── lex.l
│   ├── parser.y
│   └── README.md
├── 3-assignment             # Phase 3: Intermediate Code Generation (Final Build)
│   ├── Assignment-3.pdf
│   ├── bigger_testcase.txt
│   ├── input.txt
│   ├── lex.l
│   ├── parser.y
│   ├── README.md
│   ├── symbol.c
│   └── symbol.h
└── README.md                # Main Documentation
```

## Execution Instructions

To compile and run the project:

Install these , if u don't have on your Debian/Ubuntu/WSL system:

```bash
sudo apt update && sudo apt install flex bison build-essential
```

```bash
git clone https://github.com/SandstromPL/Compiler-Design-CSL304.git
cd 3-assignment/
```

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
input.txt:

```bash
/* Complex Test Case for CSL302 Assignment 3 
   Features: Classes, Arrays, Nested Loops, Mixed Arithmetic, Logical Ops
*/

class Geometry {
    double area;
    
    void setArea(double r) {
        area = 3.14 * r * r;
    }
}

class Vector {
    int x;
    int y;
    
    int magnitude() {
        return x * x + y * y;
    }
}

/* Main Function - Entry Point */
void main() {
    // 1. Declarations (Basic Types)
    int i;
    int j;
    int count;
    double result;
    bool isValid;
    bool finished;

    // 2. Object Instantiation
    // Syntax: ClassName ObjName New(ClassName);
    Vector v1 New(Vector);
    Geometry g1; 

    // 3. Array Declaration
    // Syntax: VarName NewArray(Size, Type);
    numbers NewArray(20, int);
    weights NewArray(10, double);

    // 4. Initialization
    i = 0;
    count = 0;
    isValid = true;
    finished = false;
    result = 0.0;

    // 5. Populating Array (For Loop)
    // TAC: Should generate labels L_FOR_COND, L_FOR_BODY, L_FOR_INC, L_FOR_END
    for (i = 0; i < 10; i = i + 1) {
        numbers[i] = i * 2 + 5;
    }

    // 6. Complex Control Flow (While with Nested If-Else)
    // TAC: Should generate labels for While loop and If/Else jumps
    i = 0;
    while (i < 10) {
        // Array Access and Mixed Arithmetic Precedence
        // Precedence Test: '*' and '/' should happen before '+' and '-'
        result = numbers[i] + 10.5 * 2.0 - 4.0 / 2.0;

        // Nested Logic
        if (result > 50.0) {
            count = count + 1;
            
            // Deeply nested If
            if (count >= 5) {
                isValid = false;
                break; // Test Break Statement
            }
        } else {
            // Object Member Access
            v1.x = i;
            v1.y = count;
            g1.area = result;
        }

        i = i + 1;
    }

    // 7. Do-While Loop
    j = 10;
    do {
        j = j - 1;
        weights[j] = result;
    } while (j > 0);

    // 8. Logical Operators (No Short Circuit)
    // TAC: Should evaluate BOTH sides regardless of the first result
    if (isValid == true && count < 10 || i > 5) {
        result = -1.0;
    }

    return 0;
}
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

## 🎓 Academic Submission Details

This project represents the culmination of work for the Compiler Design course, focusing on the implementation of a compiler front-end using Bison and Flex.

* **Course:** Compiler Design-CSL304
* **Semester:** Monsoon Semester 2025
* **Instructor/Professor:** Dr. Vishwesh Jatala
* **Institution:** IIT Bhilai
