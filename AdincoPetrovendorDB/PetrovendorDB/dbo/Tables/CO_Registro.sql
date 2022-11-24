CREATE TABLE [dbo].[CO_Registro] (
    [IdRegistro]                      INT             IDENTITY (1, 1) NOT NULL,
    [IdPrograma]                      INT             NULL,
    [IdFactura]                       INT             NULL,
    [MontoRegistro]                   DECIMAL (18, 4) NULL,
    [InicioEjecucion]                 DATE            NULL,
    [FinEjecucion]                    DATE            NULL,
    [Comentarios]                     NVARCHAR (MAX)  NULL,
    [MesPresentacion]                 DATE            NULL,
    [IdEstado]                        INT             NULL,
    [IdUsuarioCreadoPor]              INT             NULL,
    [IdUsuarioModPor]                 INT             NULL,
    [FecMovto]                        DATETIME        NULL,
    [IdInstalacion]                   INT             NULL,
    [CreadoPor]                       INT             NULL,
    [Fila]                            INT             NULL,
    [IdPedimentoComprobante]          INT             NULL,
    [CvTipoDocFacturacion]            INT             NULL,
    [IdCatalogoCuentasSH]             INT             NULL,
    [Poliza]                          NVARCHAR (MAX)  NULL,
    [CentroCostos]                    INT             NULL,
    [CuentaContable]                  INT             NULL,
    [IdLineaPresupuestoMes]           INT             NULL,
    [CostosAtribuiblesAdministracion] BIT             NULL,
    [IdGastoRubro]                    TINYINT         NULL,
    [PCN]                             FLOAT (53)      NULL,
    [IdCBSISH]                        INT             NULL,
    [IdAceptacionPedidoDetalle]       INT             NULL,
    CONSTRAINT [PK_Registros] PRIMARY KEY CLUSTERED ([IdRegistro] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [CO_Registro_IdFactura]
    ON [dbo].[CO_Registro]([IdFactura] ASC)
    INCLUDE([IdLineaPresupuestoMes]) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

