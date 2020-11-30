CREATE TABLE [dbo].[MA_OperacionDetalle] (
    [IdOperacionDetalle] INT            IDENTITY (1, 1) NOT NULL,
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
    [IdSubcontratista]   INT            NULL,
    PRIMARY KEY CLUSTERED ([IdOperacionDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

