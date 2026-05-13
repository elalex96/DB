CREATE TABLE [dbo].[EN_Entregable] (
    [IdEntregable]                     INT            IDENTITY (10000, 1) NOT NULL,
    [DocumentoEntregable]              VARCHAR (8000) NULL,
    [IdMarcoLegal]                     INT            NULL,
    [TituloAnexo]                      VARCHAR (8000) NULL,
    [Capitulo]                         VARCHAR (8000) NULL,
    [Descripcion]                      VARCHAR (8000) NULL,
    [Seccion]                          VARCHAR (8000) NULL,
    [Articulo]                         VARCHAR (8000) NULL,
    [Inciso]                           VARCHAR (8000) NULL,
    [Apartado]                         VARCHAR (8000) NULL,
    [Observaciones]                    VARCHAR (8000) NULL,
    [ArchivoNormatividad]              VARCHAR (8000) NULL,
    [ArchivoEntregable]                VARCHAR (8000) NULL,
    [IdRegulador]                      INT            NULL,
    [IdEtapa]                          INT            NULL,
    [IdReceptorEntregable]             INT            NULL,
    [IdResponsableGenerador]           INT            NULL,
    [IdFrecuenciaEntregable]           INT            NULL,
    [TiempoEntrega]                    VARCHAR (8000) NULL,
    [IdTiempoRespuesta]                INT            NULL,
    [FechaPublicacion]                 DATETIME       NULL,
    [FechaModificacion]                DATETIME       NULL,
    [CreadoPor]                        INT            NULL,
    [CreadoEn]                         DATETIME       NULL,
    [ModificadoPor]                    INT            NULL,
    [ModificadoEn]                     DATETIME       NULL,
    [IsActivo]                         BIT            NULL,
    [IsEliminado]                      BIT            NULL,
    [Consecutivo]                      VARCHAR (8000) NULL,
    [TCLicencia]                       BIT            NULL,
    [TCProducionCompartida]            BIT            NULL,
    [TCLicenciaFarmOuts]               BIT            NULL,
    [TCProducionCompartidaFarmOuts]    BIT            NULL,
    [UGTerrestre]                      BIT            NULL,
    [UGCostaFuera]                     BIT            NULL,
    [REReguladores]                    BIT            NULL,
    [REOperadores]                     BIT            NULL,
    [APAdministracionContratos]        BIT            NULL,
    [APPozoAlivio]                     BIT            NULL,
    [APCierreDesmantelamientoAbandono] BIT            NULL,
    [APPerforacion]                    BIT            NULL,
    [APTerminacion]                    BIT            NULL,
    [APActProduccion]                  BIT            NULL,
    [APEstimulacion]                   BIT            NULL,
    [APPruebaProduccion]               BIT            NULL,
    [APConstruccionCamino]             BIT            NULL,
    [APConstruccionLocalizacion]       BIT            NULL,
    [APRehabilitacionCamino]           BIT            NULL,
    [APRehabilitacionLocalizacion]     BIT            NULL,
    [APTomaInformacionSismica]         BIT            NULL,
    [APCorteNucleos]                   BIT            NULL,
    [APConstruccionLineaDescarga]      BIT            NULL,
    [APSistemaArtificialProduccion]    BIT            NULL,
    [APMedicionPozos]                  BIT            NULL,
    [APTomaInformacionPozo]            BIT            NULL,
    [APReparacionMayor]                BIT            NULL,
    [APReparacionMenor]                BIT            NULL,
    [APTransporteHidrocarburos]        BIT            NULL,
    [APQuemaGas]                       BIT            NULL,
    [BitInterno]                       BIT            NULL,
    [EsDeProceso]                      BIT            NULL,
    [Formato]                          VARCHAR (500)  NULL,
    [IdClasificacion]                  INT            NULL,
    [RequiereRespuesta]                BIT            NULL,
    [Actividad]                        VARCHAR (500)  NULL,
    [Proceso]                          VARCHAR (500)  NULL,
    [DeliverableName]                  VARCHAR (8000) NULL,
    [BitJOA]                           BIT            NULL,
    [BitMostrarMensaje]                BIT            NULL,
    [BitAwareness]                     BIT            NULL,
    [BitRecorrerDiasAbiles]            BIT            NULL,
    CONSTRAINT [PK_EN_Entregable] PRIMARY KEY CLUSTERED ([IdEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [Clasificacion_Entregable] FOREIGN KEY ([IdClasificacion]) REFERENCES [dbo].[En_Clasificacion] ([IdClasificacion]),
    CONSTRAINT [fk_En_entregableCO_Regulador] FOREIGN KEY ([IdRegulador]) REFERENCES [dbo].[CO_Regulador] ([IdRegulador]),
    CONSTRAINT [fk_en_entregableEN_FrecuenciaEntregable] FOREIGN KEY ([IdFrecuenciaEntregable]) REFERENCES [dbo].[EN_FrecuenciaEntregable] ([IdFrecuenciaEntregable]),
    CONSTRAINT [fk_en_entregableEN_TiempoRespuesta] FOREIGN KEY ([IdTiempoRespuesta]) REFERENCES [dbo].[EN_TiempoRespuesta] ([IdTiempoRespuesta]),
    CONSTRAINT [fk_En_entregableMarcoLegal] FOREIGN KEY ([IdMarcoLegal]) REFERENCES [dbo].[EN_MarcoLegal] ([IdMarcoLegal]),
    CONSTRAINT [fk_en_entregableReceptorEntregable] FOREIGN KEY ([IdReceptorEntregable]) REFERENCES [dbo].[EN_ReceptorEntregable] ([IdReceptorEntregable]),
    CONSTRAINT [fk_en_entregableReceptorGenerador] FOREIGN KEY ([IdResponsableGenerador]) REFERENCES [dbo].[EN_ResponsableGenerador] ([IdResponsableGenerador])
);


GO
CREATE NONCLUSTERED INDEX [IX_EN_Entregable]
    ON [dbo].[EN_Entregable]([IdEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
/****** Object:  Trigger [dbo].[EN_NuevoEntregable]    Script Date: 01/03/2019 06:50:21 p. m. ******/
CREATE TRIGGER [dbo].[EN_NuevoEntregable]
ON [dbo].[EN_Entregable]
FOR INSERT
AS
--SELECT *
--  FROM EN_Entregable;
--SELECT *
--  FROM EN_ContratoEntregable;
DECLARE @idEntregable INT,@pCreadoPor INT ;

SELECT @idEntregable = IdEntregable
  FROM inserted;

SELECT @pCreadoPor = CreadoPor
  FROM inserted;

INSERT INTO EN_ContratoEntregable (IdContrato,
                                   IdEntregable,
                                   AreaResponsable,
                                 --  Elabora,
                                 --  Revisa,
                                 --  Aprueba,
                                --   UsuarioElabora,
                                 --  UsuarioRevision,
                                 --  UsuarioAprueba,
                                   DiasRevision,
                                   DiasAprobacion,
                                   DiasAlerta,
                                   ReceptorAlerta,
                                   CreadoPor,
                                   CreadoEl,
                                   ModificadoPor,
                                   ModificadoEl,
                                   Activo,
                                   Entrega,
                                   FechaLimiteEntrega,
                                   FechaLimiteEntregaRegulador,
                                   DiasElaboracion)
     (SELECT IdContrato,
             @idEntregable AS idEntregable,
             '',
          --   '', -- Elabora - nvarchar(max)
         --    '', -- Revisa - nvarchar(max)
         --    '', -- Aprueba - nvarchar(max)
         --    NULL, -- UsuarioElabora - int
         --    NULL, -- UsuarioRevision - int
         --    NULL, -- UsuarioAprueba - int
             NULL, -- DiasRevision - int
             0, -- DiasAprobacion - int
             NULL, -- DiasAlerta - int
             NULL, -- ReceptorAlerta - nvarchar(max)
             @pCreadoPor, -- CreadoPor - int
             GETDATE(), -- CreadoEl - datetime
             @pCreadoPor, -- ModificadoPor - int
             GETDATE(), -- ModificadoEl - datetime
             1, -- Activo - bit
             NULL, -- Entrega - varchar(300)
             NULL, -- FechaLimiteEntrega - datetime
             NULL, -- FechaLimiteEntregaRegulador - date
             NULL -- DiasElaboracion - int
        FROM CO_Contrato);


GO
DISABLE TRIGGER [dbo].[EN_NuevoEntregable]
    ON [dbo].[EN_Entregable];

