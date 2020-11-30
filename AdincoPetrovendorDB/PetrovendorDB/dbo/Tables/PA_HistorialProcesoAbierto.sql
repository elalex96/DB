CREATE TABLE [dbo].[PA_HistorialProcesoAbierto] (
    [IdHistorialProcesoAbierto] INT            IDENTITY (1, 1) NOT NULL,
    [IdUsuario]                 INT            NULL,
    [IdProveedor]               INT            NULL,
    [IdOperacion]               INT            NULL,
    [FechaRegistro]             DATETIME       NULL,
    [Descripcion]               NVARCHAR (MAX) NULL,
    [IdTabla]                   INT            NULL,
    [HistorialTipo]             INT            NULL,
    [Version]                   INT            NULL,
    CONSTRAINT [PK_PA_HistorialProcesoAbierto] PRIMARY KEY CLUSTERED ([IdHistorialProcesoAbierto] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

