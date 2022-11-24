CREATE TABLE [dbo].[PR_SistemasMedicionBitacora] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [Accion]        VARCHAR (300) NULL,
    [CreadoPor]     INT           NULL,
    [CreadoEl]      DATETIME      NULL,
    [IdSistema]     INT           NULL,
    [IdTipoSistema] INT           NULL,
    [Marca]         VARCHAR (300) NULL,
    [Modelo]        VARCHAR (300) NULL,
    [NoSerie]       VARCHAR (300) NULL,
    [TAG]           VARCHAR (300) NULL,
    [Activo]        BIT           NULL,
    [TipoMedidor]   VARCHAR (250) NULL,
    [IdContrato]    INT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

