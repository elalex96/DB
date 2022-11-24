CREATE TABLE [dbo].[FI_CFDIEmisor] (
    [IdEmisor]         INT            IDENTITY (1, 1) NOT NULL,
    [IdSubcontratista] INT            NULL,
    [RFC]              NVARCHAR (MAX) NULL,
    [RazonSocial]      NVARCHAR (MAX) NULL,
    [Calle]            NVARCHAR (MAX) NULL,
    [NoExt]            NVARCHAR (MAX) NULL,
    [NoInt]            NVARCHAR (MAX) NULL,
    [Colonia]          NVARCHAR (MAX) NULL,
    [Municipio]        NVARCHAR (MAX) NULL,
    [Estado]           NVARCHAR (MAX) NULL,
    [Pais]             NVARCHAR (MAX) NULL,
    [CodigoPostal]     NVARCHAR (MAX) NULL,
    [Regimen]          NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    CONSTRAINT [PK_Emisor] PRIMARY KEY CLUSTERED ([IdEmisor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_VU_Emisor_PV_Subcontratista] FOREIGN KEY ([IdSubcontratista]) REFERENCES [dbo].[PV_Subcontratista] ([IdSubcontratista])
);

