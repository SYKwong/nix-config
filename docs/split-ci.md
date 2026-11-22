---
title: Split CI Architecture
description: Architectural rationale, reliability benefits, and implementation of the dual-forge (GitLab + GitHub) CI/CD model.
---

This document details the architectural and operational motivations behind the **split CI architecture** employed by `nix-config`.

The single biggest driving factor behind this design is **reliability and merge availability**: GitHub Actions experiences frequent service degradations and outages. When branch protections require GitHub Action checks to pass before merging, any GitHub Actions incident brings development to a grinding halt—blocking emergency system fixes, host configurations, and routine maintenance.

By decoupling **system evaluation, fleet maintenance, and merge gatekeeping** onto GitLab CI, merges are never blocked by GitHub downtime. GitHub Actions is relegated strictly to non-critical installer ISO builds and triggering/running the `SYKwong/nix-docs` deployment to Cloudflare.

---

## 1. High-Level Architecture

The repository enforces a strict unidirectional flow where GitLab serves as the canonical source of truth and GitHub operates purely as a read-only mirror and documentation builder:

```mermaid
flowchart LR
    dev["Local Workstation<br/><code>git push origin</code>"] --> gitlab["GitLab Repository<br/><b>Canonical Source of Truth</b>"]

    subgraph gitlab_ci ["GitLab CI/CD (Merge Gatekeeper)"]
        gitlab --> test["verify-flake<br/>(nixos/nix:latest container)"]
        gitlab --> lock_bot["update-flake-mr<br/>(scheduled flake update bot)"]
        gitlab --> stable_tag["create-weekly-stable<br/>(tag rotation bot)"]
        gitlab --> notify_docs["notify-docs<br/>(repository_dispatch to nix-docs)"]
    end

    gitlab -- "Unidirectional Push Mirror<br/>(Fine-Grained PAT)" --> github["GitHub Repository<br/><b>Read-Only Mirror</b>"]

    subgraph github_actions ["GitHub Actions (Artifacts & Unified Docs)"]
        notify_docs -. "docs-updated" .-> nix_docs["SYKwong/nix-docs<br/>(Astro Starlight + Cloudflare)"]
        github -- "Schedule / push / dispatch" --> build_iso["build-iso.yml<br/>(Custom Installer ISO)"]
    end
```

---

## 2. Core Motivations & Rationale

### A. Merge Availability & Uptime: Escaping GitHub Actions Outages

In a declarative multi-host NixOS fleet, rapid deployment and unblocked iteration are essential. When an urgent hardware fix or configuration tweak needs to be deployed, developers cannot afford to be blocked by CI downtime.

On GitHub, repository branch protections typically require CI status checks to pass before merging a pull request. However, GitHub Actions frequently suffers from:

- Runner queue stalls and degraded performance during peak hours.
- Infrastructure-wide Actions outages where jobs fail to schedule or complete.
- Webhook delivery delays and API degradation.

When GitHub Actions is down, pull requests are frozen in an unmergeable state. In contrast, GitLab CI offers significantly higher uptime and reliable job execution. By using GitLab CI as the authoritative gatekeeper for Merge Requests:

- **Zero Merge Blockers**: Code can always be evaluated, validated, and merged into `main` without waiting on GitHub infrastructure.
- **Fail-Safe Docs Deployment**: Documentation builds are hosted separately in `SYKwong/nix-docs` (triggered by `notify-docs` in `.gitlab-ci.yml`). If GitHub Actions goes down, it only temporarily delays static documentation deployment—core fleet evaluation, merges, and system rebuilds remain 100% operational. The documentation build simply catches up whenever GitHub recovers.

### B. Containerized Determinism & Pure Nix Isolation

GitLab CI jobs execute directly inside pristine, official OCI container images:

- **`nixos/nix:latest`**: Runs `nix fmt` verification, `nix flake check`, and automated `flake.lock` update MRs in an unadulterated Nix environment.
- **`alpine:latest` & `curlimages/curl:latest`**: Run lightweight weekly `stable-*` tag rotation and `notify-docs` webhook dispatches without pulling heavy VM toolchains.

In contrast to cloud VM runners that execute multi-step setup scripts on shared host environments, GitLab CI spins up fresh container instances for each job. Combined with GitLab's `FF_USE_FASTZIP` caching (`.cache/nix` keyed on `flake.lock`), builds remain completely reproducible, isolated, and fast.

Private flake inputs (such as private wallpapers) enclosed within `# BEGIN_PRIVATE_WALLPAPERS` and `# END_PRIVATE_WALLPAPERS` block markers are temporarily commented out prior to running `nix flake check` and `build-iso.yml`. This mirrors `install-nixos` bootstrap behavior, allowing unauthenticated CI runners to validate formatting, NixOS system closures, and installer images without requiring ambient SSH keys or deploy tokens.

### C. Eliminating GitHub Actions Supply-Chain & Deprecation Churn

Standard Nix continuous integration workflows on GitHub Actions typically rely on a deep chain of third-party composite actions (such as `actions/checkout`, `determinate-nix-action`, `cachix/install-nix-action`, or `magic-nix-cache`). While convenient, this model introduces distinct maintenance liabilities:

1. **Supply-Chain Attack Surface**: Composite actions run arbitrary JavaScript and third-party binary installers with ambient runner access.
2. **Node Runtime Deprecation Churn**: GitHub Actions periodically deprecates Node runtime versions (Node 12 &rarr; Node 16 &rarr; Node 20 &rarr; Node 22). Workflows and pinned composite action tags must be continuously audited and bumped across repositories to avoid runner deprecation failures.
3. **Marketplace Outages & Rate Limits**: Relying on external action repositories subjects core flake evaluation to GitHub Marketplace outages, action repository deletions, and runner API rate limits.

On GitLab CI, jobs execute standard POSIX shell scripts directly inside official container images. There are **zero external JavaScript action dependencies**, completely eliminating runtime deprecation cycles and third-party supply-chain vectors for core fleet validation.

### D. Native Bot Automation via Git Push Options

Automating `flake.lock` updates and weekly release tags is a critical maintenance task for a rolling NixOS fleet. On GitHub, running automated update bots typically requires:

- Personal Access Tokens (PATs) with expansive repo permissions to bypass branch protections.
- Third-party bots or GitHub Apps (e.g. Renovate, Dependabot).
- Complex workflow files orchestrating pull request creation and auto-merge approvals.

GitLab CI natively eliminates this complexity through **Git Push Options** and built-in **`CI_JOB_TOKEN`** credentials:

```bash
# Push update branch and automatically generate a configured Merge Request
git push -f origin "$BRANCH_NAME" \
  -o merge_request.create \
  -o merge_request.target="$CI_DEFAULT_BRANCH" \
  -o merge_request.title="chore(flake): update flake.lock ($(date +%Y-%m-%d))" \
  -o merge_request.description="The following flake inputs were updated:\n$SUMMARY" \
  -o merge_request.remove_source_branch \
  -o merge_request.label="dependencies" \
  -o merge_request.assignee_id="$GITLAB_USER_ID" \
  -o merge_request.squash=true
```

Using pure `git push` options:

- No personal access token is stored or exposed in CI environment variables.
- The pipeline authenticates using GitLab's short-lived, job-scoped `CI_JOB_TOKEN`.
- The Merge Request is created with the exact `nix flake update` summary and assigned to the repository owner. Automatic rebasing onto `main`, full system closure build verification, deduplicated common and per-device `dix` package diff summaries in the MR description, failure reporting (`build-error` label and log comment), and automatic merge are handled safely by `flake-update-verifier` on the local desktop workstation (`mini-pc-k8`) during off-peak hours (or interactively via `nverify`), ensuring broken upstream `nixpkgs` revisions never touch `main`. Similarly, `update-wallpaper` (`nwall`) utilizes native push options (`-o merge_request.create`, `-o merge_request.auto_merge`) to submit auto-merging lockfile bumps that bypass CI execution (`when: manual` + `allow_failure: true` rule in `.gitlab-ci.yml`) because they are verified locally via `nrs`.
- Tag rotation (`create-weekly-stable`) tags the commit and purges tags older than 12 weeks using native git commands in an Alpine container.
- Docs dispatch (`notify-docs`) triggers a `repository_dispatch` (`docs-updated`) on `SYKwong/nix-docs` when `docs/**` changes on `main` (requires the masked `GITHUB_DOCS_TOKEN` CI/CD variable). `SYKwong/nix-docs` also runs a scheduled fallback watcher that pulls the latest `docs/` from `nix-config` (`main`), commits any synced changes into its own repository, and deploys to Cloudflare (`cloudflare/wrangler-action`).

### E. Multi-Repo Aggregation & Global Edge CDN (`nix-docs` + Cloudflare)

Delegating documentation aggregation and Starlight builds to GitHub Actions on `SYKwong/nix-docs`—while serving the built site on Cloudflare Workers Static Assets (`cloudflare/wrangler-action`)—plays to each platform's strengths:

- **Unlimited Free Runner Minutes**: Because `SYKwong/nix-docs` is a public repository, GitHub Actions provides unlimited free runner minutes for hourly sync checks, `npm ci`, and `astro build`, preserving GitLab Free CI/CD minutes strictly for `nix-config` flake validation and update bots.
- **Cross-Forge Multi-Repo Aggregation**: Native Cloudflare Git integration can only watch pushes on a single repository. Running the sync in GitHub Actions allows `nix-docs` to pull Markdown from both GitLab (`kylekwong/nix-config`) and GitHub (`SYKwong/flake-templates`), commit synced changes into `nix-docs`, and deploy the unified `dist/` artifact.
- **Cloudflare Edge Delivery**: Cloudflare Workers Static Assets serves `nix.kyle-kwong.com` over a global Anycast edge network with unlimited static bandwidth, automated TLS, and custom `404-page` routing without GitHub Pages' 100 GB/month bandwidth cap.

Restricting GitHub Actions in this repository to [`.github/workflows/build-iso.yml`](https://gitlab.com/kylekwong/nix-config/-/blob/main/.github/workflows/build-iso.yml) (and delegating Astro Starlight site builds to `SYKwong/nix-docs`) confines GitHub runner execution strictly to non-critical static site generation and automated installer ISO artifact releases.

### F. Blast Radius Containment & Defense-in-Depth

The split architecture strictly contains operational blast radiuses:

- **Outage Immunity**: If GitHub experiences an outage, degraded runner queues, or service disruption, core NixOS fleet maintenance, MR validation, local machine rebuilds, and flake updates continue without interruption on GitLab.
- **Documentation Build Isolation**: If an Astro dependency or Starlight build failure occurs in GitHub Actions, it has zero impact on NixOS system builds or merge pipelines on GitLab.
- **Least-Privilege Token Scoping**: The GitLab push mirror authenticates to GitHub using a **fine-grained personal access token** scoped exclusively to `Contents: Read and write` on the `nix-config` mirror repository. If the mirror token were ever compromised, it grants zero access to other repositories, user profile settings, or organization assets.

---

## 3. Comparison Matrix: GitLab CI vs. GitHub Actions

| Evaluation Vector              | GitLab CI (Fleet Validation & Merges)                             | GitHub Actions (Docs & Artifact Releases)                                                           |
| :----------------------------- | :---------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------- |
| **Outage Impact on Merges**    | **Zero Impact**: Highly reliable runners; merges proceed normally | **Zero Impact**: Outages only delay wiki CDN updates or installer ISO releases; never blocks merges |
| **Primary Responsibility**     | `nix flake check`, `nix fmt`, lock updates, release tags          | Building & publishing Astro Starlight wiki to Pages and releasing custom installer ISOs             |
| **Execution Model**            | Native OCI containers (`nixos/nix`, `alpine`, `curlimages/curl`)  | Shared Ubuntu VM runners (`ubuntu-latest`)                                                          |
| **Dependency Model**           | Raw bash scripts inside container images                          | Composite actions (`actions/checkout`, `withastro/action`)                                          |
| **Action Churn**               | None (no external marketplace actions)                            | Periodic Node runtime upgrades & action bumps                                                       |
| **Automated MR / PR Creation** | Native Git Push Options via `CI_JOB_TOKEN`                        | Requires Personal Access Token or GitHub App                                                        |
| **State / Authority**          | Canonical source of truth (read/write)                            | Downstream mirror (strictly read-only)                                                              |

---

## 4. Repository Synchronization & Operational Hygiene

To maintain stability across both forges, follow these operational rules:

### 1. Single Authoritative Remote

All development branches, pull/merge requests, and commits must be pushed directly to GitLab:

```bash
git remote set-url origin git@gitlab.com:<username>/nix-config.git
```

### 2. Unidirectional Push Mirroring

GitLab's repository mirroring feature automatically pushes all branch updates and tags to GitHub over HTTPS using the fine-grained PAT. Never push directly to GitHub; doing so causes divergent git histories and breaks automatic mirroring.

### 3. Read-Only Mirror Banner

Mark the GitHub repository description as a read-only mirror pointing back to your GitLab canonical repository:

```text
[Read-Only Mirror] Primary development on GitLab: https://gitlab.com/<username>/nix-config
```

### 4. GitHub Actions Repository Permissions

To allow the automated installer ISO release workflow ([`.github/workflows/build-iso.yml`](https://gitlab.com/kylekwong/nix-config/-/blob/main/.github/workflows/build-iso.yml)) to compile and publish releases on the GitHub mirror or fork:

- **Actions Execution Policy**: In GitHub repository **Settings** → **Actions** → **General** → **Actions permissions**, select **"Allow select actions and reusable workflows"**, check **"Allow actions created by GitHub"**, and configure the explicit pattern allowlist:
  ```text
  cachix/*,
  softprops/*,
  ```
- **Workflow Permissions**: Under **Workflow permissions**, select **Read and write permissions** (required for publishing releases, creating versioned tags, and uploading release binaries via `softprops/action-gh-release`) and check **Allow GitHub Actions to create and approve pull requests**.
- **Fork Enablement**: If the downstream repository is a fork, navigate to the **Actions** tab and click **"I understand my workflows, go ahead and enable them"** (Actions are disabled by default on newly created forks).

---

## 5. Wiki Hosting Platforms

This repository's unified wiki (`SYKwong/nix-docs`) deploys to **Cloudflare** (Workers / Pages), providing global Anycast edge caching and unlimited static bandwidth. Adopters can also connect `nix-docs` directly to **Cloudflare Pages** via native Git integration (eliminating GitHub Actions for docs builds), or host on **GitLab Pages** / **GitHub Pages**.

```mermaid
flowchart TD
    gitlab["GitLab Primary Repository"] --> cf["Cloudflare Pages<br/>(Direct Webhook / Edge Build)"]
    gitlab --> pages["GitLab Pages<br/>(In-tree CI Runner Job)"]
    gitlab --> gh_mirror["GitHub Mirror (PAT)"] --> gha["SYKwong/nix-docs<br/>(GitHub Actions)"] --> cf_workers["Cloudflare Workers / Pages"]
```

### Platform Comparison

| Platform                         | Git Source                            | Build Trigger                                                          | Bandwidth / Limits                         | Key Benefits                                                                                |
| :------------------------------- | :------------------------------------ | :--------------------------------------------------------------------- | :----------------------------------------- | :------------------------------------------------------------------------------------------ |
| **Cloudflare (Workers / Pages)** | GitLab or GitHub (`SYKwong/nix-docs`) | `repository_dispatch` + scheduled sync watcher (or native Git webhook) | Unlimited static bandwidth                 | Global Anycast edge, zero GitHub Pages bandwidth caps, works out-of-the-box with `nix-docs` |
| **GitLab Pages**                 | GitLab                                | `.gitlab-ci.yml` `pages` job                                           | Bound to GitLab CI pipeline minutes        | Fully self-contained within GitLab; requires no third-party accounts or external webhooks   |
| **GitHub Pages**                 | GitHub                                | GitHub Actions (`actions/deploy-pages`)                                | 100 GB/mo; subject to Action runner health | Native GitHub hosting without external cloud accounts                                       |

---

### Recommended Setup: Native Cloudflare Pages (Zero GitHub Actions)

For adopters who want to connect their `nix-docs` Starlight repository directly to Cloudflare Pages without using GitHub Actions runners for static site builds:

#### Build Configuration Settings (in `nix-docs`):

- **Framework preset**: `Astro`
- **Build command**: `npm run build`
- **Build output directory**: `dist`
- **Environment variables**:
  - `NODE_VERSION`: `22`

> [!TIP]
> Because `SYKwong/nix-docs` commits synced documentation directly into its repository tree, connecting Cloudflare Pages to `nix-docs` works out of the box with zero custom multi-repo fetch scripts.

---

## 6. Adopting or Modifying the CI Model

If you are adopting or forking this repository, choose the deployment and CI topology that best matches your workflow:

1. **Split CI (GitLab Primary + `nix-docs` on Cloudflare)**:
   Keep the default architecture documented in this guide. Follow the token generation and push-mirroring instructions in [Adoption: Reproducing Split CI](/nix-config/adoption/#6-continuous-integration--the-split-ci-architecture).

2. **GitLab Primary + Cloudflare Pages (Recommended Modern Alternative)**:
   Connect your documentation repository directly to Cloudflare Pages with the build settings listed above. This eliminates GitHub Actions runner dependencies for docs while preserving GitLab CI's rock-solid merge gatekeeping.

3. **Consolidate on GitLab (GitLab CI + GitLab Pages)**:
   Delete `.github/` and add a `pages` job to `.gitlab-ci.yml` to build and serve the wiki directly through GitLab Pages.

4. **Consolidate on GitHub (GitHub Actions Only)**:
   Delete `.gitlab-ci.yml`, set up `determinate-nix-action` for pull request checks, and deploy to GitHub Pages. Be aware that GitHub Actions outages can block pull request merges under branch protection rules.

See the [Adoption & Forking Guide](/nix-config/adoption/#alternatives-edge-hosting--single-forge-workflows) for step-by-step instructions and sample configurations.
