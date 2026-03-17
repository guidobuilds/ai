---
name: expo-folder-structure
description: Implement Expo Router folder structure best practices from Expo guidance. Use when creating or reorganizing an Expo app to use src/app routes, screens, reusable components, colocated tests, platform-specific files, and separated API/server code.
---

# Expo Folder Structure Guide

Use this skill to implement a scalable Expo Router project structure and keep route files clean.

## Build the structure

1. Create this base tree under `src/`:
   - `app/` for Expo Router route files
   - `screens/` for route-level UI composition
   - `components/` for reusable UI
   - `utils/` and `hooks/` for shared logic
   - `server/` for server-only modules used by API routes
2. Keep `src/app` route files thin:
   - read params/navigation context
   - render a screen component
3. Put reusable UI in `src/components`:
   - use single file for simple components (`button.tsx`)
   - use folder + `index.tsx` when component has private subcomponents
4. Put page-specific composition in `src/screens`:
   - avoid large JSX trees directly in route files
5. Put API routes in `src/app/api` with `+api` suffix:
   - `src/app/api/user+api.ts`
   - import shared server logic from `src/server/*`
6. Use platform-specific files for major differences:
   - `bar-chart.tsx` (default)
   - `bar-chart.web.tsx` (web override)
7. Apply naming and colocation conventions:
   - prefer `kebab-case` filenames
   - keep styles in the component file by default
   - keep tests next to source: `file.ts` + `file.test.ts`

## Implement route-to-screen pattern

Use this pattern for every route:

```tsx
// src/app/index.tsx
import { HomeScreen } from "@screens/home";

export default function IndexRoute() {
  return <HomeScreen />;
}
```

```tsx
// src/screens/home/index.tsx
export function HomeScreen() {
  return null;
}
```

Keep route-specific concerns in `src/app/*` (params, redirects, route options), and keep UI composition in `src/screens/*`.

## Implement API and server separation

1. Create API route files only in `src/app/api`.
2. Move shared auth/db/business logic to `src/server`.
3. Import `src/server/*` into API route files.
4. Do not import `src/server/*` from client components.

## Final checks

1. Ensure imports still resolve (`@components`, `@screens`, etc.).
2. Update path aliases in `tsconfig.json` if needed.
3. Run project validation (typecheck, lint, tests).

## Reference

Read `references/expo-app-folder-structure-best-practices.md` for the full condensed rules and canonical tree from Expo's guidance.
