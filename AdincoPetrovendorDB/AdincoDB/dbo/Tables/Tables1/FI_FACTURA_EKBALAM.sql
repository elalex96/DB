CREATE TABLE [dbo].[FI_FACTURA_EKBALAM] (
    [IdFactura]             INT            IDENTITY (10000, 1) NOT NULL,
    [UUID]                  NVARCHAR (MAX) NULL,
    [IdContrato]            INT            NULL,
    [ArchivoXML]            NVARCHAR (MAX) NULL,
    [IdDocFacturacionSIPAC] NVARCHAR (50)  NULL
);

