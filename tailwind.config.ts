import type { Config } from "tailwindcss";

export default {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["var(--font-sans)", "system-ui", "sans-serif"],
        mono: ["var(--font-mono)", "ui-monospace", "monospace"],
        display: ["var(--font-display)", "ui-serif", "Georgia", "serif"],
      },
      colors: {
        ink: {
          50: "#f6f7f9",
          100: "#eceef2",
          200: "#d5dae3",
          300: "#b3bdcc",
          400: "#8996ad",
          500: "#6a7994",
          600: "#556178",
          700: "#464f62",
          800: "#3c4352",
          900: "#2d313c",
          950: "#1a1c22",
        },
        clinic: {
          // Accent system (kept compatible with existing usage)
          teal: "#2dd4bf",
          navy: "#0b1220",
          coral: "#fb7185",
        },
        glass: {
          50: "rgba(255,255,255,0.06)",
          100: "rgba(255,255,255,0.10)",
          200: "rgba(255,255,255,0.14)",
        },
      },
    },
  },
  plugins: [],
} satisfies Config;
