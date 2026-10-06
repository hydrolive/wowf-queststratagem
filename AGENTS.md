# Stratagem

The addon source is `Stratagem/`. Planning notes are `_spec/QuestStratagem/`. `Stratagem/MEMORY.md` is a copy of `_spec/QuestStratagem/MEMORY.md`.

## When you change the addon

After any change under `Stratagem/`:

1. Update the docs that describe that behavior. Keep the two `MEMORY.md` files the same. Update the spec file that owns the behavior (UI, routing, data, or phases) when the change touches it. Add a changelog line at the top of `Stratagem/Data/Forever/Overlay.lua`. Bump `## Version` in `Stratagem/Stratagem.toc` and `QS.VERSION` in `Core.lua` together. Leave `QS.DATA_VERSION` unchanged unless the quest data version itself changes. The footer string stays `Data classic-1.12 + forever-2026-10-05`.
2. Commit the addon, the docs, and the changelog together, and push to GitHub.
3. Deploy `Stratagem/` to `D:\WoW\World of Warcraft\_classic_beta_\Interface\AddOns\Stratagem`. Remove a leftover `QuestStratagem` folder in that AddOns directory. Confirm the copied files match the source.

Do not invent Forever quest ids. A quest id in the guide needs a public page. The addon stays offline: no HTTP, no Ask, no auto-accept.
