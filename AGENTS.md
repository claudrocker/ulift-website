# Repository Guidelines

## Project Structure & Module Organization

This is a static Astro 6 site for URBANLIFT. Route files live in `src/pages/`; Astro maps each `.astro` filename directly to a URL. Shared UI belongs in `src/components/`, with plan-specific components under `src/components/plans/`. Use `src/layouts/Layout.astro` for page-level structure, `src/data/coaches/` for typed coach content, and `src/styles/global.css` for Tailwind theme tokens and shared utilities. Place files that must be served unchanged in `public/`. The HTML files in `docs/source/` are design and content references, not application code. Generated `dist/` and `.astro/` content should not be edited manually.

## Build, Test, and Development Commands

- `npm install`: install dependencies; use Node.js 22.12 or newer.
- `npm run dev`: start Astro’s development server, normally at `http://localhost:4321`.
- `npm run build`: create the production site in `dist/`; run this before opening a PR.
- `npm run preview`: serve the latest production build locally.
- `docker build -t urbanlift-website .`: build the production Nginx image.
- `docker compose up -d`: run the container using the configured Dokploy network.

## Coding Style & Naming Conventions

Use two-space indentation, single quotes in TypeScript/frontmatter, and semicolons for imports and declarations. Keep TypeScript compatible with the strict configuration in `tsconfig.json`. Name Astro components in PascalCase (`CoachModal.astro`), routes in lowercase kebab-case (`nuestro-espacio.astro`), and data modules descriptively in kebab-case. Prefer reusable components and existing Tailwind theme classes over duplicated markup or new one-off CSS. Keep user-facing copy in Chilean Spanish and prices in CLP.

## Testing Guidelines

No automated test framework or coverage threshold is currently configured. Treat `npm run build` as the required validation check. For UI changes, also use `npm run preview` and manually verify affected routes at mobile and desktop widths, including navigation, modal behavior, external links, and image loading. If tests are introduced, colocate them near the feature and add the corresponding command to `package.json`.

## Commit & Pull Request Guidelines

Recent commits use short Spanish summaries describing the completed change, for example `cambios en footer y informacion`. Keep commits focused and use an imperative, specific subject. Pull requests should explain the user-visible result, list affected routes, and report build/manual checks. Include before-and-after screenshots for visual changes and link the relevant issue when one exists. Never commit secrets, local environment files, or generated build output.
