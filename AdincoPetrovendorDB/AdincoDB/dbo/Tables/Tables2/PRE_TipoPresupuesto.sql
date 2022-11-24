CREATE TABLE [dbo].[PRE_TipoPresupuesto] (
    [IdTipo]      INT            NOT NULL,
    [Descripcion] VARCHAR (1500) NULL,
    CONSTRAINT [PK_PRE_TipoPresupuesto] PRIMARY KEY CLUSTERED ([IdTipo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

