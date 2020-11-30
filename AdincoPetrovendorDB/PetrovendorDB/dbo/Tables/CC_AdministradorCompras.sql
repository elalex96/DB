CREATE TABLE [dbo].[CC_AdministradorCompras] (
    [IdAdministradorCompras] INT      IDENTITY (1, 1) NOT NULL,
    [IdUsuario]              INT      NULL,
    [Activo]                 BIT      NULL,
    [CreadoEl]               DATETIME NULL,
    [CreadoPor]              INT      NULL,
    [ModificadoEl]           DATETIME NULL,
    [ModificadoPor]          INT      NULL,
    [EliminadoPor]           INT      NULL,
    [EliminadoEl]            DATETIME NULL,
    [IdProveedor]            INT      NULL,
    [IsHistorico]            BIT      NULL,
    PRIMARY KEY CLUSTERED ([IdAdministradorCompras] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

