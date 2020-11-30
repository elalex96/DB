CREATE TABLE [dbo].[TaTipoTarea] (
    [IdTipoTarea]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreTipoTarea] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TaTipoTarea] PRIMARY KEY CLUSTERED ([IdTipoTarea] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

