CREATE TABLE [dbo].[PR_SupervisionPozo] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [Pozo]             INT             NOT NULL,
    [SAP]              INT             NOT NULL,
    [Fecha]            DATETIME        NOT NULL,
    [PresionTP]        DECIMAL (24, 8) NOT NULL,
    [PresionTR]        DECIMAL (24, 8) NOT NULL,
    [PresionLDD]       DECIMAL (24, 8) NOT NULL,
    [EstrangTP]        DECIMAL (24, 8) NOT NULL,
    [EstrangTR]        DECIMAL (24, 8) NOT NULL,
    [VelocidadBombeo]  DECIMAL (24, 8) NOT NULL,
    [PresionBomba]     DECIMAL (24, 8) NOT NULL,
    [HidraulicaSAPBCP] DECIMAL (24, 8) NOT NULL,
    [TorqueSAPBCP]     DECIMAL (24, 8) NOT NULL,
    [CarreraSAPBM]     DECIMAL (24, 8) NOT NULL,
    [PresionBNAntes]   DECIMAL (24, 8) NOT NULL,
    [PresionBNDespues] DECIMAL (24, 8) NOT NULL,
    [EstrangBN]        DECIMAL (24, 8) NOT NULL,
    CONSTRAINT [PK_PR_SupervisionPozo] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SupervisionPozo_ListaGeneral] FOREIGN KEY ([SAP]) REFERENCES [dbo].[PR_ListaGeneral] ([Id])
);

