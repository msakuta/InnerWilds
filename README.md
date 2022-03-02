# Inner Wilds

A game written in Nim for the [WASM-4](https://wasm4.org) fantasy console.

Try it now on your browser! https://msakuta.github.io/InnerWilds/out.html

![video](https://msakuta.github.io/images/showcase/InnerWilds.gif)
## What is unique about this project?

Wasm-4 is an interesting project that imitates 4-bit consoles with WebAssembly,
but obviously it isn't true 4-bit console.
In particular, WebAssembly is equipped fully capable IEEE 754 floating point processor instructions.
Also an interesting thing to note about [hardware specs](https://wasm4.org/docs/#hardware-specs)
is that it does not mention about CPU specification.
This is because WebAssembly is designed to be architecture agnostic and
it should run on any modern CPUs.
It means we can leverage modern CPU architecture and speed in supposedly 4-bit-ish
platform.

That said, RAM and ROM capacity is very limited (64kb for each), so we want
something that can run with little memory.
And what is a good example of that?
Ray tracing!

## Why Nim?

Nim is a systems programming language suitable for low-end CPUs.
Or I should say one of many of this kind.

At first, as Rust lover, I wanted to write in Rust.
However, Rust compiles to a big Wasm binary as soon as I link trigonometric functions which are required by 3D graphics, and it exceeds ROM size specification pretty quickly.
Apparently Wasm doesn't have mathematical functions as part of intrinsics,
so the language has to implement them as library functions.
Also, a lot of library codes seem to come from runtime, e.g. panic handlers.

Zig was another candidate, but for some reason it didn't compile in my environment.

Nim was the last candidate that can compile fairly small binary (~10kb).
I could write in C or C++ since Nim compiles to C, but I took this opportunity
to write something with a new language.

## Building

Build the cart by running:

```shell
nimble rel
```

Then run it with:

```shell
w4 run build/cart.wasm
```

For more info about setting up WASM-4, see the [quickstart guide](https://wasm4.org/docs/getting-started/setup?code-lang=nim#quickstart).

## Links

- [Documentation](https://wasm4.org/docs): Learn more about WASM-4.
- [Snake Tutorial](https://wasm4.org/docs/tutorials/snake/goal): Learn how to build a complete game
  with a step-by-step tutorial.
- [GitHub](https://github.com/aduros/wasm4): Submit an issue or PR. Contributions are welcome!
