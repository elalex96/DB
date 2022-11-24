CREATE TABLE [dbo].[MM_Oferta] (
    [IdOferta]         INT      IDENTITY (10000, 1) NOT NULL,
    [IdPeticionOferta] INT      NULL,
    [IdSubcontratista] INT      NOT NULL,
    [Monto]            MONEY    NULL,
    [IdMoneda]         INT      NULL,
    [IdEstatus]        INT      NULL,
    [FechaEnvio]       DATETIME NULL,
    [IdUsuario]        INT      NULL,
    CONSTRAINT [PK_MM_Oferta] PRIMARY KEY CLUSTERED ([IdOferta] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_Oferta_MM_PeticionOferta] FOREIGN KEY ([IdPeticionOferta]) REFERENCES [dbo].[MM_PeticionOferta] ([IdPeticionOferta]),
    CONSTRAINT [FK_MM_Oferta_PV_TipoMoneda] FOREIGN KEY ([IdMoneda]) REFERENCES [dbo].[PV_TipoMoneda] ([IdMoneda])
);

