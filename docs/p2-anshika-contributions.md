# P2 Contributions - Anshika

Author: Anshika

## Section 4.1 Use cases selected for analysis (revised from Laxmi's draft)

<img width="502" height="234" alt="image" src="https://github.com/user-attachments/assets/2142a758-9595-4535-90fb-ba48e601e2f3" />


### Changes and reasons

1. **Removed technology from "Why selected" and "Non-trivial steps".** The draft named Supabase, Row Level Security, JWT sessions, relational tables and server-side database functions. Section 4 is analysis with the technology switched off: the P2 rubric awards full marks only for use cases with "no technology", and the template's Lesson 13 rules reject database and framework names. Technology decisions belong in sections 6 and 7.
2. **Replaced the "Non-trivial steps" column with step numbers from 4.2.** The template defines non-trivial steps as the steps in 4.2 that need objects inside the system.
**Restored the P1 use-case names.**
**Gave UC-02 a reason based on user evidence.**

## Section 4.2 Expanded use cases (revised from Laxmi's drafts)
### UC-01 Record Workout Session
<img width="500" height="470" alt="image" src="https://github.com/user-attachments/assets/54cc94e7-79d0-461b-9476-33d9b23efddd" />

<img width="497" height="332" alt="image" src="https://github.com/user-attachments/assets/3558845a-c638-4df2-ac63-712f3f7ccad0" />

### UC-05 Access Workout Records Across Devices
<img width="505" height="381" alt="image" src="https://github.com/user-attachments/assets/15d4fa49-6fd2-4f80-ae2f-0cdee45e0d45" />
<img width="506" height="311" alt="image" src="https://github.com/user-attachments/assets/fe4f9159-5d29-4738-8ec1-16b46f7ef34a" />


### UC-02 Review Workout History
<img width="500" height="219" alt="image" src="https://github.com/user-attachments/assets/c158a140-bcab-4ccb-8fb1-4d5b3dd3cbd0" />

<img width="508" height="405" alt="image" src="https://github.com/user-attachments/assets/2f69c21c-026c-46ba-9553-d92439f50e83" />


### Changes and reasons (4.2)

**UC-01**
- Added step (0) and numbered all rows as required by the rubric.
- Split "search and select"; merged "enter" and "save": one turn per row.
- Removed cloud saving; supporting actors set to None: background work and technology don't belong in analysis.
- Replaced "search bar" as a screen widget is technology.
- Filled traces (FR-01, FR-02, FR-03, FR-10)

**UC-05**
- Added step (0); removed the "opens the app" row: that row is the trigger (TUCBW).
- Expanded step (4) with verification and retrieval: the user waits for both, and 5.2 needs them.
- Moved "network access" from preconditions to A4: it can be false during normal use.
- Added A3, A5, A6 and traces QR-01, CON-02

**UC-02**
- Removed "has saved records" from preconditions: it contradicted A1.
- TUCBW reduced to one action; supporting actors set to None: the user is already signed in.
- Removed "home screen interface" and "cached locally": technology.
- Step (2) now shows the list: every system turn must be visible to the user.
- Traces changed to FR-02, FR-08: matches the P1 matrix.

### Changes and reasons (4.3)
- New section: the rubric requires a self-review log of what each Lesson 13 check found and fixed.
- Lists actor-column items for the domain model so cross-check K1 can run.

## Section 10.3 Risks (updated)

<img width="499" height="320" alt="image" src="https://github.com/user-attachments/assets/b4509c4a-0812-409d-922c-4281cacee03e" />
<img width="497" height="314" alt="image" src="https://github.com/user-attachments/assets/cfad149a-a911-4661-873e-d0addab767e6" />


## Section 10.4 Repository

<img width="524" height="363" alt="image" src="https://github.com/user-attachments/assets/d56a7758-b330-4770-9dc7-eb2d0b4b50c3" />


## Section 0.2 
<img width="521" height="484" alt="image" src="https://github.com/user-attachments/assets/1d5a23ff-ddbb-4ed9-bf8b-adac5dce32f2" />
