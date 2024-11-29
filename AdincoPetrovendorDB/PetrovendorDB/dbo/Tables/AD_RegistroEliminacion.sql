CREATE TABLE [dbo].[AD_RegistroEliminacion] (
    [IdEliminacion]     INT            IDENTITY (1, 1) NOT NULL,
    [IdUsuario]         INT            NULL,
    [FechaRegistro]     DATETIME       NULL,
    [FechaModificacion] DATETIME       NULL,
    [ModificadoPor]     INT            NULL,
    [ComentarioExterno] NVARCHAR (MAX) NULL,
    [ComentarioInterno] NVARCHAR (MAX) NULL,
    [TipoEliminacion]   NVARCHAR (100) NULL,
    [Activo]            BIT            NULL,
    [IdProveedor]       INT            NULL,
    [IdContrato]        INT            NULL,
    [IdProceso]         INT            NULL,
    [Confirmacion]      BIT            NULL,
    [FechaRecuperacion] DATETIME       NULL,
    [RecuperadoPor]     INT            NULL,
    [ComentarioRecuperacion]            NVARCHAR(MAX)  NULL,
    [HistorialRecuperacion] NVARCHAR(MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdEliminacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

