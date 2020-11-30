CREATE TABLE [dbo].[MPY_MM_DocSoporteRecepcionFactura] (
    [IdDocSoporteRecepcionFactura] INT            IDENTITY (1, 1) NOT NULL,
    [IdAceptacionPedido]           INT            NOT NULL,
    [Documento]                    NVARCHAR (MAX) NOT NULL,
    [NombreDoc]                    VARCHAR (150)  NOT NULL,
    [CargadoPor]                   INT            NOT NULL,
    [CargadoEl]                    SMALLDATETIME  NOT NULL,
    [Eliminado]                    BIT            NOT NULL,
    [Comentario]                   VARCHAR (1500) NULL,
    [Carpeta]                      NVARCHAR (300) NULL,
    [Identificador]                NVARCHAR (300) NULL,
    [Extension]                    NVARCHAR (300) NULL,
    [Mime]                         NVARCHAR (300) NULL,
    [AMS3]                         BIT            NULL,
    [EliminadoEl]                  DATETIME       NULL,
    CONSTRAINT [PK_MPY_MM_DocSoporteRecepcionFactura] PRIMARY KEY CLUSTERED ([IdDocSoporteRecepcionFactura] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MPY_MM_DocSoporteRecepcionFactura_S_Usuario1] FOREIGN KEY ([CargadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

