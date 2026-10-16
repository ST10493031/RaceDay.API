# RaceDay.API
# RaceDay - Event Management System

**Author:** Seaney Maseko (ST10493031)  
**Module:** Programming 2B (PROG6212)  
**Part:** 1 - System Planning and Database  
**Date:** September 2026

---

## Project Overview

South Africa has a rich road events culture, from the iconic Comrades Marathon to the Cape Town Cycle Tour and hundreds of community park runs. However, many of these events are still managed through paper-based registration and disconnected spreadsheets.

**RaceDay** is a full-stack web-based event management system designed specifically for the South African road running, walking, and cycling community. This repository contains the **planning and database foundation** (Part 1) for the project, including the Entity Relationship Diagram (ERD), API endpoint specifications, and the SQL database schema.

---

##  User Roles

The system supports two distinct user roles, each with specific permissions:

###  Organiser
- Create, edit, and delete events.
- Define age and distance categories for events.
- View all participant enrolments for their events.
- Capture and publish finish times and finishing positions.

###  Participant
- Register and manage their personal profile.
- Browse upcoming events with filtering options.
- Enrol in events by selecting a relevant category.
- View their personal enrolment history and race results.

---

##  Repository Structure
RaceDayDB/
├── .github/
│ └── workflows/
│ └── validate.yml # CI/CD pipeline to validate Part 1 structure
├── docs/ # All planning documents (Part 1)
│ ├── ERD.png # Entity Relationship Diagram (PNG/PDF)
│ ├── API_Endpoint_Plan.md # Full RESTful API endpoint specification
│ └── RaceDay_Schema.sql # SQL Server database creation & seed script
├── README.md # This file
└── ...
---

## 🛠️ Setup Instructions (Part 1)

Since Part 1 focuses on planning and database design, the "setup" involves verifying the database script and reviewing the documentation.

**Prerequisites:**
- SQL Server Management Studio (SSMS) or Azure Data Studio.
- SQL Server (LocalDB, Express, or Full instance).

**Steps to run the Database Script:**

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/Omph1l3/RaceDayDB.git
    cd RaceDayDB

--   
##Key Documentation Highlights
1. Entity Relationship Diagram (ERD)
Located in /docs/ERD.png.

Contains 7 entities: Users, Roles, Events, Categories, EventCategories, Enrolments, and Results.

Clearly indicates Primary Keys, Foreign Keys, and cardinalities (One-to-Many, Many-to-Many).

2. API Endpoint Plan
Located in /docs/API_Endpoint_Plan.md.

Covers Authentication, User Profile, Events, Categories, Enrolments, and Results.

Specifies HTTP Methods, Routes, Descriptions, Required Roles, Request Bodies, and Expected Responses (including failure cases like 401 and 404).

3. SQL Database Script
Located in /docs/RaceDay_Schema.sql.


References
W3Schools. (2025). SQL Tutorial. Available at: https://www.w3schools.com/sql/ [Accessed 28 Aug. 2026].

Microsoft Learn. (2026). Azure DevOps documentation. Available at: https://learn.microsoft.com/en-us/azure/devops/ [Accessed 28 Aug. 2026].

Scrum Guides. (2025). Home | Scrum Guides. Available at: https://scrumguides.org/ [Accessed 28 Aug. 2026].

