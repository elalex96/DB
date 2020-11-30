CREATE TABLE [dbo].[MA_TipoOperacion] (
    [IdTipoOperacion]  INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]           NVARCHAR (300) NULL,
    [IdContrato]       INT            NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEl]     DATETIME       NULL,
    [IsEliminado]      INT            NULL,
    [IdSubcontratista] INT            NULL,
    [Activo]           BIT            NULL,
    CONSTRAINT [PK_MA_TipoOperacion] PRIMARY KEY CLUSTERED ([IdTipoOperacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

