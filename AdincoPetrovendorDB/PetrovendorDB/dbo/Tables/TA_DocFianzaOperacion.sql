CREATE TABLE [dbo].[TA_DocFianzaOperacion] (
    [IdDocFianza]   INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor]   INT            NOT NULL,
    [NombreDoc]     VARCHAR (MAX)  NULL,
    [Documento]     NVARCHAR (MAX) NULL,
    [IdOperacion]   INT            NOT NULL,
    [Carpeta]       NVARCHAR (300) NULL,
    [Identificador] NVARCHAR (300) NULL,
    [Extension]     NVARCHAR (300) NULL,
    [Mime]          NVARCHAR (300) NULL,
    [AMS3]          BIT            NULL,
    [Activo]        BIT            DEFAULT ((1)) NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [Bucket]        VARCHAR (200)  NULL,
    CONSTRAINT [PK_TA_DocFianzaOperacion] PRIMARY KEY CLUSTERED ([IdDocFianza] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TA_DocFianzaOperacion_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_TA_DocFianzaOperacion_TA_Operacion] FOREIGN KEY ([IdOperacion]) REFERENCES [dbo].[TA_Operacion] ([IdOperacion])
);

