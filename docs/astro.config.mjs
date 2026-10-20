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
      head: [
        {
          tag: 'script',
          content: `
            document.addEventListener('keydown', (event) => {
              if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
              if (event.key !== 'ArrowLeft' && event.key !== 'ArrowRight') return;
              const target = event.target;
              if (target instanceof HTMLElement && (target.isContentEditable || ['INPUT', 'TEXTAREA', 'SELECT'].includes(target.tagName))) return;
              if (document.querySelector('dialog[open], [role="dialog"][aria-modal="true"]')) return;
              const selection = window.getSelection();
              if (selection && selection.toString().length > 0) return;

              const path = window.location.pathname.replace(/\\/+$/, '') || '/';
              if (event.key === 'ArrowLeft') {
                const prev = document.querySelector('a[rel="prev"]');
                if (prev instanceof HTMLElement) {
                  prev.click();
                } else if (path === '/installation') {
                  window.location.href = '/';
                }
              } else if (event.key === 'ArrowRight') {
                const next = document.querySelector('a[rel="next"]');
                if (next instanceof HTMLElement) {
                  next.click();
                } else if (path === '/') {
                  const heroLink = document.querySelector('.hero .actions a.primary, .hero a[href]');
                  if (heroLink instanceof HTMLElement) {
                    heroLink.click();
                  } else {
                    window.location.href = '/installation/';
                  }
                }
              }
            });
          `,
        },
      ],
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
            { label: 'Adoption & Forking', slug: 'adoption' },
            { label: 'Post-Installation Setup', slug: 'post-installation' },
            { label: 'BIOS & Firmware', slug: 'bios-update' },
          ],
        },
        {
          label: 'Architecture & Hosts',
          items: [
            { label: 'Flake Architecture', slug: 'architecture' },
            { label: 'Split CI Architecture', slug: 'split-ci' },
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
