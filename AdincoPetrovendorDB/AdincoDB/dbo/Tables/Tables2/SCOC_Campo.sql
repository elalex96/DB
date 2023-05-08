CREATE TABLE [dbo].[SCOC_Campo] (
    [CampoID]               INT            IDENTITY (10000, 1) NOT NULL,
    [NombreCampo]           NVARCHAR (MAX) NULL,
    [GasEntregadoEn]        VARCHAR (250)  NULL,
    [PetroleoEntregadoEn]   VARCHAR (250)  NULL,
    [CondensadoEntregadoEn] VARCHAR (250)  NULL,
    [CreadoPor]             INT            NULL,
    [CreadoEl]              DATETIME       NULL,
    [ModificadoPor]         INT            NULL,
    [ModificadoEl]          DATETIME       NULL,
    [Activo]                BIT            NULL,
    CONSTRAINT [PK_SCOC_Campo] PRIMARY KEY CLUSTERED ([CampoID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SCOC_Campo_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_Campo_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

