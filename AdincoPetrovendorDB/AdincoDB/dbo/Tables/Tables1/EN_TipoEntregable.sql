CREATE TABLE [dbo].[EN_TipoEntregable] (
    [IdTipoEntregable] INT            IDENTITY (1, 1) NOT NULL,
    [TipoEntregable]   NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    CONSTRAINT [PK_Cat_General_TipoEntregable] PRIMARY KEY CLUSTERED ([IdTipoEntregable] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

