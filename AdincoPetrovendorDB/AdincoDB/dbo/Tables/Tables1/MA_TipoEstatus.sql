CREATE TABLE [dbo].[MA_TipoEstatus] (
    [IdTipoEstatus]    INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]           NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEl]     DATETIME       NULL,
    [IsEliminado]      INT            NULL,
    [IdContrato]       INT            NULL,
    [IdSubcontratista] INT            NULL,
    CONSTRAINT [PK_TA_TipoEstatus] PRIMARY KEY CLUSTERED ([IdTipoEstatus] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

