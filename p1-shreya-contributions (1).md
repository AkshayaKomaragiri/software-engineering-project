# P1 Contribution Evidence — Shreya Singaravel Sabapathi

**Project:** Rep Rank — CS 3354.003, Team 3  
**Deliverable:** P1 Proposal and Requirements  
**Sections contributed:** 1.4 (References, revised); 2.2 (Stakeholders and how you reached them); 2.4 (Constraints); 2.5 (Assumptions and dependencies)

This file preserves the content of my contributed sections from the team’s P1 document dated October 18, 2026.

## 1.4 References

[R1] Federal Trade Commission, “Mobile Health Apps Interactive Tool.” [Online]. Available: https://www.ftc.gov/business-guidance/resources/mobile-health-apps-interactive-tool. [Accessed: Oct. 16, 2026].

[R2] StatCounter GlobalStats, “Mobile Operating System Market Share in the United States.” [Online]. Available: https://gs.statcounter.com/os-market-share/mobile/united-states-of-america. [Accessed: Oct. 16, 2026].

[R3] OWASP Foundation, “Password Storage Cheat Sheet,” OWASP Cheat Sheet Series. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html. [Accessed: Oct. 16, 2026].

[R4] International Organization for Standardization and International Electrotechnical Commission, Systems and software engineering—Systems and software Quality Requirements and Evaluation (SQuaRE)—Product quality model, ISO/IEC 25010:2023, 2023. [Online]. Available: https://www.iso.org/standard/78176.html. [Accessed: Oct. 16, 2026].

[R5] T. J. McCabe, “A complexity measure,” IEEE Transactions on Software Engineering, vol. SE-2, no. 4, pp. 308–320, Dec. 1976, doi: 10.1109/TSE.1976.233837. [Online]. Available: https://doi.org/10.1109/TSE.1976.233837. [Accessed: Oct. 16, 2026].

[R6] World Wide Web Consortium (W3C), “Web Content Accessibility Guidelines (WCAG) 2.2, Success Criterion 1.3.4: Orientation.” [Online]. Available: https://www.w3.org/TR/WCAG22/#orientation. [Accessed: Oct. 16, 2026].

[R7] World Wide Web Consortium (W3C), “Web Content Accessibility Guidelines (WCAG) 2.2, Success Criterion 2.5.8: Target Size (Minimum).” [Online]. Available: https://www.w3.org/TR/WCAG22/#target-size-minimum. [Accessed: Oct. 16, 2026].

[R8] Federal Trade Commission, “Federal Trade Commission Act.” [Online]. Available: https://www.ftc.gov/legal-library/browse/statutes/federal-trade-commission-act. [Accessed: Oct. 16, 2026].

[R9] Centers for Disease Control and Prevention, “Adding Physical Activity as an Adult,” Dec. 4, 2025. [Online]. Available: https://www.cdc.gov/physical-activity-basics/adding-adults/. [Accessed: Oct. 17, 2026].

[R10] Supabase, “Pricing.” [Online]. Available: https://supabase.com/pricing. [Accessed: Oct. 18, 2026].

[R11] Intuit Mailchimp, “Transactional Email Pricing.” [Online]. Available: https://mailchimp.com/pricing/transactional-email/. [Accessed: Oct. 18, 2026].

## 2.2 Stakeholders and how you reached them

| Stakeholder | Role in relation to the system | What they need from it | How you learned this |
| --- | --- | --- | --- |
| Strength Training Users | Primary Users of Rep Rank | They need a convenient way to record their exercises, review previous workout sessions, and monitor changes in their exercise performance over time. | This is an assumption based on personal gym experiences and observations. No formal interviews were documented in this process. |
| Development Team | System designers, developers, and maintenance teams. | They require clearly defined requirements, manageable development scope, and maintainable application. | This was identified through the team’s project planning and discussions regarding development responsibilities. |
| Third-party cloud and authentication providers | External services used for account authentication and data storage. | They require compatible integration, correct usage of services, and compliance with service requirements. | This was identified from the decision to outsource authentication and cloud storage in Section 1.2. No formal provider consultation documented. |
| App distribution platforms | External stakeholders responsible for hosting and distributing the application. | They require applications to meet the applicable platform requirements for installation and documentation. | This is an assumption based on the decision to support iOS and Android users. The specific platform requirements have not yet been formally reviewed. |
| Federal Trade Commission and relevant privacy authorities | Regulatory stakeholders are responsible for enforcing consumer protection and privacy requirements. | They require protection of user data privacy and truthful representation of the application’s purpose and its capabilities. | This was identified through reviewing the FTC Mobile Health App Interactive Tool and Federal Trade Commission Act [R1, R8]. |

## 2.4 Constraints

Rep Rank’s design and development are subject to the following constraints.

**Platform Requirements:** The application must support iOS and Android operating systems. These platforms were specifically selected because they represent the majority of the Unites States mobile operating system market. Development and compatibility support for other operating systems are excluded from the initial release [R2].

**Privacy and data handling:** The application must protect any personal and fitness related information collected from users, including workout records and profile information. Personal workout information must not be publicly disclosed without appropriate user authorization except where disclosure is required by applicable law. This constraint limits how the workout records and personal information may be accessed, stored, or shared with third parties [R1].

**Truthful health-related claims:** Rep Rank must not make any false, misleading or unsupported claims regarding improvements in the users’ physical health, strength or fitness. The application is intended for workout tracking and progress visualization rather than medical diagnosis or treatment. This constraint restricts the claims that may appear in the application’s interface or promotional materials [R8].

**External service integration:** Based on the team’s defined project scope and resource limitations, account authorization and cloud storage will rely on third party services rather than the infrastructure developed and operated by the team. This constraint rules out developing custom authentication and cloud storage infrastructure for the initial release (Section 1.2).

## 2.5 Assumptions and dependencies

| # | Assumption or dependency | What breaks if it does not hold |
| --- | --- | --- |
| A1 | The selected third-party database and authentication providers are assumed to maintain appropriate security measures to protect user data against unauthorized access and data loss. | It results in user’s personal information and workout records being exposed, compromised, or lost, undermining privacy and user trust in the application. |
| A2 | The selected cloud service provider is assumed to maintain sufficient service availability, data integrity, and backup capabilities to support the applications' intended usage. | The users may not be able to save, retrieve, or synchronize workout records reliably across application sessions and devices. |
| A3 | The targeted audiences are assumed to have access to a compatible iOS or Android device and possess familiarity with navigating mobile applications. Knowledge of specific exercise terminology is not assumed. | The prospective users without compatible devices or basic mobile navigation skills may struggle to access the application or use its workout tracking features effectively. |
| A4 | The users are assumed to accurately record their workout performance, including the weights lifted and number of sets and repetitions completed. | Incorrect or inconsistent workout entries may result in inaccurate workout histories and misleading progress graphs, reducing the reliability of the application’s progress tracking functionality. |
| A5 | A sufficiently comprehensive and usable exercise dataset is assumed to be available for the application’s exercise search functionality. | The users may be unable to find exercises they perform, preventing the application from fully supporting its intended workout logging functionality. |
| A6 | The selected third-party authentication and cloud services are assumed to provide necessary APIs or SDKs compatible with the application’s iOS and Android development framework. | Account creation, authentication and workout synchronization may require a different service provider or changes to the application architecture, potentially delaying development. |
