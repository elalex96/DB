CREATE TABLE [dbo].[Adinco_ServerMonitor] (
    [IdServerMonitor]         INT             IDENTITY (1, 1) NOT NULL,
    [NameDevice]              NVARCHAR (MAX)  NULL,
    [Date]                    DATETIME        NULL,
    [UnirLetter]              VARCHAR (10)    NULL,
    [VolumenLabel]            VARCHAR (1000)  NULL,
    [FileSystem]              VARCHAR (1000)  NULL,
    [AvaibleSpaceUserBytes]   FLOAT (53)      NULL,
    [TotalAvaibleSpaceBytes]  FLOAT (53)      NULL,
    [TotalSizeDriveBytes]     FLOAT (53)      NULL,
    [TotalRAMKilobyte]        FLOAT (53)      NULL,
    [FreePhysicalRAMkilobyte] FLOAT (53)      NULL,
    [TotalVirtualRAMKilobyte] FLOAT (53)      NULL,
    [FreeVirtualRAMKilobyte]  FLOAT (53)      NULL,
    [ModelCPU]                NVARCHAR (1000) NULL,
    [NumberDeviceCPU]         NVARCHAR (100)  NULL,
    [UsagePercentageCPU]      FLOAT (53)      NULL
);

