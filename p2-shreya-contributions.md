# Rep Rank — P2 Individual Contributions

**Contributor:** Shreya Singaravel Sabapathi  
**Course:** CS 3354.003 — Software Engineering  
**Milestone:** P2 — Analysis and High-Level Design  
**Sections contributed:** 6.2, 7.1 (ADR-01 through ADR-04), and 7.2

## 6.2 Architectural Style and Alternatives

| Style considered | Drivers it serves | What it costs | Verdict |
|---|---|---|---|
| A layered mobile architecture with local SQLite storage and a client-server connection to Supabase | This supports workout logging and retrieval of previously saved workout records (UC-01, UC-02), cross-device access to workout history (UC-05), and separation of responsibilities for maintainability (QR-03). The local SQLite storage allows users to access their saved workout records offline, and Supabase provides authentication and cloud synchronization. | It requires additional development and maintenance of cloud synchronization, resolving conflicts when records are changed on multiple devices, and ensuring separation between application layers. | **Chosen** |
| Cloud-only thin-client architecture | This architecture supports centralized data management, user authentication, and cross-device access (UC-05). It also simplifies maintaining workout records consistently in a single cloud database. | It requires internet connectivity for workout logging and retrieval. Network interruptions can prevent users from accessing their records, and the responsiveness of the application depends on cloud service availability and network latency. | **Rejected** |
| Traditional three-tier architecture with custom backend/API server | It supports a clear separation between the user interface, application logic, and data management (QR-03), which improves maintainability. It also provides control over user authentication, workout data processing, and communication between system components. | It requires the team to develop, deploy, secure, monitor, and maintain a custom backend server. This increases implementation effort, infrastructure costs, and operational responsibilities beyond the team's initial project scope. | **Rejected** |

The team chose the layered mobile-client architecture because it supports recording and retrieving workouts (UC-01 and UC-02), cross-device access (UC-05), and maintainability through separation of responsibilities (QR-03). A local SQLite store makes previously saved records accessible without continuous internet access, while Supabase supports authentication and synchronization. The team accepts the additional complexity of keeping local and cloud records consistent in exchange for offline availability and reduced dependence on network connectivity for basic workout tracking. This choice also works within the team's decision not to develop its own cloud infrastructure.

## 7 Design Rationale

### 7.1 Architecture Decision Records

#### ADR-01: Selection of Overall Architectural Style

| Field | Content |
|---|---|
| **Status** | Proposed — pending team approval |
| **Date and owner** | November 7, 2026 — Shreya Singaravel Sabapathi |
| **Context (drivers)** | Rep Rank requires reliable workout logging (UC-01), retrieval of previously recorded workouts (UC-02), and access to workout records across devices (UC-05). The architecture must also support maintainability (QR-03), cross-platform compatibility (CON-01), and protection of user information (CON-02). |
| **Options considered** | **Option 1:** Layered mobile-client architecture with local SQLite storage and Supabase cloud services. **Option 2:** Cloud-only thin-client architecture with centralized storage. **Option 3:** Traditional three-tier architecture with a custom backend/API server. |
| **Decision** | Adopt a layered mobile-client architecture using SQLite for local workout storage and Supabase for authentication and cloud synchronization. The mobile application will separate its user interface functionality, application logic, and data management responsibilities into distinct layers. |
| **Consequences** | This architecture supports local access to workout records, cross-device synchronization, and maintainability through separation of responsibilities. However, it introduces additional complexity in maintaining local and cloud data consistency, resolving synchronization conflicts, and coordinating communication between application layers. |
| **Evidence** | The P1 Flutter and SQLite prototype in `dev/spike/flutter_sqlite_demo` provides preliminary implementation evidence for the proposed mobile and local-storage approach. Its actual test results should be cited before final approval. |
| **Related** | ADR-02, ADR-03, ADR-04; UC-01, UC-02, UC-05; QR-03; CON-01, CON-02. |

#### ADR-02: Local-First Storage vs. Cloud-Only Storage

| Field | Content |
|---|---|
| **Status** | Proposed — pending team approval |
| **Date and owner** | November 8, 2026 — Shreya Singaravel Sabapathi |
| **Context (drivers)** | Rep Rank requires users to record workout information (UC-01), retrieve previously saved workout records (UC-02), and access workout history across multiple devices (UC-05). The application must support reliable workout tracking even when network connectivity is not available. The storage architecture must also protect confidential personal workout records (CON-02). |
| **Options considered** | **Option 1:** Local-first architecture using SQLite for on-device storage with synchronization to Supabase. **Option 2:** Cloud-only architecture that stores and retrieves workout records directly from Supabase without a persistent local workout database. |
| **Decision** | Adopt a local-first storage approach using SQLite to store workout records directly on the user's device. When network connectivity is present, workout information will be synchronized with Supabase to support backup and cross-device access. |
| **Consequences** | This approach improves offline availability by allowing users to record and retrieve locally stored workout information without continuous internet connectivity. However, it introduces additional development complexity involving synchronization failures, conflicting updates across multiple devices, and maintaining consistency between local and cloud databases. |
| **Evidence** | The P1 Flutter and SQLite prototype in `dev/spike/flutter_sqlite_demo` provides preliminary implementation evidence for a local-storage approach. Cloud synchronization and conflict handling require additional validation through the P2 architecture spike (S-01). |
| **Related** | ADR-01, ADR-03; UC-01, UC-02, UC-05; FR-01, FR-02, FR-09; CON-02; R6. |

#### ADR-03: Selection of Backend Service Provider

| Field | Content |
|---|---|
| **Status** | Proposed — pending team approval |
| **Date and owner** | November 8, 2026 — Shreya Singaravel Sabapathi |
| **Context (drivers)** | Rep Rank requires secure user authentication (FR-07, FR-08), storage of account-specific workout records, and synchronization of workout history across devices (FR-09). The team has limited development resources and does not intend to build and maintain its own authentication and cloud storage infrastructure, as established in Section 1.2. The selected service must also support the application's security and privacy requirements (QR-01, CON-02). |
| **Options considered** | **Option 1 — Supabase:** Provides managed PostgreSQL database services, authentication, and APIs for application integration. **Option 2 — Firebase:** Provides managed authentication and cloud database services through Google's backend platform, with a different data modeling approach. **Option 3 — Custom Backend Server:** Develop and maintain a separate backend API, database infrastructure, and authentication functionality. |
| **Decision** | Select Supabase as the backend service provider for user authentication, cloud database storage, and synchronization of workout records. Its PostgreSQL database supports the application's structured workout records, and its authentication services reduce the need to develop custom account management infrastructure. |
| **Consequences** | Supabase reduces backend development and infrastructure maintenance responsibilities. It also supports authentication and centralized data storage. However, the application depends on Supabase's service availability, pricing, supported features, and security configuration. The team remains responsible for configuring access controls and integrating a secure service within the mobile application. |
| **Evidence** | The project's scope in Section 1.2 establishes the use of third-party authentication and cloud storage. Supabase's service and pricing documentation [R10] supports the provider evaluation. The team's P2 architecture spike (S-01) is intended to validate synchronization and access control before implementation proceeds. |
| **Related** | ADR-01, ADR-02; UC-05; FR-07, FR-08, FR-09; QR-01; CON-02; R2, R7, R8. |

#### ADR-04: Selection of Cross-Platform Development Framework

| Field | Content |
|---|---|
| **Status** | Proposed — pending team approval |
| **Date and owner** | November 8, 2026 — Shreya Singaravel Sabapathi |
| **Context (drivers)** | Rep Rank must support both iOS and Android operating systems (CON-01). The development team requires support for consistent application functionality, manageable maintenance, and efficient implementation across both platforms. The selected framework must also support integration with local SQLite storage and third-party authentication and database services. |
| **Options considered** | **Option 1 — Flutter:** A cross-platform development framework using Dart that supports building iOS and Android applications from a shared codebase. **Option 2 — React Native:** A cross-platform framework using JavaScript or TypeScript that also supports shared mobile development. **Option 3 — Native Development:** Develop separate iOS and Android applications using platform-specific technologies such as Swift and Kotlin. |
| **Decision** | Select Flutter as the mobile development framework for Rep Rank. A shared Flutter codebase will be used to develop the iOS and Android applications, supporting consistent functionality and reducing duplication of development effort. |
| **Consequences** | Flutter supports cross-platform compatibility and maintainability by allowing the development team to implement most application functionality within a single codebase. However, platform-specific adjustments, additional testing, and native integrations may still be necessary. The team must also maintain compatibility with the selected SQLite and Supabase integration packages. |
| **Evidence** | The P1 Flutter and SQLite prototype provides preliminary evidence for integrating Flutter with local workout storage. The decision also supports the cross-platform requirement defined in CON-01. Further validation is needed to confirm application behavior on both supported operating systems. |
| **Related** | ADR-01, ADR-02, ADR-03; CON-01; QR-02, QR-03; R4. |

### 7.2 Trade-off Summary

| Quality favored | Architectural move | Cost accepted | Recorded in |
|---|---|---|---|
| Maintainability and modularity | Adopt a layered mobile-client architecture that separates the user interface, application logic, and data management responsibilities. | Requires additional coordination between application layers and clearly defined interfaces, increasing initial design and integration effort. | ADR-01 |
| Offline availability and reliability | Implement local-first SQLite storage for workout records, with synchronization to Supabase when network connectivity is available. | Introduces additional complexity in synchronizing local and cloud records, handling synchronization failures, and resolving conflicting updates across devices. | ADR-02 |
| Security and development efficiency | Use Supabase for third-party authentication and cloud database management instead of developing and maintaining a custom backend server. | Creates a dependency on Supabase's availability, service limitations, pricing, and security configuration, reducing direct control over backend infrastructure. | ADR-03 |
| Cross-platform compatibility and maintenance | Use Flutter to develop a shared mobile application codebase for iOS and Android. | May require platform-specific adjustments, additional testing, and integration work to ensure consistent functionality across both operating systems. | ADR-04 |
