CREATE TABLE [dbo].[S_TipoTarjeta] (
    [IdTipoTarjeta]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreTipoTarjeta] NVARCHAR (200) NULL,
    [Activo]            BIT            NULL,
    CONSTRAINT [PK_S_TipoTarjeta] PRIMARY KEY CLUSTERED ([IdTipoTarjeta] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

