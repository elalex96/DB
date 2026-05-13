CREATE TABLE [dbo].[MA_HistorialOperacionDetalle] (
    [IdOperacionDetalle] INT            NOT NULL,
    [IdAprobador]        INT            NULL,
    [IdLineaTiempo]      INT            NULL,
    [IdEstatus]          INT            NULL,
    [Comentario]         NVARCHAR (MAX) NULL,
    [FechaRegistro]      DATETIME       NULL,
    [FechaCambioEstatus] DATETIME       NULL,
    [Activo]             BIT            NULL,
    [NoSecuencia]        INT            NULL,
    [IdOperacion]        INT            NULL,
    [IsEliminado]        BIT            NULL,
    [IdFirma]            NVARCHAR (35)  NULL,
    [IdContrato]         INT            NULL,
    [IdSubcontratista]   INT            NULL
);

