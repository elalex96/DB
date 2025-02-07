CREATE TABLE [dbo].[SC_Materiales] (
    [IdSCMaterial]          INT             NOT NULL,
    [IdSubContrato]         INT             NOT NULL,
    [Concepto]              VARCHAR (MAX)   NOT NULL,
    [IdMaestro]             INT             NULL,
    [IdUnidad]              INT             NULL,
    [Cantidad]              DECIMAL (14, 5) NULL,
    [PrecioUnitario]        MONEY           NOT NULL,
    [Importe]               MONEY           NOT NULL,
    [Descripcion]           VARCHAR (MAX)   NULL,
    [DescripcionCorta]      VARCHAR (MAX)   NULL,
    [CreadoPor]             INT             NOT NULL,
    [CreadoEl]              DATETIME        NOT NULL,
    [ModificadoPor]         INT             NULL,
    [ModificadoEl]          DATETIME        NULL,
    [IdServicio]            INT             NULL,
    [IdMaterialContratista] INT             NULL,
    FechaDocumento          DATE            NULL,
    PrefijoOTDocumento      VARCHAR(500)    NULL,
    MaterialConceptoDocumento VARCHAR(200)  NULL
    CONSTRAINT [PK_SC_Material] PRIMARY KEY CLUSTERED ([IdSCMaterial] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__SC_Materi__IdSer__53A3FD5A] FOREIGN KEY ([IdServicio]) REFERENCES [dbo].[CO_Servicio] ([IdServicio]),
    CONSTRAINT [FK_SC_Material_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SC_Material_AP_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SC_Material_SC_SubContrato] FOREIGN KEY ([IdSubContrato]) REFERENCES [dbo].[SC_SubContrato] ([IdSubContrato])
);

