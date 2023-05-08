CREATE TABLE [dbo].[AspNetUsers] (
    [AccessFailedCount]    INT            NOT NULL,
    [Email]                NVARCHAR (256) NULL,
    [EmailConfirmed]       BIT            NOT NULL,
    [Id]                   NVARCHAR (128) NOT NULL,
    [LockoutEnabled]       BIT            NOT NULL,
    [LockoutEndDateUtc]    DATETIME       NULL,
    [PasswordHash]         NVARCHAR (MAX) NULL,
    [PhoneNumber]          NVARCHAR (MAX) NULL,
    [PhoneNumberConfirmed] BIT            NOT NULL,
    [SecurityStamp]        NVARCHAR (MAX) NULL,
    [TwoFactorEnabled]     BIT            NOT NULL,
    [UserName]             NVARCHAR (256) NOT NULL
);

