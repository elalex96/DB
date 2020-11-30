CREATE TABLE [dbo].[TipoPaquete] (
    [IdPaquete]   INT           IDENTITY (1, 1) NOT NULL,
    [TipoPaquete] VARCHAR (50)  NULL,
    [NumUsuarios] INT           NULL,
    [Precio]      DECIMAL (18)  NULL,
    [Descripcion] VARCHAR (200) NULL,
    CONSTRAINT [PK_CAT_TipoPaquete] PRIMARY KEY CLUSTERED ([IdPaquete] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

