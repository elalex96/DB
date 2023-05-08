CREATE TABLE [dbo].[TA_DocMatrizOperacion] (
    [IdDocMatriz]  INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor]  INT            NOT NULL,
    [NombreDoc]    VARCHAR (MAX)  NULL,
    [Documento]    NVARCHAR (MAX) NULL,
    [IdOperacion]  INT            NULL,
    [PorcentajeEC] FLOAT (53)     NULL,
    [PorcentajeET] FLOAT (53)     NULL,
    CONSTRAINT [PK_TA_DocMatrizOperacion] PRIMARY KEY CLUSTERED ([IdDocMatriz] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TA_DocMatrizOperacion_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

