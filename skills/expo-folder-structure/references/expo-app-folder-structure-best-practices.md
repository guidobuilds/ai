# Expo App Folder Structure Best Practices (Condensed)

Source: https://expo.dev/blog/expo-app-folder-structure-best-practices

## Core recommendations

1. Prefer `src/app` over root `app`
- Keep app code under `src/` to separate it from config and tooling files.
- Expo Router supports both `app/` and `src/app/`.

2. Keep reusable UI in `src/components`
- Every file in `app` becomes a route; avoid placing reusable components there.
- Use either:
  - single-file components (`button.tsx`), or
  - folder components with `index.tsx` and internal colocated files.

3. Use `src/screens` for complex route UI
- Keep route files in `src/app` as thin wrappers.
- Move page-specific UI composition into screen components.
- Pattern:
  - `src/app/index.tsx` imports and renders `@screens/home`.

4. Keep shared helpers in `src/utils` and `src/hooks`
- Put standalone utilities and reusable hooks in dedicated folders.

5. Separate API and server logic
- API route files use `+api` suffix and can live in `src/app`.
- Prefer grouping them under `src/app/api` to avoid route collisions and improve clarity.
- Move shared server-only code to `src/server`.
- Server code can access sensitive `process.env.*`; frontend code should use `EXPO_PUBLIC_*` for inlined values.

6. Use platform-specific file suffixes for major divergence
- Supported suffixes: `.web`, `.native`, `.ios`, `.android`.
- Always keep a default implementation (no suffix).
- Keep component props consistent across platform variants.

7. Colocate styles with component code
- Prefer styles at the bottom of the component file rather than separate `*.styles.*` files unless separation is justified.

8. Colocate unit tests
- Keep tests next to source files, e.g. `format-date.ts` + `format-date.test.ts`.

9. Naming convention
- Use one naming scheme consistently.
- Updated Expo recommendation: prefer `kebab-case` filenames.

## Canonical scalable tree

```text
├── assets/
├── scripts/
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   ├── event+api.ts
│   │   │   └── user+api.ts
│   │   ├── _layout.tsx
│   │   ├── _layout.web.tsx
│   │   ├── index.tsx
│   │   ├── events.tsx
│   │   └── settings.tsx
│   ├── components/
│   │   ├── table/
│   │   │   ├── cell.tsx
│   │   │   └── index.tsx
│   │   ├── bar-chart.tsx
│   │   ├── bar-chart.web.tsx
│   │   └── button.tsx
│   ├── screens/
│   │   ├── home/
│   │   │   ├── card.tsx
│   │   │   └── index.tsx
│   │   ├── events.tsx
│   │   └── settings.tsx
│   ├── server/
│   │   ├── auth.ts
│   │   └── db.ts
│   ├── utils/
│   │   ├── format-date.ts
│   │   ├── format-date.test.ts
│   │   └── pluralize.ts
│   └── hooks/
│       ├── use-app-state.ts
│       └── use-theme.ts
├── app.json
├── eas.json
└── package.json
```
