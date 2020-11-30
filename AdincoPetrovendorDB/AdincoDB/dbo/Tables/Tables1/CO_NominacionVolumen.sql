CREATE TABLE [dbo].[CO_NominacionVolumen] (
    [idNominacionVolumen]  INT        IDENTITY (1000, 1) NOT NULL,
    [idFecha]              DATE       NULL,
    [idProductoNominacion] INT        NULL,
    [PuntoEntregaID]       INT        NULL,
    [idTipoBase]           INT        NULL,
    [VolumenProgramado]    FLOAT (53) NULL,
    [idUnidadMedida]       INT        NULL,
    [idContrato]           INT        NULL,
    [idDirector]           INT        NULL,
    [CreadoPor]            INT        NULL,
    [CreadoEl]             DATETIME   NULL,
    [ModificadoPor]        INT        NULL,
    [ModificadoEl]         DATETIME   NULL,
    [Activo]               BIT        NULL,
    CONSTRAINT [PK__CO_Nomin__41693C83F310F556] PRIMARY KEY CLUSTERED ([idNominacionVolumen] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__CO_Nomina__idCon__16BBB602] FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK__CO_Nomina__idPro__18A3FE74] FOREIGN KEY ([idProductoNominacion]) REFERENCES [dbo].[CO_ClasificacionProductoNominacion] ([ProductoNominacionID]),
    CONSTRAINT [FK__CO_Nomina__idTip__1A8C46E6] FOREIGN KEY ([idTipoBase]) REFERENCES [dbo].[CO_TipoBasesNominacion] ([idTipoBase]),
    CONSTRAINT [FK__CO_Nomina__idUni__1B806B1F] FOREIGN KEY ([idUnidadMedida]) REFERENCES [dbo].[CO_UnidadMedida] ([idUnidadMedida]),
    CONSTRAINT [FK__CO_Nomina__Punto__199822AD] FOREIGN KEY ([PuntoEntregaID]) REFERENCES [dbo].[CO_PuntosdeEntrega] ([PuntoEntregaID]),
    CONSTRAINT [FK_CO_NominacionVolumen_CO_DirectorOperaciones] FOREIGN KEY ([idDirector]) REFERENCES [dbo].[CO_DirectorOperaciones] ([idDirector])
);

