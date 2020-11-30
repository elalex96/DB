CREATE TABLE [dbo].[CO_TipoPago] (
    [IdTipoPago] INT            IDENTITY (1, 1) NOT NULL,
    [TipoPago]   NVARCHAR (MAX) NULL,
    [Clave]      NVARCHAR (MAX) NULL,
    [CreadoPor]  INT            NULL,
    CONSTRAINT [PK_TipoPago] PRIMARY KEY CLUSTERED ([IdTipoPago] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

