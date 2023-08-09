IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_ObtenerCatalogoDeServicios'
)
    DROP PROCEDURE USP_SEL_CO_ObtenerCatalogoDeServicios;
GO

CREATE PROCEDURE USP_SEL_CO_ObtenerCatalogoDeServicios
    @UsuarioId INT,
    @ContratoId INT
AS
SET NOCOUNT ON;
CREATE TABLE #T_Servicio
(
    [IdServicio] INT NOT NULL,
    [IdContrato] INT NULL,
    [Contrato] VARCHAR(100) NULL,
    [NombreDelServicio] VARCHAR(8000) NULL,
    [IdUnidad] INT NULL,
    [Unidad] VARCHAR(100) NULL,
    [CreadoPor] INT NULL,
    [Usuario] VARCHAR(100) NULL,
    [CreadoEn] DATETIME NULL,
    [Activo] BIT NULL
);

INSERT INTO #T_Servicio
(
    IdServicio,
    IdContrato,
    NombreDelServicio,
    IdUnidad,
    CreadoPor,
    CreadoEn,
    Activo,
    Contrato,
    Unidad,
    Usuario
)
SELECT IdServicio,
       IdContrato,
       NombreServicio,
       IdUnidad,
       CreadoPor,
       FecMovto,
       Activo,
       '',
       '',
       ''
FROM CO_Servicio (NOLOCK)

UPDATE #T_Servicio
SET #T_Servicio.Unidad = ISNULL(CO_Unidad.Unidad, '')
FROM #T_Servicio
    JOIN CO_Unidad
        ON #T_Servicio.IdUnidad = CO_Unidad.IdUnidad

UPDATE #T_Servicio
SET #T_Servicio.Usuario = ISNULL(AP_Usuario.Nombre, '')
FROM #T_Servicio
    JOIN AP_Usuario
        ON #T_Servicio.CreadoPor = AP_Usuario.UsuarioID

UPDATE #T_Servicio
SET #T_Servicio.Contrato = CO_Contrato.NumeroContrato + ' - ' + ISNULL(CO_AreaContractual.NombreAreaContractual, '')
FROM #T_Servicio
    JOIN CO_Contrato
        ON #T_Servicio.IdContrato = CO_Contrato.IdContrato
    JOIN CO_AreaContractual
        ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual

SELECT IdServicio,
       Contrato,
       NombreDelServicio,
       Unidad,
       Usuario,
       CreadoEn,
       Activo
FROM #T_Servicio 
ORDER BY Contrato ASC