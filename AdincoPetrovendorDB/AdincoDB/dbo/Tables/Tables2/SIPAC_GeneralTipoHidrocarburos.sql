CREATE TABLE [dbo].[SIPAC_GeneralTipoHidrocarburos] (
    [IdTipoHidrocarburo] INT          IDENTITY (1, 1) NOT NULL,
    [TipoHidrocarburo]   VARCHAR (50) NOT NULL,
    [Orden]              INT          NULL,
    CONSTRAINT [PK_Cat_General_TipoHidrocarburos] PRIMARY KEY CLUSTERED ([IdTipoHidrocarburo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

