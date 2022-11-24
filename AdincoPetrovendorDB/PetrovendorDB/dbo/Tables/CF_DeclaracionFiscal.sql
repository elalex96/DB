CREATE TABLE [dbo].[CF_DeclaracionFiscal] (
    [IdDeclaracionFiscal] INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor]         INT            NOT NULL,
    [DeclaracionFiscal]   NVARCHAR (MAX) NOT NULL,
    [SubidoPor]           INT            NOT NULL,
    [FechaCarga]          SMALLDATETIME  NOT NULL,
    [NombreDoc]           VARCHAR (MAX)  NULL,
    [Anio]                INT            NULL,
    CONSTRAINT [PK_CF_DeclaracionFiscal] PRIMARY KEY CLUSTERED ([IdDeclaracionFiscal] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CF_DeclaracionFiscal_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_CF_DeclaracionFiscal_S_Usuario] FOREIGN KEY ([SubidoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

