import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";

export default defineConfig({
  plugins: [
    svelte(),
    {
      name: "beacon-file-runtime-html",
      enforce: "post",
      transformIndexHtml(html, ctx) {
        // Keep dev-server HTML untouched so ESM scripts still run.
        if (!ctx?.bundle) {
          return html;
        }
        return html
          .replace(/\s+crossorigin(?:="[^"]*")?/g, "")
          .replace(/\s+type="module"/g, "")
          .replace(/<script\s+src=/g, "<script defer src=");
      }
    }
  ],
  base: "./",
  build: {
    modulePreload: false,
    outDir: "build",
    emptyOutDir: true
  }
});
