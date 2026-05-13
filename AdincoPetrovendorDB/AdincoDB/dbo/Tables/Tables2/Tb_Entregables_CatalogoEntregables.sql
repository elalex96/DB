CREATE TABLE [dbo].[Tb_Entregables_CatalogoEntregables] (
    [IdEntregable]                INT            NOT NULL,
    [IdTipoContrato]              INT            NULL,
    [IdClausulaAnexo]             INT            NULL,
    [IdNumeralSeccion]            INT            NULL,
    [IdInciso]                    INT            NULL,
    [NombreEntregable]            NVARCHAR (MAX) NULL,
    [IdTipoDocumentoEntregable]   INT            NULL,
    [IdAreaResponsableEntregable] INT            NULL,
    [IdTipoEntregable]            INT            NULL,
    [TiempoEntrega]               NVARCHAR (MAX) NULL,
    [TeimpoRespuesta]             NVARCHAR (MAX) NULL,
    [Frecuencia]                  NVARCHAR (MAX) NULL,
    [IdEntidad]                   INT            NULL,
    [Observacion]                 NVARCHAR (MAX) NULL,
    [IdCriticidad]                INT            NULL
);

