CREATE TABLE [dbo].[MM_GiroSubcontratista] (
    [IdGiroSubcontratista] INT            IDENTITY (1, 1) NOT NULL,
    [Giro]                 NVARCHAR (MAX) NULL,
    [Creado]               DATE           NULL,
    [CreadoPor]            INT            NULL,
    CONSTRAINT [PK_GiroProveedor] PRIMARY KEY CLUSTERED ([IdGiroSubcontratista] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

