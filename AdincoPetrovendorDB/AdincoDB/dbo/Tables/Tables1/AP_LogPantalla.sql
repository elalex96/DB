CREATE TABLE [dbo].[AP_LogPantalla] (
    [IdLogPantalla]  INT            IDENTITY (1, 1) NOT NULL,
    [NombrePantalla] NVARCHAR (MAX) NULL,
    [IdUsuario]      INT            NULL,
    [IdContrato]     INT            NULL,
    [Fecha]          DATETIME       NULL,
    [CreadoPor]      INT            NULL,
    [CreadoEl]       DATETIME       NULL,
    [ModificadoPor]  INT            NULL,
    [ModificadoEl]   DATETIME       NULL,
    [Activo]         BIT            NULL,
    CONSTRAINT [PK_AP_LogPantalla] PRIMARY KEY CLUSTERED ([IdLogPantalla] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

