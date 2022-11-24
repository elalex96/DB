CREATE TABLE [dbo].[CO_PresupuestoAFE_Estatus] (
    [IdEstatus]   TINYINT       NOT NULL,
    [Descripcion] VARCHAR (200) NOT NULL,
    [CreadoEl]    DATETIME      NOT NULL,
    CONSTRAINT [PK_CO_PresupuestoAFE_Estatus] PRIMARY KEY CLUSTERED ([IdEstatus] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

