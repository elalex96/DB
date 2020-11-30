CREATE TABLE [dbo].[Notificacion] (
    [IdNotificacion]     INT            IDENTITY (1, 1) NOT NULL,
    [IdTipoNotificacion] INT            NULL,
    [IdTabla]            INT            NULL,
    [IdProveedor]        INT            NULL,
    [IdUsuario]          INT            NULL,
    [Cabecera]           NVARCHAR (MAX) NULL,
    [Descripcion]        NVARCHAR (MAX) NULL,
    [FechaRegistro]      DATETIME       NULL,
    [Activo]             BIT            NULL,
    [Eliminado]          BIT            NULL,
    [EliminadoEl]        DATETIME       NULL,
    [EliminadoPor]       INT            NULL,
    [ModificadoPor]      INT            NULL,
    [ModificadoEl]       DATETIME       NULL,
    [IdOperacion]        INT            NOT NULL,
    CONSTRAINT [PK_Notificacion] PRIMARY KEY CLUSTERED ([IdNotificacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [Notificacion_IdProveedor_Activo]
    ON [dbo].[Notificacion]([IdProveedor] ASC, [Activo] ASC)
    INCLUDE([FechaRegistro], [IdOperacion]) WITH (STATISTICS_NORECOMPUTE = ON);

