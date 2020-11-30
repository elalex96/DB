CREATE TABLE [dbo].[FI_FacturasContratosVolPre] (
    [IdFacContVolPre]       INT            IDENTITY (10000, 1) NOT NULL,
    [IdFactura]             INT            NULL,
    [IdContrato]            INT            NULL,
    [Mes]                   DATE           NULL,
    [IdDocFacturacionSIPAC] NVARCHAR (MAX) NULL,
    [ArchivoXML]            NVARCHAR (MAX) NULL,
    [CreadoPor]             INT            NULL,
    [CreadoEn]              DATETIME       NULL,
    [NumeroProcesado]       INT            NULL
);

