CREATE TABLE [dbo].[DB_Prefijo] (
    [IdPrefijo]   INT            IDENTITY (10000, 1) NOT NULL,
    [Prefijo]     NVARCHAR (MAX) NULL,
    [Descripción] NVARCHAR (MAX) NULL,
    [Activo]      BIT            NULL,
    CONSTRAINT [PK_DB_Prefijo] PRIMARY KEY CLUSTERED ([IdPrefijo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

