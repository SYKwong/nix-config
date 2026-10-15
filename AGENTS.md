# Repository Guidelines

## Documentation Site
- Documentation is maintained in-tree under `docs/` using Astro Starlight and deployed to `nix.kyle-kwong.com`.
- When adding or updating features, keep documentation in `docs/src/content/docs/` synchronized with the implementation.
- Only run `npx --no-install astro build` in `docs/` when adding, removing, or renaming documentation pages, or when modifying `docs/astro.config.mjs`, `docs/package.json`, or `docs/src/styles/` (skip the build for routine content edits to existing `.md` files). If `docs/node_modules/` is missing when a build is required, initialize it via `npm ci --ignore-scripts` in `docs/`.
- Maintain Catppuccin theme conventions and upright code typography.
