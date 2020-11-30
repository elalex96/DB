CREATE TABLE [dbo].[TA_TipoFlujoTarea] (
    [IdTipoFlujoTarea] INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]           NVARCHAR (300) NULL,
    CONSTRAINT [PK_TaTipoAprobacion] PRIMARY KEY CLUSTERED ([IdTipoFlujoTarea] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

