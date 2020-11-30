CREATE TABLE [dbo].[PV_FormatoDeSolicitudCuentaBancaria] (
    [IdFormatoAprobacion] INT            IDENTITY (1, 1) NOT NULL,
    [Documento]           NVARCHAR (MAX) NULL,
    [FechaRegistro]       DATETIME       NULL,
    [NombreArchivo]       VARCHAR (100)  NULL,
    CONSTRAINT [PK_PV_FormatoDeSolicitudCuentaBancaria] PRIMARY KEY CLUSTERED ([IdFormatoAprobacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

