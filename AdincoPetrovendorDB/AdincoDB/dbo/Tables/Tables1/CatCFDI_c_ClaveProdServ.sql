CREATE TABLE [dbo].[CatCFDI_c_ClaveProdServ] (
    [Idclave]               INT            IDENTITY (1, 1) NOT NULL,
    [c_ClaveProdServ]       NVARCHAR (MAX) NULL,
    [Descripcion]           NVARCHAR (MAX) NULL,
    [IncluirIVATrasladado]  NVARCHAR (MAX) NULL,
    [IncluirIEPSTrasladado] NVARCHAR (MAX) NULL,
    [FechaInicioVigencia]   DATE           NULL,
    [FechaFinVigencia]      DATE           NULL,
    [PalabrasSimilares]     NVARCHAR (MAX) NULL
);

