CREATE TABLE [dbo].[TA_TipoTarea] (
    [IdTipoTarea]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreTipoTarea] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TA_TipoTarea] PRIMARY KEY CLUSTERED ([IdTipoTarea] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

