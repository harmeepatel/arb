import { readFileSync as fsReadFileSync } from "fs";
import { Recipe } from "./types";

const data = fsReadFileSync("./../main.wasm");
const typeArray = new Uint8Array(data);

const importObj = {
    env: {
        printi32: (val: number) => console.log(val)
    },
};

const { instance } = await WebAssembly.instantiate(typeArray, importObj);

const memory = instance.exports.memory;
const allocBytes = instance.exports.allocBytes as CallableFunction;
const freeBytes = instance.exports.freeBytes as CallableFunction;
const createImage = instance.exports.createImage as CallableFunction;

var recipeJsonBuffer = fsReadFileSync("../data/recipe.min.json");
const recipeU8Array = new Uint8Array(Array.from(
    recipeJsonBuffer.toString(),
    (val: string) => {
        return val.charCodeAt(0);
    }
));

const recipe_ptr = allocBytes(recipeU8Array.length * Uint8Array.BYTES_PER_ELEMENT);
if (recipe_ptr === 0) throw new Error("OOM")

try {
    const values = new Uint8Array(memory.buffer, recipe_ptr, recipeU8Array.length);
    for (let i = 0; i < recipeU8Array.length; i++) {
        values[i] = recipeU8Array[i]
    }

    createImage(recipe_ptr, recipeU8Array.length);
} finally {
    freeBytes(recipe_ptr, recipeU8Array.length * Uint8Array.BYTES_PER_ELEMENT)
}
