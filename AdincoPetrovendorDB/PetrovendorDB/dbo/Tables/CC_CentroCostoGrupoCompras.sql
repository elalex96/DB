CREATE TABLE [dbo].[CC_CentroCostoGrupoCompras] (
    [IdCentroCostoGrupoCompras] INT      IDENTITY (1, 1) NOT NULL,
    [IdCentroCosto]             INT      NULL,
    [IdUsuario]                 INT      NULL,
    [Activo]                    BIT      NULL,
    [CreadoEl]                  DATETIME NULL,
    [CreadoPor]                 INT      NULL,
    [ModificadoEl]              DATETIME NULL,
    [ModificadoPor]             INT      NULL,
    [EliminadoPor]              INT      NULL,
    [EliminadoEl]               DATETIME NULL,
    [IdProveedor]               INT      NULL,
    [IsHistorico]               BIT      NULL,
    PRIMARY KEY CLUSTERED ([IdCentroCostoGrupoCompras] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

