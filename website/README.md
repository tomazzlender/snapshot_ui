# Snapshot UI website

A dependency-free static homepage for Snapshot UI. It uses the real product screenshots from `gems/snapshot_ui-rails/docs/images` and has no build step or JavaScript.

The page uses a stacked-window mark, a warm color palette, and separate code-plus-output sections for mailers and integration responses.

From the repository root:

```sh
python3 -m http.server 4173
```

Then open `/website/` on that server.
