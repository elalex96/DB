CREATE TABLE [dbo].[OT_EstatusAdicional] (
    [IdEstatusAdicional] TINYINT      NOT NULL,
    [Nombre]             VARCHAR (50) NULL,
    [CreadoEl]           DATETIME     NULL,
    CONSTRAINT [PK_OT_EstatusAdicional] PRIMARY KEY CLUSTERED ([IdEstatusAdicional] ASC)
);

