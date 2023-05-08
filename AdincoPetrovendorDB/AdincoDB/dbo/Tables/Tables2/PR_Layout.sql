CREATE TABLE [dbo].[PR_Layout] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [NombreControl] VARCHAR (200)   NULL,
    [NombreLayout]  NVARCHAR (2000) NULL,
    [Layoutb]       VARBINARY (MAX) NULL,
    [Usuario]       VARCHAR (200)   NULL,
    [Fecha]         DATETIME        NULL,
    [Compartido]    TINYINT         NULL,
    CONSTRAINT [PK_PR_Layout] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

