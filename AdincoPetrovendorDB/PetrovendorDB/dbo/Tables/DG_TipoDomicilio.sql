CREATE TABLE [dbo].[DG_TipoDomicilio] (
    [IdTipoDomicilio] INT            IDENTITY (1, 1) NOT NULL,
    [TipoDomicilio]   NVARCHAR (300) NULL,
    [Activo]          BIT            NULL,
    [CreadoPor]       INT            NULL,
    [CreadoEl]        DATETIME       NULL,
    [EditadorPor]     INT            NULL,
    [EditadoEl]       DATETIME       NULL,
    CONSTRAINT [PK_DG_TipoDomicilio] PRIMARY KEY CLUSTERED ([IdTipoDomicilio] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

