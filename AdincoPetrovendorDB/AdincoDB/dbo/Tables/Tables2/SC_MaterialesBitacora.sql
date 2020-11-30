CREATE TABLE [dbo].[SC_MaterialesBitacora] (
    [IdSCBitacora]     INT             NOT NULL,
    [IdSCMaterial]     INT             NOT NULL,
    [CantidadRespaldo] DECIMAL (14, 2) NOT NULL,
    [FechaRespaldo]    DATETIME        NOT NULL,
    [ModificadoPor]    INT             NOT NULL,
    [Cantidad]         FLOAT (53)      NULL,
    [PrecioUnitario]   FLOAT (53)      NULL,
    CONSTRAINT [PK_SC_MaterialesBitacora] PRIMARY KEY CLUSTERED ([IdSCBitacora] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SC_MaterialesBitacora_SC_Materiales] FOREIGN KEY ([IdSCMaterial]) REFERENCES [dbo].[SC_Materiales] ([IdSCMaterial])
);

