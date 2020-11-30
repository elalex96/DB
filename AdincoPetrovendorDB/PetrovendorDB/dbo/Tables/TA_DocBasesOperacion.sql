CREATE TABLE [dbo].[TA_DocBasesOperacion] (
    [IdDocBases]    INT            IDENTITY (1, 1) NOT NULL,
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
    [CreadoEl]      DATETIME       NULL,
    [CreadoPor]     INT            NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    CONSTRAINT [PK_TA_DocBasesOperacion] PRIMARY KEY CLUSTERED ([IdDocBases] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TA_DocBasesOperacion_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_TA_DocBasesOperacion_TA_Operacion] FOREIGN KEY ([IdOperacion]) REFERENCES [dbo].[TA_Operacion] ([IdOperacion])
);

