CREATE TABLE [dbo].[PC_VentasAsignacion] (
    [ASIGNACIÓN]                     NVARCHAR (255) NULL,
    [REGIÓN FISCAL]                  NVARCHAR (255) NULL,
    [REGIÓN]                         NVARCHAR (255) NULL,
    [POZO SNIP]                      NVARCHAR (255) NULL,
    [PRODUCTO POZO]                  NVARCHAR (255) NULL,
    [PRODUCCIÓN POZO]                NVARCHAR (50)  NULL,
    [CAMPO OFICIAL]                  NVARCHAR (255) NULL,
    [PRODUCCIÓN CAMPO]               NVARCHAR (50)  NULL,
    [PRODUCTO UNIF]                  NVARCHAR (255) NULL,
    [FACTOR = ProdPozo/ProdCampo]    NVARCHAR (50)  NULL,
    [PRODUCCIÓN ASIGNACIÓN]          NVARCHAR (50)  NULL,
    [PRODUCTO AGRUPA]                NVARCHAR (255) NULL,
    [PRODUCTO VENTA]                 NVARCHAR (255) NULL,
    [PUNTO DE VENTA]                 NVARCHAR (255) NULL,
    [VENTA CAMPO MES]                NVARCHAR (50)  NULL,
    [VENTA ASIGNACIÓN MES]           NVARCHAR (50)  NULL,
    [UNIDAD VENTA MES]               NVARCHAR (255) NULL,
    [VENTA ASIGNACIÓN DÍA]           NVARCHAR (50)  NULL,
    [UNIDAD VENTA DÍA]               NVARCHAR (255) NULL,
    [VENTA ASIGNACIÓN MES INGLÉS]    NVARCHAR (50)  NULL,
    [UNIDAD VENTA MES INGLÉS]        NVARCHAR (255) NULL,
    [VENTA ASIGNACIÓN DÍA INGLÉS]    NVARCHAR (50)  NULL,
    [UNIDAD VENTA DÍA INGLÉS]        NVARCHAR (255) NULL,
    [API]                            NVARCHAR (50)  NULL,
    [S]                              NVARCHAR (50)  NULL,
    [C1]                             NVARCHAR (50)  NULL,
    [C2]                             NVARCHAR (50)  NULL,
    [C3]                             NVARCHAR (50)  NULL,
    [NC4]                            NVARCHAR (50)  NULL,
    [IC4]                            NVARCHAR (50)  NULL,
    [C5+]                            NVARCHAR (50)  NULL,
    [CO2]                            NVARCHAR (50)  NULL,
    [H2S]                            NVARCHAR (50)  NULL,
    [N2]                             NVARCHAR (50)  NULL,
    [PoderCalorif C1]                NVARCHAR (50)  NULL,
    [PoderCalorif C2]                NVARCHAR (50)  NULL,
    [PoderCalorif C3]                NVARCHAR (50)  NULL,
    [PoderCalorif NC4]               NVARCHAR (50)  NULL,
    [PoderCalorif IC4]               NVARCHAR (50)  NULL,
    [PoderCalorif C5+]               NVARCHAR (50)  NULL,
    [PoderCalorif C1Btu/pc]          NVARCHAR (50)  NULL,
    [PoderCalorif C2Btu/pc]          NVARCHAR (50)  NULL,
    [PoderCalorif C3Btu/pc]          NVARCHAR (50)  NULL,
    [PoderCalorif NC4Btu/pc]         NVARCHAR (50)  NULL,
    [PoderCalorif IC4Btu/pc]         NVARCHAR (50)  NULL,
    [PoderCalorif C5+Btu/pc]         NVARCHAR (50)  NULL,
    [PoderCalorif Total Btu/pc]      NVARCHAR (50)  NULL,
    [Volumen C1]                     NVARCHAR (50)  NULL,
    [Volumen C2]                     NVARCHAR (50)  NULL,
    [Volumen C3]                     NVARCHAR (50)  NULL,
    [Volumen NC4]                    NVARCHAR (50)  NULL,
    [Volumen IC4]                    NVARCHAR (50)  NULL,
    [Volumen C5+]                    NVARCHAR (50)  NULL,
    [Energía C1]                     NVARCHAR (50)  NULL,
    [Energía C2]                     NVARCHAR (50)  NULL,
    [Energía C3]                     NVARCHAR (50)  NULL,
    [Energía NC4]                    NVARCHAR (50)  NULL,
    [Energía IC4]                    NVARCHAR (50)  NULL,
    [Energía C5+]                    NVARCHAR (50)  NULL,
    [Energía Total]                  NVARCHAR (50)  NULL,
    [Ingreso C1]                     NVARCHAR (50)  NULL,
    [Ingreso C2]                     NVARCHAR (50)  NULL,
    [Ingreso C3]                     NVARCHAR (50)  NULL,
    [Ingreso NC4]                    NVARCHAR (50)  NULL,
    [Ingreso IC4]                    NVARCHAR (50)  NULL,
    [Ingreso C5+]                    NVARCHAR (50)  NULL,
    [Precio C1]                      NVARCHAR (50)  NULL,
    [Precio C2]                      NVARCHAR (50)  NULL,
    [Precio C3]                      NVARCHAR (50)  NULL,
    [Precio NC4]                     NVARCHAR (50)  NULL,
    [Precio IC4]                     NVARCHAR (50)  NULL,
    [Precio C5+]                     NVARCHAR (50)  NULL,
    [Precio ]                        NVARCHAR (50)  NULL,
    [Ingresos Mes USD]               NVARCHAR (50)  NULL,
    [Venta Campo mes Facturado]      NVARCHAR (50)  NULL,
    [Venta Asignación mes Facturado] NVARCHAR (50)  NULL,
    [Volumen Facturacion]            NVARCHAR (50)  NULL,
    [Precio Facturación]             NVARCHAR (50)  NULL,
    [Ingresos Mes Calculado USD]     NVARCHAR (50)  NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_PuntoVenta]
    ON [dbo].[PC_VentasAsignacion]([PUNTO DE VENTA] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idx_CampoOficial]
    ON [dbo].[PC_VentasAsignacion]([CAMPO OFICIAL] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idx_ProductoAgrupa]
    ON [dbo].[PC_VentasAsignacion]([PRODUCTO AGRUPA] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

