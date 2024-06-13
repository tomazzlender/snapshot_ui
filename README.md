# SnapshotUI

## Things to do next

- Live reloads after a test run and new snapshots become published
- Accept not only "response" objects but also just plain strings for testing UI helpers (think buttons, etc.)
- Make it easier to navigate between a list of snapshots and the code
- Ability to disable or enable javascript of the rendered snapshots

## Things to do in the far future

- Different representations of snapshot lists
- Spatially display snapshots and how they connect to each other to demonstrate UI flows
- Extract more information out of response snapshots - path, page title, how they connect to other snapshots
- Possibility to add notes to snapshots from within tests (`take_snapshot response, note: "...")

