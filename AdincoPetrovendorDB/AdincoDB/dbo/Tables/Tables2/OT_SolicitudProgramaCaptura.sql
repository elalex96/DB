CREATE TABLE [dbo].[OT_SolicitudProgramaCaptura] (
    [IdOTSolicitudProgramaCaptura] INT             NOT NULL,
    [IdOTSolicitudMaterial]        INT             NOT NULL,
    [IdAnioMesDia]                 INT             NOT NULL,
    [Fecha]                        DATETIME        NOT NULL,
    [Captura]                      DECIMAL (14, 5) NULL,
    [CreadoPor]                    VARCHAR (50)    NOT NULL,
    [CreadoEl]                     DATETIME        NOT NULL,
    [ModificadoPor]                VARCHAR (50)    NULL,
    [ModificadoEl]                 DATETIME        NULL,
    [VoBoContratista]              BIT             NULL,
    [FechaVoBoContratista]         DATETIME        NULL,
    [QuienVoBoContratista]         VARCHAR (100)   NULL,
    [VoBoSubcontratista]           BIT             NULL,
    [FechaVoBoSubcontratista]      DATETIME        NULL,
    [QuienVoBoSubontratista]       VARCHAR (100)   NULL,
    [Cerrado]                      BIT             NULL,
    [CerradoPor]                   INT             NULL,
    [FechaCierre]                  DATETIME        NULL,
    CONSTRAINT [PK_OT_SolicitudProgramaCaptura] PRIMARY KEY CLUSTERED ([IdOTSolicitudProgramaCaptura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__OT_Solici__IdOTS__2D5F2438] FOREIGN KEY ([IdOTSolicitudMaterial]) REFERENCES [dbo].[OT_SolicitudMaterial] ([IdOTSolicitudMaterial]),
    CONSTRAINT [FK_SolicitudProgramaCaptura_usuarios] FOREIGN KEY ([CerradoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);


GO
CREATE NONCLUSTERED INDEX [IX_OT_SolicitudProgramaCaptura]
    ON [dbo].[OT_SolicitudProgramaCaptura]([IdOTSolicitudMaterial] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

