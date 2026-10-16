// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import mermaid from 'astro-mermaid';

// https://astro.build/config
export default defineConfig({
  site: 'https://nix.kyle-kwong.com',
  integrations: [
    mermaid({
      autoTheme: true,
    }),
    starlight({
      title: 'nix-config',
      description: 'Declarative NixOS & Home Manager Configuration Fleet',
      customCss: ['./src/styles/catppuccin.css', './src/styles/custom.css'],
      expressiveCode: {
        themes: ['catppuccin-mocha', 'catppuccin-latte'],
        styleOverrides: {
          borderRadius: '0.5rem',
          borderColor: 'var(--sl-color-hairline)',
          codeBackground: 'var(--sl-color-gray-6)',
          frames: {
            editorBackground: 'var(--sl-color-gray-6)',
            terminalBackground: 'var(--sl-color-gray-6)',
            editorActiveTabBackground: 'var(--sl-color-gray-6)',
            frameBoxShadowCssValue: 'none',
          },
        },
      },
      social: [
        {
          icon: 'gitlab',
          label: 'GitLab',
          href: 'https://gitlab.com/kylekwong/nix-config',
        },
      ],
      sidebar: [
        {
          label: 'Getting Started',
          items: [
            { label: 'System Installation', slug: 'installation' },
            { label: 'Post-Installation Setup', slug: 'post-installation' },
            { label: 'BIOS & Firmware', slug: 'bios-update' },
          ],
        },
        {
          label: 'Architecture & Hosts',
          items: [
            { label: 'Flake Architecture', slug: 'architecture' },
            { label: 'Host Configurations', slug: 'hosts' },
            { label: 'Home Manager', slug: 'home-manager' },
            { label: 'Out-of-Store Dotfiles', slug: 'dotfiles' },
          ],
        },
        {
          label: 'Modules & Extensibility',
          items: [
            { label: 'System Modules', slug: 'modules' },
            { label: 'Sunshine Streaming & Tablet Display', slug: 'sunshine' },
            { label: 'Gaming & Gamescope', slug: 'gaming' },
            { label: 'Declarative Flatpak', slug: 'flatpak' },
            { label: 'Custom Shell Scripts', slug: 'shell-scripts' },
            { label: 'Nixpkgs Overlays', slug: 'overlays' },
          ],
        },
        {
          label: 'Guides & Operations',
          items: [
            { label: 'Secrets Management', slug: 'secrets' },
            { label: 'Managing Desktop Entries', slug: 'desktop-entries' },
            { label: 'Code Quality & Evaluation', slug: 'code-quality' },
          ],
        },
      ],
    }),
  ],
});
