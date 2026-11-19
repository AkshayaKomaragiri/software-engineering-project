# Rep Rank — UI Prototype

CS 3354 · Team 03 · Author: Anshika

A clickable prototype of the Rep Rank app screens. It's **UI only**: it uses sample workout data held in memory, so nothing is saved, and reloading the page resets everything. There's no database, no real login and no network calls.

## How to open it

- **On your computer:** double-click `index.html`. It opens in any browser, with no install needed.
- **From GitHub:** once GitHub Pages is turned on (see below), open `https://akshayakomaragiri.github.io/software-engineering-project/prototype/`.

On a laptop, it shows a phone frame. On the left is a list for jumping to any screen. On a phone, it fills the screen like an app.

## Screens and the requirements they show

| Screen | Use case / requirement |
|---|---|
| Sign in / Create account | UC-04, UC-05, FR-07, FR-08 (type the password `wrong` to see the error message) |
| Today + weekly goal | UC-01 step 0, UC-06, FR-05 |
| Choose exercise (search) | UC-01 steps 2–5, FR-10, A1 (no matches) |
| Record exercise | UC-01 steps 6–8, FR-01, FR-03, A2 (no previous record), A3 (field errors), A4 (save failure, there's a "simulate" link), A5 ("Record another") |
| Workout history + detail | UC-02, A1, A2 (sync warning after "simulate a failed sync") |
| Edit / delete an entry | Correcting a saved workout |
| Progress graph | UC-03, FR-04 (estimated 1RM = weight × (1 + reps ÷ 30), best set per day), CON-03 wording |
| Account | Sync status (UC-05), weekly goal, sign out |

## Colors

Charcoal ink (`#1C1F23`) on warm off-white (`#F5F4F0`), with white panels. There's one muted iron-oxide accent (`#9C3B26`), used only for the graph, best lifts and the selected tab. The status colors are muted: green `#2F6A4F`, ochre `#8A6417` and red `#A12A2A`.

## Turning on GitHub Pages (one time, after this is merged to main)

1. On GitHub, open the repo, then **Settings → Pages**.
2. Under **Source**, pick **Deploy from a branch**. Choose `main` and `/ (root)`, then click **Save**.
3. After about a minute, the prototype is live at the link above.
