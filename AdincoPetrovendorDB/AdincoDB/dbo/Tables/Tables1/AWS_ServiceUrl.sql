CREATE TABLE [dbo].[AWS_ServiceUrl] (
    [IdServiceUrl] INT            IDENTITY (10000, 1) NOT NULL,
    [URL]          NVARCHAR (MAX) NULL,
    [CreadoPor]    INT            NULL,
    [CreadoEn]     DATETIME       NULL,
    CONSTRAINT [PK_AWS_ServiceUrl] PRIMARY KEY CLUSTERED ([IdServiceUrl] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

