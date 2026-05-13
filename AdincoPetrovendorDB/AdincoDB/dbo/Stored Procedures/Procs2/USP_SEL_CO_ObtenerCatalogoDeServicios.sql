IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_ObtenerCatalogoDeServicios'
)
    DROP PROCEDURE USP_SEL_CO_ObtenerCatalogoDeServicios;
GO

CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenerCatalogoDeServicios] 
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
    [CreadoPor] INT NULL,
    [Usuario] VARCHAR(100) NULL,
    [CreadoEn] DATETIME NULL,
	[ModificadoPor] INT NULL,
    [UsuarioModificador] VARCHAR(100) NULL,
    [ModificadoEl] DATETIME NULL,
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
	ModificadoPor,
	ModificadoEl,
    Activo,
    Contrato,
    Usuario,
	UsuarioModificador
)
SELECT IdServicio,
       IdContrato,
       NombreServicio,
       IdUnidad,
       CreadoPor,
       FecMovto,
	   ModificadoPor,
	   ModificadoEl,
       Activo,
       '',
       '',
       ''
FROM CO_Servicio (NOLOCK)

UPDATE #T_Servicio
SET #T_Servicio.IdUnidad = NULL
FROM #T_Servicio
    JOIN CO_Unidad
        ON #T_Servicio.IdUnidad = CO_Unidad.IdUnidad
		AND CO_Unidad.IdContrato <> 1

UPDATE #T_Servicio
SET #T_Servicio.Usuario = ISNULL(AP_Usuario.Nombre, '')
FROM #T_Servicio
    JOIN AP_Usuario
        ON #T_Servicio.CreadoPor = AP_Usuario.UsuarioID

UPDATE #T_Servicio
SET #T_Servicio.UsuarioModificador = ISNULL(AP_Usuario.Nombre, '')
FROM #T_Servicio
    JOIN AP_Usuario
        ON #T_Servicio.ModificadoPor = AP_Usuario.UsuarioID

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
       IdUnidad,
       Usuario,
       CreadoEn,
	   UsuarioModificador,
	   ModificadoEl,
       Activo
FROM #T_Servicio 
ORDER BY Contrato ASC