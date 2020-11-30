CREATE TABLE [dbo].[DEA_UsuariosNotificar] (
    [IdUsuarioNotificar] INT            IDENTITY (1, 1) NOT NULL,
    [IdUsuario]          INT            NULL,
    [CreadoPor]          INT            NULL,
    [CreadoEl]           DATETIME       NULL,
    [EditadoEl]          DATETIME       NULL,
    [EditadoPor]         INT            NULL,
    [EliminadoEl]        DATETIME       NULL,
    [EliminadoPor]       INT            NULL,
    [Activo]             BIT            NULL,
    [IsEliminado]        BIT            NULL,
    [TipoNotificacion]   NVARCHAR (100) NULL,
    [IdProveedor]        INT            NULL,
    [IdCentroCosto]      INT            NULL,
    [IsHistorico]        BIT            NULL
);

