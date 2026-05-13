CREATE TABLE [dbo].[PC_PuntoVentaProducto] (
    [IdPuntoVentaProducto]     INT      IDENTITY (10000, 1) NOT NULL,
    [IdContrato]               INT      NULL,
    [Mes]                      DATE     NULL,
    [IdPtoExpedicionRecepcion] INT      NULL,
    [IdMaterialPC]             INT      NULL,
    [Aplica]                   BIT      NULL,
    [CreadoPor]                INT      NULL,
    [CreadoEn]                 DATETIME NULL,
    CONSTRAINT [PK_PC_PuntoVentaProducto] PRIMARY KEY CLUSTERED ([IdPuntoVentaProducto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PC_PuntoVentaProducto_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_PC_PuntoVentaProducto_PC_Material] FOREIGN KEY ([IdMaterialPC]) REFERENCES [dbo].[PC_Material] ([IdMaterialPC]),
    CONSTRAINT [FK_PC_PuntoVentaProducto_PC_PtoExpedicionRecepcion] FOREIGN KEY ([IdPtoExpedicionRecepcion]) REFERENCES [dbo].[PC_PtoExpedicionRecepcion] ([IdPtoExpedicionRecepcion])
);

