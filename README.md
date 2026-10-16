# RaceDay - Event Management System

**Author:** Seaney Maseko (ST10493031)
**Module:** Programming 2B (PROG6212)
**Parts Completed:** 1 (System Planning & Database) + 2 (RESTful API)
**Date:** October 2026

---

## 📖 Project Overview

South Africa has a rich road events culture — from the iconic Comrades Marathon to the Cape Town Cycle Tour and hundreds of community park runs. However, many of these events are still managed through paper-based registration, disconnected spreadsheets, and manual processes that overwhelm organisers and frustrate participants.

**RaceDay** is a full-stack web-based event management system designed specifically for the South African road running, walking, and cycling community. The platform allows **Organisers** to create and manage events, categories, and participant results, while **Participants** can browse upcoming events, enter events, and track their personal performance history.

This repository currently contains:

- **Part 1** — System planning: ERD, API endpoint plan, and SQL database schema.
- **Part 2** — A fully functional RESTful API built in C# using ASP.NET Core, with JWT authentication, role-based authorization, Entity Framework Core, Swagger documentation, and unit tests.

---

## 👥 User Roles

The system supports **two distinct user roles**, enforced at the API level through JWT claims and `[Authorize(Roles = "...")]` attributes.

### 🏁 Organiser
- Register and log in with an Organiser account.
- Create, edit, and delete events.
- Define age and distance categories for each event.
- View all participant enrolments for their own events.
- Capture and publish finish times, positions, and pace for participants.

### 🏃 Participant
- Register and log in with a Participant account.
- Browse all upcoming events (public endpoint).
- Enrol in events by selecting a category.
- View their own enrolment history.
- View their personal results (finish times, positions).
- Update their own profile information.

---

## 🏗️ Repository Structure

```
RaceDay.API/
├── .github/
│   └── workflows/
│       └── dotnet.yml              # CI/CD: builds and runs unit tests on every push
├── docs/                           # Part 1 planning documents
│   ├── ERD.png                     # Entity Relationship Diagram
│   ├── API_Endpoint_Plan.md        # Full RESTful API endpoint specification
│   ├── RaceDay_Schema.sql          # SQL Server database creation script
│   └── ci-screenshot.png           # Green build screenshot from GitHub Actions
├── RaceDay.API/                    # Main API project (Part 2)
│   ├── Controllers/                # AuthController, UsersController, EventsController,
│   │                               # CategoriesController, EnrolmentsController, ResultsController
│   ├── Models/                     # User, Event, Category, Participant, EventEnrolment, EventRoute, Result
│   ├── DTOs/                       # RegisterDto, LoginDto, EventDto, CategoryDto, EnrolmentDto, ResultDto, UpdateProfileDto
│   ├── Data/                       # RaceDayDbContext (EF Core)
│   ├── Migrations/                 # EF Core migrations
│   ├── appsettings.json            # Connection string + JWT configuration
│   └── Program.cs                  # App bootstrap: DI, JWT, Swagger, EF Core
├── RaceDay.API.Tests/              # Unit tests (Part 2)
│   ├── AuthTests.cs                # Register + login success/failure
│   ├── EventTests.cs               # Event management + role enforcement
│   ├── EnrolmentTests.cs           # Enrolment + role enforcement
│   ├── RoleAccessTests.cs          # Profile update + user lookup
│   ├── CustomWebApplicationFactory.cs
│   └── TestHelpers.cs
├── README.md                       # This file
└── RaceDay.API.sln                 # Solution file
```

---

## 🛠️ Setup Instructions

### Prerequisites
- **.NET 8 SDK** — [Download](https://dotnet.microsoft.com/download/dotnet/8.0)
- **SQL Server** — Express, LocalDB, or Full instance
- **Visual Studio 2022** (or VS Code with C# extension)
- **SQL Server Management Studio (SSMS)** — for viewing the database

---

### 🔧 Local Setup

**1. Clone the repository**

```bash
git clone https://github.com/Omph1l3/RaceDayDB.git
cd RaceDayDB
```

**2. Configure the connection string**

Open `RaceDay.API/appsettings.json` and update the `DefaultConnection` to point to your SQL Server instance:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=RaceDayDB;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True"
  },
  "Jwt": {
    "Key": "ThisIsAVeryLongSecretKeyForJwtSigningThatIsAtLeast32CharsLong!",
    "Issuer": "RaceDayAPI",
    "Audience": "RaceDayClient"
  }
}
```

> ⚠️ The `Jwt:Key` must be at least 32 characters long, or JWT signing will fail.

**3. Restore NuGet packages**

In Visual Studio, right-click the Solution → **Restore NuGet Packages**. Or via CLI:

```bash
dotnet restore
```

**4. Apply Entity Framework migrations**

In Package Manager Console (Tools → NuGet → Package Manager Console), set the **Default project** to `RaceDay.API`, then run:

```powershell
Update-Database
```

This creates the `RaceDayDB` database and seeds it with schema from your EF Core models.

**5. Run the API**

Press **F5** in Visual Studio. The API will start and listen on:

```
https://localhost:7122
```

**6. Open Swagger UI**

Navigate to:

```
https://localhost:7122/swagger
```

You'll see all endpoint groups (Auth, Users, Events, Categories, Enrolments, Results), plus an **Authorize** button at the top for JWT.

---

### 🔐 Testing the API — Quick Start

**1. Register users**

- `POST /api/Auth/register` → register an Organiser (`role = "Organiser"`) and a Participant (`role = "Participant"`).

**2. Log in to get tokens**

- `POST /api/Auth/login` → returns a JWT token.
- Copy the token, click **Authorize** in Swagger, and paste `Bearer <your_token>`.

**3. As Organiser**

- `POST /api/Events` → create an event.
- `POST /api/events/{eventId}/categories` → add a category.
- `POST /api/enrolments/{enrolmentId}/results` → capture a result.

**4. As Participant**

- `POST /api/categories/{categoryId}/enrolments` → enrol in an event.
- `GET /api/enrolments/me` → view personal enrolments.

**5. Public endpoints**

- `GET /api/Events` → list all events.
- `GET /api/events/{eventId}/results` → view the results board.

---

### 🧪 Running Unit Tests

The test project uses **xUnit** with an in-memory database via `WebApplicationFactory<Program>`.

**Run all tests from Visual Studio:**
- Open **Test → Test Explorer** → **Run All Tests**.

**Or from the CLI:**

```bash
dotnet test
```

**Expected result:**

```
Passed!  - Failed: 0, Passed: 12, Skipped: 0, Total: 12
```

**Test coverage:**

| Test Class | Tests | Covers |
|---|---|---|
| `AuthTests` | 4 | Register (success, duplicate), Login (success, wrong password) |
| `EventTests` | 4 | Create event (Organiser success, Participant blocked, unauthenticated blocked), Public list |
| `EnrolmentTests` | 2 | Enrolment (Participant success, Organiser blocked) |
| `RoleAccessTests` | 2 | Profile update, user lookup by role |

---

## ⚙️ Continuous Integration (CI/CD)

A **GitHub Actions workflow** (`.github/workflows/dotnet.yml`) runs on every push and pull request to `main`. It:

1. Checks out the repository.
2. Sets up .NET 8.
3. Restores dependencies.
4. Builds the solution in Release mode.
5. Runs all 12 unit tests.

### ✅ Green Build Status

![CI Build Status](docs/ci-screenshot.png)

> _The green checkmark above confirms that every push builds cleanly and all unit tests pass automatically._

---

## 🔒 Authentication & Security

- **Passwords** are hashed using **BCrypt** before being stored — plain-text passwords are never persisted.
- **JWT tokens** are issued on successful login and contain the user's `userId`, `email`, and `role` as claims.
- **Role-based authorization** is enforced via `[Authorize]` and `[Authorize(Roles = "Organiser")]` / `[Authorize(Roles = "Participant")]` attributes.
- **Ownership checks** ensure Organisers can only modify their own events and Participants can only withdraw their own enrolments.
- **HTTPS** is enforced via `app.UseHttpsRedirection()`.

---

## 📦 Technologies Used

| Layer | Technology |
|---|---|
| Language | C# (.NET 8) |
| Framework | ASP.NET Core Web API |
| ORM | Entity Framework Core 8 |
| Database | Microsoft SQL Server |
| Authentication | JWT Bearer (Microsoft.AspNetCore.Authentication.JwtBearer) |
| Password Hashing | BCrypt.Net-Next |
| API Documentation | Swagger / Swashbuckle |
| Testing | xUnit + WebApplicationFactory + EF Core InMemory |
| CI/CD | GitHub Actions |

---

## 📁 Part 1 — Planning Documents

All Part 1 documents are stored in the `/docs` folder:

1. **`ERD.png`** — Entity Relationship Diagram showing all 7 entities (Users, Events, Categories, Participants, EventEnrolments, EventRoutes, Results), primary keys, foreign keys, and cardinalities.
2. **`API_Endpoint_Plan.md`** — Full RESTful API endpoint specification covering Authentication, User Profile, Events, Categories, Enrolments, and Results.
3. **`RaceDay_Schema.sql`** — SQL Server script that creates the schema and seeds it with realistic sample data.

---

## 🎥 Video Presentation

A full walkthrough of the Part 2 API is available here:

---

## 📚 References

- Microsoft. (2026a). *CREATE TABLE (Transact-SQL)*. Microsoft Learn. Available at: https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql [Accessed 1 September 2026].
- Microsoft. (2026b). *Primary and foreign key constraints — SQL Server*. Microsoft Learn. Available at: https://learn.microsoft.com/en-us/sql/relational-databases/tables/primary-and-foreign-key-constraints [Accessed 1 September 2026].
- Microsoft. (2026c). *ASP.NET Core Web API documentation with Swagger / OpenAPI*. Microsoft Learn. Available at: https://learn.microsoft.com/en-us/aspnet/core/tutorials/web-api-help-pages-using-swagger [Accessed 10 October 2026].
- Microsoft. (2026d). *JWT bearer authentication in ASP.NET Core*. Microsoft Learn. Available at: https://learn.microsoft.com/en-us/aspnet/core/security/authentication/configure-jwt-bearer-authentication [Accessed 10 October 2026].
- Microsoft. (2026e). *Integration tests in ASP.NET Core*. Microsoft Learn. Available at: https://learn.microsoft.com/en-us/aspnet/core/test/integration-tests [Accessed 12 October 2026].
- Microsoft. (2026f). *Entity Framework Core documentation*. Microsoft Learn. Available at: https://learn.microsoft.com/en-us/ef/core/ [Accessed 12 October 2026].
- Lucid Software Inc. (2026). *Quick guide to different types of Entity Relationship Diagrams*. Lucidchart. Available at: https://www.lucidchart.com/pages/er-diagrams [Accessed 1 September 2026].
- GitHub. (2026). *Building and testing .NET*. GitHub Docs. Available at: https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-net [Accessed 15 October 2026].

---

## 📄 License

This project was created as part of the **IIE Programming 2B (PROG6212)** Portfolio of Evidence. All code is original work by the author unless otherwise referenced.
