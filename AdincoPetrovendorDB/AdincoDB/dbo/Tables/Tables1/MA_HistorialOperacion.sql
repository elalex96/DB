CREATE TABLE [dbo].[MA_HistorialOperacion] (
    [IdHistorialOperacion] INT      IDENTITY (1, 1) NOT NULL,
    [IdOperacion]          INT      NULL,
    [IdDocumento]          INT      NULL,
    [IdLineaTiempo]        INT      NULL,
    [IdApp]                INT      NULL,
    [IdEstatusOperacion]   INT      NULL,
    [IdUsuarioRegistro]    INT      NULL,
    [FechaRegistro]        DATETIME NULL,
    [FechaModificacion]    DATETIME NULL,
    [ModificadoPor]        INT      NULL,
    PRIMARY KEY CLUSTERED ([IdHistorialOperacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

