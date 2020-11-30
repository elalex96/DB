CREATE TABLE [dbo].[MA_TipoFlujo] (
    [IdTipoFlujo]      INT            IDENTITY (1, 1) NOT NULL,
    [TipoFlujo]        NVARCHAR (300) NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEl]     DATETIME       NULL,
    [IsEliminado]      INT            NULL,
    [IdContratista]    INT            NULL,
    [IdSubcontratista] INT            NULL,
    CONSTRAINT [PK_MA_TipoFlujo] PRIMARY KEY CLUSTERED ([IdTipoFlujo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

