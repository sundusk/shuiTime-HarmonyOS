---
name: harmonyos-official-docs
description: Use this skill when working on this repository's HarmonyOS app, especially for ArkTS, ArkUI, resources, UIAbility, file APIs, or compiler/runtime errors. Prefer Huawei official documentation first, using the HarmonyOS application development guide as the primary entry point: https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide
---

# HarmonyOS Official Docs

This repository is a HarmonyOS native project. When implementing or fixing HarmonyOS code here, prefer Huawei official documentation before relying on memory.

## Primary doc entry

- Official entry: [HarmonyOS 应用开发导读](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)

## Use this skill when

- Writing or fixing ArkTS code
- Building ArkUI pages or components
- Working with resources, media files, or project structure
- Working with `UIAbility`, stage model, routing, or lifecycle
- Handling file APIs, storage APIs, or backup-related APIs
- Resolving HarmonyOS compiler errors or runtime behavior differences

## Workflow

1. Start from the official guide entry above.
2. Find the most specific official page for the current problem before changing code.
3. Prefer official API names, component properties, and resource rules over memory.
4. If the current project behavior conflicts with memory, trust the official docs and the project's actual compiler/runtime behavior.
5. When unsure, keep the implementation conservative and compatible with the current project setup.

## Focus areas

- ArkTS syntax restrictions and compiler constraints
- ArkUI component properties and layout behavior
- Resource directory rules and media usage
- File/storage APIs and type expectations
- HarmonyOS-specific lifecycle and stage model behavior

## Notes

- Avoid assuming web or cross-platform patterns apply to HarmonyOS.
- For icon and resource questions, prefer HarmonyOS official design/system resources when available.
- If a doc page is unavailable or ambiguous, state that and then fall back to the safest working implementation.
