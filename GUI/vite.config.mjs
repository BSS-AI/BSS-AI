import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

export default defineConfig({
  root: './src',
  base: './',
  build: {
    outDir: '../public',
    emptyOutDir: true,
    sourcemap: false,
    minify: 'esbuild',
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'src', 'index.html'),
        tokenPriority: resolve(__dirname, 'src', 'tokenPriority.html'),
      },
    },
  },
  plugins: [
    react()
  ]
})