CREATE TABLE [dbo].[CO_GastosRubro] (
    [IdGastoRubro] TINYINT       NOT NULL,
    [Descripcion]  VARCHAR (250) NOT NULL,
    CONSTRAINT [PK_CO_GastoRubro] PRIMARY KEY CLUSTERED ([IdGastoRubro] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

