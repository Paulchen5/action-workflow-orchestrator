// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-nocheck
"use strict";

import { FlatCompat } from "@eslint/eslintrc";

import js from "@eslint/js";
import globals from "globals";
import tseslint from "typescript-eslint";
import json from "@eslint/json";
import markdown from "@eslint/markdown";
import { defineConfig } from "eslint/config";
import gtsConfig from "gts/.eslintrc.json" with { type: "json" };

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: gtsConfig
});

export default defineConfig([
  {
    ignores: ["**/node_modules/**", "**/build/**"]
  },
  {
    files: ["**/*.{js,mjs,cjs,ts,mts,cts}"],
    plugins: { js },
    extends: ["js/recommended"],
    languageOptions: { globals: globals.browser }
  },
  tseslint.configs.recommended,
  {
    files: ["**/*.json"],
    plugins: { json },
    language: "json/json",
    extends: ["json/recommended"]
  },
  {
    files: ["**/*.jsonc"],
    plugins: { json },
    language: "json/jsonc",
    extends: ["json/recommended"]
  },
  {
    files: ["**/*.json5"],
    plugins: { json },
    language: "json/json5",
    extends: ["json/recommended"]
  },
  {
    files: ["**/*.md"],
    plugins: { markdown },
    language: "markdown/gfm",
    extends: ["markdown/recommended"]
  },
  ...compat.config({})
]);
