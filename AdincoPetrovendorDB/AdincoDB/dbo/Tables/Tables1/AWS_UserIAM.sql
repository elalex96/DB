CREATE TABLE [dbo].[AWS_UserIAM] (
    [IdIAM]           INT            IDENTITY (10000, 1) NOT NULL,
    [Nombre]          NVARCHAR (MAX) NULL,
    [AccessKey]       NVARCHAR (MAX) NULL,
    [SecretAccessKey] NVARCHAR (MAX) NULL,
    [IdContrato]      INT            NULL,
    [CreadoPor]       INT            NULL,
    [CreadoEn]        DATETIME       NULL,
    CONSTRAINT [PK_AWS_UserIAM] PRIMARY KEY CLUSTERED ([IdIAM] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

