CREATE TABLE [dbo].[MA_Flujo] (
    [IdFlujo]          INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]           NVARCHAR (500) NULL,
    [Descripcion]      NVARCHAR (MAX) NULL,
    [IdTipoFlujo]      INT            NULL,
    [IdTipoOperacion]  INT            NULL,
    [IdContrato]       INT            NULL,
    [Activo]           BIT            NULL,
    [Predeterminado]   BIT            NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEl]     DATETIME       NULL,
    [IsEliminado]      INT            NULL,
    [IdSubcontratista] INT            NULL,
    CONSTRAINT [PK_MA_Flujo] PRIMARY KEY CLUSTERED ([IdFlujo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MA_Flujo_MA_TipoFlujo] FOREIGN KEY ([IdTipoFlujo]) REFERENCES [dbo].[MA_TipoFlujo] ([IdTipoFlujo]),
    CONSTRAINT [FK_MA_Flujo_MA_TipoOperacion] FOREIGN KEY ([IdTipoOperacion]) REFERENCES [dbo].[MA_TipoOperacion] ([IdTipoOperacion])
);

