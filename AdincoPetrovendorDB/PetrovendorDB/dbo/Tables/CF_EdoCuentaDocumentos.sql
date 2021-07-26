CREATE TABLE [dbo].[CF_EdoCuentaDocumentos] (
    [IdEdoCuenta]   INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor]   INT            NOT NULL,
    [EdoCuenta]     NVARCHAR (MAX) NOT NULL,
    [Año]           INT            NOT NULL,
    [SubidoPor]     INT            NOT NULL,
    [FechaCarga]    SMALLDATETIME  NOT NULL,
    [NombreDoc]     VARCHAR (MAX)  NULL,
    [Carpeta]       NVARCHAR (300) NULL,
    [Identificador] NVARCHAR (300) NULL,
    [Extension]     NVARCHAR (300) NULL,
    [Mime]          NVARCHAR (300) NULL,
    [AMS3]          BIT            NULL,
    [EliminadoS3]   BIT            NULL,
    [isEliminado]   BIT            NULL,
    [Bucket]        VARCHAR(50)    NULL, 
    CONSTRAINT [PK_CF_EdoCuentaDocumentos] PRIMARY KEY CLUSTERED ([IdEdoCuenta] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CF_EdoCuentaDocumentos_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_CF_EdoCuentaDocumentos_S_Usuario] FOREIGN KEY ([SubidoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

