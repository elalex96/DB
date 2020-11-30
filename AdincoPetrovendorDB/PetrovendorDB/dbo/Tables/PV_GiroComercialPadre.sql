CREATE TABLE [dbo].[PV_GiroComercialPadre] (
    [IdGiroProveedorPadre] INT           IDENTITY (1, 1) NOT NULL,
    [GiroProovedor]        VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([IdGiroProveedorPadre] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

