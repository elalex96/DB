CREATE TABLE [dbo].[TA_Estatus] (
    [IdEstatus] INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]    NVARCHAR (MAX) NULL,
    [Name]      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TA_Estatus] PRIMARY KEY CLUSTERED ([IdEstatus] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

