Prerequisites

Before running the build command, you must install:
1. **Node.js** (v18 or later)
2. **Rust** (via rustup.rs)
3. **pnpm**: `npm install -g pnpm`
4. **Visual Studio Build Tools** (Windows only, with C++ development tools)

Install dependencies:
   pnpm install

The final standalone executable will be located in:
- `src-tauri/target/release/bss-ai-gui.exe`

## Build Commands

The final build command to create the standalone Windows executable (.exe) is:

```bash
cargo tauri build

upx --best --lzma src-tauri\target\release\bss-ai-gui.exe
```
