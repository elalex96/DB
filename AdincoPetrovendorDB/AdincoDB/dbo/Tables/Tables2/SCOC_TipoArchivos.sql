CREATE TABLE [dbo].[SCOC_TipoArchivos] (
    [IdTipoArchivo]   INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]          VARCHAR (250)  NULL,
    [Descripcion]     VARCHAR (700)  NULL,
    [Activo]          BIT            NULL,
    [EsDescargable]   BIT            NULL,
    [CreadoPor]       INT            NULL,
    [CreadoEn]        DATETIME       NULL,
    [ModificadoPor]   INT            NULL,
    [ModificadoEn]    DATETIME       NULL,
    [EntregaGas]      NVARCHAR (250) NULL,
    [RecibeGas]       NVARCHAR (250) NULL,
    [EntregaPetroleo] NVARCHAR (250) NULL,
    [RecibePetroleo]  NVARCHAR (250) NULL,
    CONSTRAINT [PK_SCOC_TipoArchivos] PRIMARY KEY CLUSTERED ([IdTipoArchivo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

