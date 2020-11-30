CREATE TABLE [dbo].[CO_RegistroTopen] (
    [IdRegistro]             INT             IDENTITY (1, 1) NOT NULL,
    [IdPrograma]             INT             NULL,
    [IdFactura]              INT             NULL,
    [MontoRegistro]          DECIMAL (18, 4) NULL,
    [InicioEjecucion]        DATE            NULL,
    [FinEjecucion]           DATE            NULL,
    [Comentarios]            NVARCHAR (MAX)  NULL,
    [MesPresentacion]        DATE            NULL,
    [IdEstado]               INT             NULL,
    [IdUsuarioCreadoPor]     INT             NULL,
    [IdUsuarioModPor]        INT             NULL,
    [FecMovto]               DATETIME        NULL,
    [IdInstalacion]          INT             NULL,
    [CreadoPor]              INT             NULL,
    [Fila]                   INT             NULL,
    [IdPedimentoComprobante] INT             NULL,
    [CvTipoDocFacturacion]   INT             NULL,
    [IdCatalogoCuentasSH]    INT             NULL,
    [Poliza]                 NVARCHAR (MAX)  NULL
);

