# StackOS

**Bare-Metal ARM Cortex-M3 Assembly Project - A Stack-Based Calculator with BigInt Support**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-ARM%20Cortex--M3-blue)](https://www.arm.com/)
[![IDE](https://img.shields.io/badge/IDE-Keil%20uVision-green)](https://www.keil.com/)

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Project Phases](#project-phases)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Building the Project](#building-the-project)
- [Testing and Debugging](#testing-and-debugging)
- [Code Standards (AAPCS)](#code-standards-aapcs)
- [Usage Examples](#usage-examples)
- [License](#license)
- [Contributing](#contributing)
- [Acknowledgments](#acknowledgments)
- [Contact](#contact)
- [Further Reading](#further-reading)

---

## Overview

**StackOS** is a bare-metal ARM assembly project that implements a stack-based calculator with arbitrary-precision integer arithmetic. It is designed for the **ARM Cortex-M3** architecture, specifically targeting the **STM32F103RB** microcontroller.

The project is intended as a hands-on exploration of low-level programming concepts, including:

- Computer architecture and memory management
- Stack operations and function calling conventions (AAPCS)
- UART communication and low-level I/O
- BigInt arithmetic: addition, subtraction, multiplication, and division
- RPN (Reverse Polish Notation) parsing and interpretation
- Dynamic memory management using an arena allocator
- Exception handling and input validation

Rather than relying on high-level libraries, StackOS implements its core functionality directly in ARM assembly. This requires explicit management of registers, memory, stacks, communication interfaces, and arithmetic operations.

---

## Key Features

### Interactive Command Shell

- Custom command-line interface with a `StackOS>` prompt
- Keyboard input buffer with Backspace support
- Input sanitization and filtering of ANSI escape sequences and control characters
- RPN tokenization and command parsing

### BigInt Arithmetic Engine

- **Arbitrary-precision integers** - the number of digits is limited primarily by available RAM
- **Four core operations:** addition, subtraction, multiplication, and division
- **Signed integer support** with algebraic routing and XOR-based sign determination
- **Sliding-window division algorithm** for BigInt division

### Memory Management

- **Arena allocator** for fast, linear memory allocation
- **Software math stack** implemented as a LIFO structure and kept separate from the hardware stack
- **AAPCS-compliant function calls** with appropriate caller- and callee-saved register handling

### Error Handling and Robustness

- **Division-by-zero protection** before division is executed
- **Input firewall** for filtering invalid control sequences
- **Stack recovery** after syntax or parsing errors
- Defensive error handling to reduce the risk of unexpected system hangs

### Hardware Integration

- **UART driver** using polling-based serial communication
- **Memory-mapped I/O** for direct access to hardware registers
- **Simulator support** for Keil µVision and CPUlator environments

---

## Architecture

The project is organized into several layers, from the user-facing command shell down to the hardware interface:

```text
┌─────────────────────────────────────────────┐
│              Command Shell (CLI)            │
│             main.s + shell_io.s             │
└──────────────────────┬──────────────────────┘
                       │
┌──────────────────────▼──────────────────────┐
│             RPN Parser & Tokenizer           │
│                  rpn_parser.s                 │
└──────────────────────┬──────────────────────┘
                       │
┌──────────────────────▼──────────────────────┐
│               Algebraic Router               │
│       SIGNED_ADD, SIGNED_SUB, etc.           │
└──────────────────────┬──────────────────────┘
                       │
┌──────────────────────▼──────────────────────┐
│                 BigInt Core                  │
│       ABS_ADD, ABS_SUB, ABS_MUL, ABS_DIV     │
└──────────────────────┬──────────────────────┘
                       │
┌──────────────────────▼──────────────────────┐
│             Software Math Stack              │
│              MATH_PUSH / MATH_POP            │
└──────────────────────┬──────────────────────┘
                       │
┌──────────────────────▼──────────────────────┐
│              Arena Allocator                 │
│             ARENA_INIT / ALLOC               │
└──────────────────────┬──────────────────────┘
                       │
┌──────────────────────▼──────────────────────┐
│               Hardware Layer                │
│             UART + Startup Code             │
│              startup.s + shell_io.s          │
└─────────────────────────────────────────────┘
```

---

## Project Structure

```text
StackOS/
├── startup.s          # Startup code, vector table, and stack initialization
├── main.s             # Main loop, command shell, and keyboard buffer
├── shell_io.s         # UART drivers, I/O functions, and input filtering
├── memory_core.s      # Arena allocator and software math stack
├── string_utils.s     # String utilities: length, comparison, normalization
├── math_basic.s       # Signed/unsigned addition and subtraction
├── math_adv.s         # Signed/unsigned multiplication and division
├── rpn_parser.s       # RPN parser, tokenizer, and operator handling
├── StackOS.uvprojx    # Keil µVision project file
├── .gitignore         # Git ignore rules for the project
└── README.md          # Project documentation
```

---

## Project Phases

| Phase | Title | Focus | Score |
|:-----:|---|---|:-----:|
| 0 | Environment Setup | Keil configuration and startup file creation | - |
| 1 | UART I/O & Bootloader | Reset vector, UART driver, and basic I/O | 5 |
| 2 | Command Shell & Buffer | Keyboard buffer, Backspace handling, and input firewall | 5 |
| 3 | Arena Allocator | Dynamic memory management using a linear allocator | 5 |
| 4 | String Utilities | Length, comparison, and normalization of strings | 5 |
| 5 | Software Stack & AAPCS | LIFO math stack and register preservation | 10 |
| 6 | BigInt Addition | Carry management and digit-by-digit addition | 10 |
| 7 | BigInt Subtraction | Borrow management, magnitude comparison, and operand ordering | 10 |
| 8 | BigInt Multiplication | Nested loops, accumulation, and division-related instructions such as `UDIV`/`MLS` | 15 |
| 9 | BigInt Division | Sliding-window algorithm and in-place subtraction | 15 |
| 10 | Algebraic Routing | Signed-number support and XOR-based sign determination | 5 |
| 11 | RPN Parser | Tokenization, operator detection, and stack management | 10 |
| 12 | Security & Exceptions | Division-by-zero protection, input filtering, and stack recovery | 5 |
| **Total** | | | **100** |

---

## Prerequisites

### Software

- **Keil µVision 5 (MDK-ARM)** - recommended for development and debugging
- **CPUlator** - optional online simulator for quick testing
- **Git** - for version control
- **ARM Compiler 6** - included with recent versions of Keil MDK

### Hardware (Optional)

- **STM32F103RB** or another compatible ARM Cortex-M3 development board
- **USB-to-UART adapter** for testing on physical hardware

---

## Getting Started

### 1. Clone the Repository

Replace `your-username` with the actual GitHub account that owns the repository.

```bash
git clone https://github.com/your-username/StackOS.git
cd StackOS
```

### 2. Open the Project in Keil µVision

1. Launch **Keil µVision**.
2. Select **Project → Open Project**.
3. Navigate to the cloned repository.
4. Open `StackOS.uvprojx`.

### 3. Configure the Simulator

1. Open **Options for Target** using the Magic Wand icon.
2. Go to the **Debug** tab.
3. Select **Use Simulator**.
4. Configure the simulator as follows:

   - **Dialog DLL:** `DARMSTM.DLL`
   - **Parameter:** `-pSTM32F103RB`

5. Click **OK**.

### 4. Build the Project

Press **F7** or use the **Build** command in Keil.

A successful build should produce output similar to:

```text
Build target 'StackOS_Simulator'
assembling startup.s...
assembling main.s...
...
"StackOS.axf" - 0 Error(s), 0 Warning(s).
```

### 5. Run in Debug Mode

1. Press **Ctrl+F5** to enter Debug mode.
2. Open the UART terminal using **View → Serial Windows → UART #1**.
3. Press **F5** to start execution.
4. The terminal should display the welcome message:

```text
Welcome to StackOS V1.0
```

### 6. Test the Calculator

At the `StackOS>` prompt, enter an RPN expression such as:

```text
10 20 + 5 *
```

Expected output:

```text
150
```

---

## Building the Project

### Using Keil µVision

1. Open `StackOS.uvprojx`.
2. Press **F7** to build the target.
3. The generated `.axf` file should be placed in the configured `Objects/` output directory.

### Using the Command Line

When the ARM Compiler 6 toolchain is available in your PATH, the project can also be built from the command line. The exact commands may need to be adjusted to match the project's startup code, scatter-loading configuration, and linker settings.

```bash
armclang -c --target=arm-arm-none-eabi -mcpu=cortex-m3 -mthumb *.s
armlink --cpu=Cortex-M3 *.o --map --symbols --info=summary --output=StackOS.axf
```

> **Note:** For the most reliable build, use the provided Keil project configuration because it contains the project-specific target and linker settings.

---

## Testing and Debugging

### UART #1 Terminal

- **Menu:** `View → Serial Windows → UART #1`
- **Purpose:** Real-time input and output for the command shell
- **Tip:** Click inside the terminal window before typing commands.

### Memory Window

- **Menu:** `View → Memory Windows → Memory 1`
- **Useful regions:** `0x20000000` for SRAM and `0x40000000` for peripheral memory
- **Tip:** Use an ASCII representation when inspecting string data.

### Registers Window

- **Menu:** `View → Registers Window`
- **Useful registers to monitor:**
  - `R13 (SP)` - hardware stack pointer
  - `PSP` - process stack pointer, when dual-stack operation is used
  - `R0-R12` - general-purpose registers

### Disassembly Window

- **Menu:** `View → Disassembly Window`
- **Purpose:** Inspect generated machine instructions and verify control flow and branch targets.

---

## Code Standards (AAPCS)

The project follows the **ARM Architecture Procedure Call Standard (AAPCS)** for function interfaces and register preservation.

### Register Usage

| Registers | Role | Saved By |
|---|---|---|
| `R0-R3` | Arguments and return values | Caller |
| `R4-R11` | Callee-saved registers / local state | Callee |
| `R12` | Intra-procedure-call scratch register (IP) | Caller |
| `R13 (SP)` | Stack pointer | - |
| `R14 (LR)` | Link register | Callee / calling convention |
| `R15 (PC)` | Program counter | - |

### Example Function Template

```asm
MyFunction:
    PUSH    {R4-R7, LR}        ; Save callee-saved registers
    ; ... function body ...
    POP     {R4-R7, PC}        ; Restore registers and return
```

### Stack Alignment

The project aims to preserve the required **8-byte stack alignment** at public function boundaries.

For example, when a sequence would leave the stack misaligned, explicit padding may be required:

```asm
PUSH    {R4-R11, LR}
SUB     SP, SP, #4             ; Restore 8-byte alignment
; ... function body ...
ADD     SP, SP, #4
POP     {R4-R11, PC}
```

> **Important:** The exact prologue/epilogue must match the function's actual register usage and stack layout. Alignment padding should not be added blindly.

---

## Usage Examples

After startup, the following prompt should appear:

```text
StackOS>
```

Enter an expression using **Reverse Polish Notation (RPN)** and press Enter.

| User Input | Expected Output |
|---|---:|
| `12 34 +` | `46` |
| `999 999 *` | `998001` |
| `1000 5 -` | `995` |
| `-10 -5 *` | `50` |
| `100 3 /` | `33` |
| `100 50 50 - /` | `Error: Division by zero is undefined.` |
| `10 20 + 5 *` | `150` |

---

## License

This project is licensed under the **MIT License**.

See the [`LICENSE`](LICENSE) file for the full license text.

---

## Contributing

Contributions are welcome. To contribute:

1. Fork the repository.
2. Create a feature branch:

   ```bash
   git checkout -b feature/amazing-feature
   ```

3. Commit your changes:

   ```bash
   git commit -m "Add amazing feature"
   ```

4. Push the branch:

   ```bash
   git push origin feature/amazing-feature
   ```

5. Open a Pull Request and describe the changes you made.

### Coding Guidelines

- Maintain AAPCS compliance.
- Keep the code modular and well organized.
- Use clear comments and meaningful labels.
- Avoid unnecessary duplication.
- Test changes thoroughly before submitting a Pull Request.

---

## Acknowledgments

- **ARM** - for the ARM architecture and instruction set
- **Keil** - for the µVision development environment
- **STMicroelectronics** - for the STM32 Cortex-M3 platform
- **CPUlator** - for providing an accessible online simulation environment
- **All contributors** - for their work and interest in low-level programming

---

## Contact

For questions, bug reports, or collaboration:

- **GitHub Issues:** `https://github.com/amirpoori99/StackOS/issues`
- **Email:** `amirpoori99@gmail.com`


---

## Further Reading

- [ARM Architecture Reference Manual](https://developer.arm.com/documentation/ddi0403/latest/)
- [AAPCS Specification](https://developer.arm.com/documentation/ihi0042/latest/)
- [STM32F103 Reference Manual](https://www.st.com/resource/en/reference_manual/rm0008-stm32f101xx-stm32f102xx-stm32f103xx-stm32f105xx-and-stm32f107xx-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf)
- [Keil µVision User Guide](https://www.keil.com/support/man/docs/uv4/)

---

**Built with ❤️ and pure ARM assembly.**
