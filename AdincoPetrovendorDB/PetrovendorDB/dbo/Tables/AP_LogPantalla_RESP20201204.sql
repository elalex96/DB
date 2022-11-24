CREATE TABLE [dbo].[AP_LogPantalla_RESP20201204] (
    [IdLogPantalla]  INT            IDENTITY (1, 1) NOT NULL,
    [NombrePantalla] NVARCHAR (MAX) NULL,
    [IdUsuario]      INT            NULL,
    [IdContrato]     INT            NULL,
    [Fecha]          DATETIME       NULL,
    [CreadoPor]      INT            NULL,
    [CreadoEl]       DATETIME       NULL,
    [ModificadoPor]  INT            NULL,
    [ModificadoEl]   DATETIME       NULL,
    [Activo]         BIT            NULL
);

