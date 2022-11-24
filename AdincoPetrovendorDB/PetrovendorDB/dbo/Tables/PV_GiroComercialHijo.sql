CREATE TABLE [dbo].[PV_GiroComercialHijo] (
    [IdGiroProveedorHijo]  INT           IDENTITY (1, 1) NOT NULL,
    [GiroProovedor]        VARCHAR (200) NULL,
    [IdGiroProveedorPadre] INT           NULL,
    PRIMARY KEY CLUSTERED ([IdGiroProveedorHijo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdGiroProveedorPadre]) REFERENCES [dbo].[PV_GiroComercialPadre] ([IdGiroProveedorPadre])
);

