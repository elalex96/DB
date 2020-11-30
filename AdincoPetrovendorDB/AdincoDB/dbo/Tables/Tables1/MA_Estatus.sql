CREATE TABLE [dbo].[MA_Estatus] (
    [IdEstatus]        INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]           NVARCHAR (MAX) NULL,
    [IdTipoEstatus]    INT            NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEl]     DATETIME       NULL,
    [IsEliminado]      INT            NULL,
    [IdContrato]       INT            NULL,
    [IdSubcontratista] INT            NULL,
    CONSTRAINT [PK_MA_Estatus] PRIMARY KEY CLUSTERED ([IdEstatus] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MA_Estatus_MA_TipoEstatus] FOREIGN KEY ([IdTipoEstatus]) REFERENCES [dbo].[MA_TipoEstatus] ([IdTipoEstatus])
);

