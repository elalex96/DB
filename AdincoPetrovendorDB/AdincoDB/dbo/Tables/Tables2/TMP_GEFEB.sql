CREATE TABLE [dbo].[TMP_GEFEB] (
    [FACTURALUM]                          NVARCHAR (255) NULL,
    [FECHA FACTURA]                       DATE           NULL,
    [NOMBRE DEL PROVEEDOR]                NVARCHAR (255) NULL,
    [DESCRIPCION DE LA COMPRA O SERVICIO] NVARCHAR (255) NULL,
    [FACTURA]                             NVARCHAR (255) NULL,
    [FECHA FACTURA1]                      DATE           NULL,
    [PROVEEDOR]                           NVARCHAR (255) NULL,
    [USD]                                 FLOAT (53)     NULL,
    [MXN]                                 FLOAT (53)     NULL,
    [TOTAL GASTOS (markup)]               FLOAT (53)     NULL,
    [TOTAL GASTOS USD]                    FLOAT (53)     NULL,
    [IVA]                                 FLOAT (53)     NULL,
    [TOTAL]                               FLOAT (53)     NULL,
    [TIPO DE CAMBIO]                      FLOAT (53)     NULL,
    [CUENTA]                              NVARCHAR (255) NULL,
    [CONCEPTO BUDGET]                     NVARCHAR (255) NULL,
    [INSTALACION]                         NVARCHAR (255) NULL,
    [IdSubcontratista]                    INT            NULL,
    [IdFactura]                           INT            NULL
);

