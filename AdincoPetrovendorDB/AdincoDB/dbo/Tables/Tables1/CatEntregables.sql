CREATE TABLE [dbo].[CatEntregables] (
    [Regulador]                  NVARCHAR (MAX) NULL,
    [MarcoLegal]                 NVARCHAR (MAX) NULL,
    [FechaPublicacion]           DATETIME       NULL,
    [FechaUltimaModificación]    DATETIME       NULL,
    [TituloAnexoRonda]           NVARCHAR (MAX) NULL,
    [CapituloClausula]           NVARCHAR (MAX) NULL,
    [Seccion]                    NVARCHAR (MAX) NULL,
    [Articulo]                   NVARCHAR (MAX) NULL,
    [Apartado]                   NVARCHAR (MAX) NULL,
    [Fraccion]                   NVARCHAR (MAX) NULL,
    [Inciso]                     NVARCHAR (MAX) NULL,
    [Descripcion]                NVARCHAR (MAX) NULL,
    [Entregable]                 NTEXT          NULL,
    [Responsable Generador]      NVARCHAR (MAX) NULL,
    [EntidadReceptoraEntregable] NVARCHAR (MAX) NULL,
    [TiempoEntrega]              NVARCHAR (MAX) NULL,
    [TiempoRespuesta]            NVARCHAR (MAX) NULL,
    [Frecuencia]                 NVARCHAR (MAX) NULL,
    [Observaciones]              NVARCHAR (MAX) NULL
);

