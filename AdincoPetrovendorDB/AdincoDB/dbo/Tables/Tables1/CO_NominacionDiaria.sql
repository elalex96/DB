CREATE TABLE [dbo].[CO_NominacionDiaria] (
    [idNominacionVolumenDiario] INT            IDENTITY (1000, 1) NOT NULL,
    [idFecha]                   DATE           NULL,
    [idProductoNominacion]      INT            NULL,
    [PuntoEntregaID]            INT            NULL,
    [idTipoBase]                INT            NULL,
    [VolumenProgramado]         FLOAT (53)     NULL,
    [idUnidadMedida]            INT            NULL,
    [idContrato]                INT            NULL,
    [Comentario]                NVARCHAR (MAX) NULL,
    [CreadoPor]                 INT            NULL,
    [CreadoEl]                  DATETIME       NULL,
    [ModificadoPor]             INT            NULL,
    [ModificadoEl]              DATETIME       NULL,
    [Activo]                    BIT            NULL,
    CONSTRAINT [PK__CO_Nomin__882CBFBDF88A571B] PRIMARY KEY CLUSTERED ([idNominacionVolumenDiario] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__CO_Nomina__idCon__261DF523] FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK__CO_Nomina__idTip__2712195C] FOREIGN KEY ([idTipoBase]) REFERENCES [dbo].[CO_TipoBasesNominacion] ([idTipoBase]),
    CONSTRAINT [FK__CO_Nomina__idUni__28063D95] FOREIGN KEY ([idUnidadMedida]) REFERENCES [dbo].[CO_UnidadMedida] ([idUnidadMedida]),
    CONSTRAINT [FK_CO_NominacionDiaria_CO_ClasificacionProductoNominacion] FOREIGN KEY ([idProductoNominacion]) REFERENCES [dbo].[CO_ClasificacionProductoNominacion] ([ProductoNominacionID]),
    CONSTRAINT [FK_CO_NominacionDiaria_CO_PuntosdeEntregaContrato] FOREIGN KEY ([PuntoEntregaID]) REFERENCES [dbo].[CO_PuntosdeEntrega] ([PuntoEntregaID])
);

