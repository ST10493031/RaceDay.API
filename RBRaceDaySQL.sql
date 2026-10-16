-- Drop if exists (for clean testing)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'RaceDayDB')
BEGIN
    ALTER DATABASE RBRaceDay SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDay;
END
GO

CREATE DATABASE RBRaceDay;
GO

USE RBRaceDay;
GO


-- 1. Roles Table

CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(200) NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO


-- 2. Users Table

CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    RoleId INT NOT NULL,
    ProfilePictureUrl NVARCHAR(500) NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES Roles(RoleId),
    CONSTRAINT CHK_Users_Email CHECK (Email LIKE '%_@__%.__%')
);
GO


-- 3. EventType Table (NEW – matches ERD)

CREATE TABLE EventType (
    EventTypeId INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(20) NOT NULL UNIQUE CHECK (TypeName IN ('Run', 'Walk', 'Cycle')),
    Description NVARCHAR(200) NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO


-- 4. Events Table (now uses EventTypeId instead of column)

CREATE TABLE Events (
    EventId INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId INT NOT NULL,
    EventTypeId INT NOT NULL,                         -- changed
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    EventDate DATETIME NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    Distance DECIMAL(8,2) NOT NULL,
    BannerImageUrl NVARCHAR(500) NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Events_EventType FOREIGN KEY (EventTypeId) REFERENCES EventType(EventTypeId)
);
GO


-- 5. Categories Table

CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200) NULL,
    CategoryType NVARCHAR(20) NOT NULL CHECK (CategoryType IN ('Age', 'Distance')),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO


-- 6. EventCategories Junction (many-to-many)

CREATE TABLE EventCategories (
    EventCategoryId INT IDENTITY(1,1) PRIMARY KEY,
    EventId INT NOT NULL,
    CategoryId INT NOT NULL,
    CONSTRAINT FK_EventCategories_Events FOREIGN KEY (EventId) REFERENCES Events(EventId) ON DELETE CASCADE,
    CONSTRAINT FK_EventCategories_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId) ON DELETE CASCADE,
    CONSTRAINT UQ_EventCategories_EventCategory UNIQUE (EventId, CategoryId)
);
GO


-- 7. Enrolments Table

CREATE TABLE Enrolments (
    EnrolmentId INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId INT NOT NULL,
    EventId INT NOT NULL,
    CategoryId INT NOT NULL,
    EnrolmentDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending' 
        CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled', 'Completed')),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (ParticipantId) REFERENCES Users(UserId),
    CONSTRAINT FK_Enrolments_Events FOREIGN KEY (EventId) REFERENCES Events(EventId) ON DELETE CASCADE,
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT UQ_Enrolments_ParticipantEvent UNIQUE (ParticipantId, EventId)
);
GO


-- 8. Results Table (with Status column added)

CREATE TABLE Results (
    ResultId INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId INT NOT NULL,
    FinishTime TIME NOT NULL,
    FinishingPosition INT NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Finished' 
        CHECK (Status IN ('DNS', 'DNF', 'Finished')),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentId) REFERENCES Enrolments(EnrolmentId) ON DELETE CASCADE,
    CONSTRAINT UQ_Results_Enrolment UNIQUE (EnrolmentId)
);
GO


-- Indexes for performance

CREATE INDEX IX_Users_RoleId ON Users(RoleId);
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_Events_OrganiserId ON Events(OrganiserId);
CREATE INDEX IX_Events_EventDate ON Events(EventDate);
CREATE INDEX IX_EventCategories_EventId ON EventCategories(EventId);
CREATE INDEX IX_EventCategories_CategoryId ON EventCategories(CategoryId);
CREATE INDEX IX_Enrolments_ParticipantId ON Enrolments(ParticipantId);
CREATE INDEX IX_Enrolments_EventId ON Enrolments(EventId);
CREATE INDEX IX_Enrolments_CategoryId ON Enrolments(CategoryId);
CREATE INDEX IX_Enrolments_Status ON Enrolments(Status);
CREATE INDEX IX_Results_EnrolmentId ON Results(EnrolmentId);
GO


-- SEED DATA


-- 1. Roles
INSERT INTO Roles (RoleName, Description) VALUES
('Organiser', 'Event organiser who can create and manage events, categories, and results'),
('Participant', 'Event participant who can browse events, enrol, and view results');
GO

-- 2. Event Types
INSERT INTO EventType (TypeName, Description) VALUES
('Run', 'Road running events including marathons, half-marathons, and fun runs'),
('Walk', 'Walking events including park runs and charity walks'),
('Cycle', 'Cycling events including road races and time trials');
GO

-- 3. Users (passwords hashed – placeholders)
INSERT INTO Users (Email, PasswordHash, FirstName, LastName, RoleId, ProfilePictureUrl) VALUES
('thabo.mokoena@raceday.co.za', 'hashed_password_1', 'Thabo', 'Mokoena', 1, NULL),
('linda.zulu@raceday.co.za', 'hashed_password_2', 'Linda', 'Zulu', 1, NULL),
('sipho.ndlovu@gmail.com', 'hashed_password_3', 'Sipho', 'Ndlovu', 2, NULL),
('zanele.dlamini@gmail.com', 'hashed_password_4', 'Zanele', 'Dlamini', 2, NULL);
GO

-- 4. Categories
INSERT INTO Categories (Name, Description, CategoryType) VALUES
('Under 20', 'Participants aged under 20 years', 'Age'),
('Senior (20-39)', 'Participants aged 20 to 39 years', 'Age'),
('Master (40+)', 'Participants aged 40 years and over', 'Age'),
('10km', '10 kilometre distance category', 'Distance'),
('21km', '21.1 kilometre half-marathon category', 'Distance'),
('42km', '42.2 kilometre marathon category', 'Distance');
GO

-- 5. Events (now using EventTypeId)
INSERT INTO Events (OrganiserId, EventTypeId, Name, Description, EventDate, Location, Distance, BannerImageUrl) VALUES
(1, 1, 'Soweto Marathon', 'Annual Soweto Marathon through the streets of Soweto', '2026-09-15 06:00:00', 'Soweto, Johannesburg', 42.20, NULL),
(1, 3, 'Cape Town Cycle Tour', 'World-famous Cape Town Cycle Tour', '2026-10-20 07:00:00', 'Cape Town', 109.00, NULL),
(2, 1, 'Two Oceans Marathon', 'Ultra-marathon with stunning coastal views', '2026-11-05 05:30:00', 'Cape Town', 56.00, NULL);
GO

-- 6. Link Events to Categories
INSERT INTO EventCategories (EventId, CategoryId) VALUES
(1, 1), (1, 2), (1, 3), (1, 6),
(2, 1), (2, 2), (2, 3),
(3, 1), (3, 2), (3, 3), (3, 5);
GO

-- 7. Enrolments
INSERT INTO Enrolments (ParticipantId, EventId, CategoryId, Status) VALUES
(3, 1, 2, 'Confirmed'),
(3, 2, 1, 'Pending'),
(4, 1, 3, 'Confirmed'),
(4, 3, 2, 'Pending');
GO

-- 8. Results (now with Status)
INSERT INTO Results (EnrolmentId, FinishTime, FinishingPosition, Status) VALUES
(1, '03:45:12', 47, 'Finished'),
(3, '04:12:08', 89, 'Finished');
GO


-- Verification Queries

SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
GO

SELECT * FROM Roles;
SELECT * FROM EventType;
SELECT * FROM Users;
SELECT * FROM Categories;
SELECT * FROM Events;
SELECT * FROM EventCategories;
SELECT * FROM Enrolments;
SELECT * FROM Results;
GO