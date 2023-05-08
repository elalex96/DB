CREATE TABLE [dbo].[SIPAC_ImportRML_CONT_28_M] (
    [Id]         INT             IDENTITY (1, 1) NOT NULL,
    [IdBitacora] INT             NOT NULL,
    [RF_00]      VARCHAR (200)   NULL,
    [RI_00]      VARCHAR (200)   NULL,
    [RF01_01]    VARCHAR (200)   NULL,
    [RMLCT28_00] TINYINT         NULL,
    [RMLCT28_01] SMALLINT        NULL,
    [RMLCT28_02] TINYINT         NULL,
    [RMLCT28_03] SMALLINT        NULL,
    [RMLCT28_04] DECIMAL (18, 2) NULL,
    [CreadoPor]  INT             NULL,
    [CreadoEl]   DATETIME        NULL,
    CONSTRAINT [PK_SIPAC_ImportRML_CONT_28_M] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SIPAC_ImportRML_CONT_28_M_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SIPAC_ImportRML_CONT_28_M_SIPAC_ImportBitacora] FOREIGN KEY ([IdBitacora]) REFERENCES [dbo].[SIPAC_ImportBitacora] ([Id])
);

