CREATE TABLE [dbo].[S_BitacoraConsultaCatalogoProveedor] (
    [IdBitacora]            INT            IDENTITY (1, 1) NOT NULL,
    [IdUsuario]             INT            NOT NULL,
    [IdProveedorConsultado] INT            NOT NULL,
    [Motivo]                VARCHAR (1500) NOT NULL,
    [FechaConsulta]         SMALLDATETIME  NOT NULL,
    CONSTRAINT [PK_S_BitacoraConsultaCatalogoProveedor] PRIMARY KEY CLUSTERED ([IdBitacora] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_S_BitacoraConsultaCatalogoProveedor_S_Proveedor1] FOREIGN KEY ([IdProveedorConsultado]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_S_BitacoraConsultaCatalogoProveedor_S_Usuario1] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

