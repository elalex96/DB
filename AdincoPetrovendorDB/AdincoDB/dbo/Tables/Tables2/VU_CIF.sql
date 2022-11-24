CREATE TABLE [dbo].[VU_CIF] (
    [IdCIF]                INT           IDENTITY (1, 1) NOT NULL,
    [CIF]                  VARCHAR (20)  NULL,
    [RFC]                  VARCHAR (100) NULL,
    [RazonSocial]          VARCHAR (250) NULL,
    [Regimen]              VARCHAR (100) NULL,
    [FechaConstitucion]    DATE          NULL,
    [FechaOperaciones]     DATE          NULL,
    [Situacion]            VARCHAR (50)  NULL,
    [FechaUltimaSituacion] DATE          NULL,
    [EntidadFederativa]    VARCHAR (100) NULL,
    [Municipio]            VARCHAR (100) NULL,
    [Colonia]              VARCHAR (100) NULL,
    [Vialidad]             VARCHAR (100) NULL,
    [NombreVialidad]       VARCHAR (100) NULL,
    [NoExterior]           VARCHAR (50)  NULL,
    [NoInterior]           VARCHAR (50)  NULL,
    [CodigoPostal]         VARCHAR (50)  NULL,
    [CorreoElectronico]    VARCHAR (200) NULL,
    [RegimenFiscal]        VARCHAR (MAX) NULL,
    [FiscalAlta]           DATE          NULL,
    CONSTRAINT [PK_VU_CIF] PRIMARY KEY CLUSTERED ([IdCIF] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

