CREATE TABLE [dbo].[TA_NoNotificacion] (
    [IdNotificacion]      INT      IDENTITY (1, 1) NOT NULL,
    [IdUsuario]           INT      NULL,
    [IdProveedor]         INT      NULL,
    [IdCorreo]            INT      NULL,
    [FechaModificacion]   DATETIME NULL,
    [IdUsuarioModificado] INT      NULL,
    [FechaCreacion]       DATETIME NULL,
    [UsuarioCreador]      INT      NULL,
    [IsEliminado]         BIT      NULL,
    PRIMARY KEY CLUSTERED ([IdNotificacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

