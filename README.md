# Compiler

編譯器課程作業，分三個階段實作一個類 Turing 語言 (`.st`) 的 compiler，使用 **Lex/Flex** 做 scanning、**Yacc/Bison** 做 parsing，最後產生 **Java bytecode (JVM assembly)**。

## project1 — Scanner

用 Lex 寫 lexical analyzer：tokenize keyword、identifier、integer、real、string、boolean、註解（單行 / 多行）以及符號，並維護 symbol table。

執行：

```bash
cd project1
make run    # lex → gcc → ./a.out < input
```

## project2 — Parser

在 project1 的 scanner 上加入 Yacc grammar，定義語言的 syntax rules，scanner 改成把 token 回傳給 parser。支援宣告、運算式、控制流程（`if`/`loop`/`exit when`）、函式與程序。

執行：

```bash
cd project2
make
```

## project3 — Code Generation

在 parser 上加 semantic actions，把 source 編譯成 Java bytecode（JVM assembly），輸出到 `argv[1]` 指定的 `.java` 檔，再用 `javaa` 組譯成 `.class` 後由 JVM 執行。支援變數 / 常數 / 區塊 scope、算術與邏輯運算、`if-else`、`loop / exit when`、function call、`put` / `read` I/O。

執行：

```bash
cd project3
make          # 編譯 scanner+parser 並對 testinputfile.txt 產生 tmp.java
make java     # javaa tmp.java && java example
```
