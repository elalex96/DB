CREATE TABLE [dbo].[CO_SAPProformaDocumentos] (
    [IdDocumento]     INT            NOT NULL,
    [IdSAPProforma]   INT            NULL,
    [IdTipoDocumento] INT            NULL,
    [NombreDoc]       VARCHAR (100)  NULL,
    [Carpeta]         NVARCHAR (600) NULL,
    [Identificador]   NVARCHAR (600) NULL,
    [Extension]       NVARCHAR (600) NULL,
    [Mime]            NVARCHAR (600) NULL,
    [Activo]          BIT            NULL,
    [CreadoPor]       INT            NULL,
    [CreadoEl]        DATETIME       NULL,
    [ModificadoPor]   DATETIME       NULL,
    [ModificadoEl]    INT            NULL,
    PRIMARY KEY CLUSTERED ([IdDocumento] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_IdSAPProforma] FOREIGN KEY ([IdSAPProforma]) REFERENCES [dbo].[CO_SAPProforma] ([IdSAPProforma])
);

