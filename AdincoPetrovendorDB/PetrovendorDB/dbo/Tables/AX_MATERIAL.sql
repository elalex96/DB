CREATE TABLE [dbo].[AX_MATERIAL] (
    [IdMaterialAx]     INT      NOT NULL,
    [IdMaterialPetrov] INT      NOT NULL,
    [IdProveedor]      INT      NULL,
    [FechaRegistro]    DATETIME NULL,
    PRIMARY KEY CLUSTERED ([IdMaterialAx] ASC, [IdMaterialPetrov] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

