import { readdirSync } from "fs";

console.log("Hello, World!");
const files = readdirSync(".", { withFileTypes: false });
console.log(files);
