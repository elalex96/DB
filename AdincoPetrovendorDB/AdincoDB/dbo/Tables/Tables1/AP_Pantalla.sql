CREATE TABLE [dbo].[AP_Pantalla] (
    [IdPantalla]     INT            IDENTITY (10000, 1) NOT NULL,
    [NombrePantalla] NVARCHAR (MAX) NULL,
    [Activo]         BIT            NULL,
    CONSTRAINT [PK_AP_Pantalla] PRIMARY KEY CLUSTERED ([IdPantalla] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

