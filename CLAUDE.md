# CLAUDE.md — fpv-page

Personal website for Miguel Pais, an FPV drone pilot. Hosted on GitHub Pages at **fpv.miguelppais.com**.

## Project Type

**Pure static site — no build tools, no package manager, no compilation step.** All dependencies are loaded via CDN at runtime. To view the site, open the HTML files directly in a browser or serve the directory with any static file server (e.g. `python3 -m http.server`).

## Repository Structure

```
fpv-page/
├── index.html              # Main landing/link-in-bio page (vanilla HTML + JS)
├── sim_training_guide.html # Interactive FPV sim guide (build-less React app)
├── assets/
│   ├── Miguel_Pais_FPV_photo.jpg   # Profile photo (104 KB)
│   └── Miguel_Pais_FPV_logo_wt.png # Brand logo, white text (24 KB)
├── CNAME                   # GitHub Pages custom domain: fpv.miguelppais.com
├── README.md               # One-line project description
└── license                 # CC BY 4.0
```

## Pages

### `index.html` — Landing Page
Vanilla HTML with inline JavaScript. Contains:
- Profile photo + logo header
- Bio / services tagline
- Social media grid (TikTok, Instagram, YouTube)
- "Contact Me" mailto CTA
- **FPV Tools list** — dynamically rendered from the `TOOLS` JavaScript array; add new tools by appending to that array

### `sim_training_guide.html` — FPV Simulator Training Guide
A build-less React 18 app (JSX transpiled in-browser via Babel Standalone). Contains:
- **`FPV_DATA` array** — 44+ training scenario objects; the authoritative data store for the guide
- Goal-selector dropdown (built with `useState`)
- Filtered scenario cards (`useMemo`)
- Email suggestion CTA using `mailto:` with pre-filled subject/body
- About / contact section

## CDN Dependencies

All libraries are loaded from CDN — do **not** add `npm` or any local node_modules.

| Library | CDN | Used in |
|---|---|---|
| Tailwind CSS | `cdn.tailwindcss.com` | Both pages |
| Lucide Icons | `unpkg.com/lucide@latest` | Both pages |
| React 18 (production UMD) | `unpkg.com/react@18/umd/react.production.min.js` | sim_training_guide.html |
| ReactDOM 18 (production UMD) | `unpkg.com/react-dom@18/umd/react-dom.production.min.js` | sim_training_guide.html |
| Babel Standalone | `unpkg.com/@babel/standalone/babel.min.js` | sim_training_guide.html |
| Google Fonts (Inter) | `fonts.googleapis.com` | Both pages |

## Design System

### Color Palette
- **Background**: `bg-slate-950`
- **Surface/card**: `bg-slate-900`, `bg-slate-800` (hover)
- **Primary border**: `border-slate-800`
- **Body text**: `text-slate-100`
- **Muted text**: `text-slate-400`, `text-slate-500`, `text-slate-600`
- **Accent**: `text-sky-400` / `text-sky-500` / `bg-sky-500` (interactive elements, highlights)
- **Accent hover border**: `hover:border-sky-500/50`

### Typography
- Font: **Inter** (weights 400, 500, 600, 700, 800, 900)
- Labels/badges: `text-xs` or `text-[10px]`, `uppercase`, `tracking-widest`, `font-bold`
- Body: `text-sm` or `text-base`, `text-slate-400`, `leading-relaxed`
- Headings: `font-black` or `font-bold`, `uppercase`, tight tracking

### Component Conventions
- **Cards**: `bg-slate-900 border border-slate-800 rounded-2xl shadow-xl`
- **Hover state**: `hover:border-sky-500/50 hover:bg-slate-800 transition-all`
- **Lift on hover**: `hover:-translate-y-1`
- **Icon containers**: `p-3 bg-slate-950 rounded-xl text-sky-500 group-hover:scale-110 transition-transform`
- **Primary button**: `bg-sky-500 hover:bg-sky-400 text-slate-950 font-black rounded-2xl`
- **Glow effect**: `shadow-[0_0_20px_rgba(56,189,248,0.3)]`
- **Background blobs**: `absolute` divs with `bg-sky-500/10 blur-[120px] rounded-full`

### Icons
- Use **Lucide** icon names via `data-lucide="<name>"` attributes, then call `lucide.createIcons()` to initialize
- Lucide does not have a TikTok icon — a custom SVG path is used in both pages:
  ```html
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M9 12a4 4 0 1 0 4 4V4a5 5 0 0 0 5 5" />
  </svg>
  ```
- In the React page, the `Icon` component wraps Lucide and calls `lucide.createIcons()` in a `useEffect`

## Extending the Site

### Adding a new tool to index.html
Append an object to the `TOOLS` array in the inline `<script>`:
```js
{
    title: "Tool Name",
    subtitle: "Short descriptor",
    link: "relative-or-absolute-url.html",
    icon: "lucide-icon-name"
}
```

### Adding a new training scenario to sim_training_guide.html
Append an object to the `FPV_DATA` array inside the `<script type="text/babel">` block:
```js
{
    id: <unique_number>,
    category: "<Category>",      // e.g. "Technical", "Environmental"
    goal: "<Shared goal label>", // groups similar entries in the dropdown
    sim: "<Simulator Name>",
    link: "<Steam store URL>",
    map: "<Map or location>",
    tips: "<Practical tip string>",
    drone: "<Recommended drone>",
    icon: "<lucide-icon-name>"
}
```
Existing categories: Environmental, Signal, Technical, Automotive, Extreme Sports, Aviation, Drone Warfare, Racing, Scale, Dynamic.

## Development Workflow

1. **Edit** HTML files directly — no transpilation needed
2. **Preview** by opening the file in a browser, or run `python3 -m http.server 8080` from the repo root
3. **No linter or formatter** is configured — follow existing Tailwind class ordering and JS style
4. **Commit** with descriptive messages matching the existing style (e.g. `Refactor FPV training guide layout and style`)
5. **Push** to `main` (or the feature branch) — GitHub Pages deploys automatically

## Deployment

- Hosted via **GitHub Pages** on the `main` branch
- Custom domain configured in `CNAME`: `fpv.miguelppais.com`
- No build step required — changes are live after push

## Key Constraints

- **No npm / no build system** — do not introduce one unless explicitly requested
- **No TypeScript** — plain JavaScript only
- **No external CSS files** — all styling is Tailwind utility classes inline in the HTML
- **No separate JS files** — scripts are inline `<script>` blocks in each HTML file
- **Tailwind CDN defaults only** — no `tailwind.config.js`; custom values are avoided in favour of existing palette
- **License**: CC BY 4.0 — attribution required for reuse
