USE Petrovendor
GO
DROP PROC IF EXISTS AD_SP_ComboInstalaciones
GO
-- =============================================
-- Author:	Daniel
-- Create date: 08-11-2023
-- Description:	SP PARA OBTENER INSTALACION CON VALIDACION DE PREFERENCIA
-- =============================================
-- Author:	David
-- Create date: 30-11-2023
-- Description:	SP PARA VALIDAR SI SE ESTÁ ACCEDIENDO A UNA SOLPED GUARDADA
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_ComboInstalaciones]
	@IdContrato INT,
	@IdUsuario INT = null,
	@IdCentroCosto NVARCHAR(300),
	@IsSolpedGuardado bit = NULL
AS
BEGIN
	
	DECLARE @PreferenciaId INT = (SELECT Id FROM [AP_Preferencias] WHERE [Nombre]='FiltroInstalacionesPorCentroCosto')

	if(ISNULL(@IsSolpedGuardado,0) = 0)
	BEGIN
	IF EXISTS (SELECT 1 FROM AP_PreferenciaContrato
	WHERE ContratoId= @IdContrato
	AND PreferenciaId = ISNULL(@PreferenciaId,0))
	BEGIN 
	 
		SELECT
			I.IdInstalacion,
			I.NombreInstalacion AS NombreInstalacion
		FROM  CC_CentroCostoInstalacion CCI (NOLOCK)
		 JOIN Adinco.dbo.CO_Instalacion AS I (NOLOCK)
			ON CCI.IdInstalacion = I.IdInstalacion		   
		 JOIN adinco.dbo.CO_Contrato AS C (NOLOCK) 
			ON I.IdAreaContractual = C.IdAreaContractual 
		 AND CCI.IdContrato = @IdContrato		 
		WHERE CAST(ISNULL(CCI.IdCentroCosto,'') AS NVARCHAR(MAX)) = ISNULL(@IdCentroCosto,'')
		AND CCI.Activo = 1 
		ORDER BY I.NombreInstalacion ASC
	END 
	ELSE
	BEGIN 

		SELECT
			I.IdInstalacion,
			I.NombreInstalacion
		FROM Adinco.dbo.CO_Instalacion AS I (NOLOCK)
		 JOIN adinco.dbo.CO_Contrato AS C (NOLOCK) 
		 ON I.IdAreaContractual = C.IdAreaContractual 
		 AND C.IdContrato = @IdContrato
		WHERE ISNULL(I.Activo,0) = 1
		ORDER BY I.NombreInstalacion ASC
	END 
	END
	ELSE
	BEGIN 
	IF EXISTS (SELECT 1 FROM AP_PreferenciaContrato
	WHERE ContratoId= @IdContrato
	AND PreferenciaId = ISNULL(@PreferenciaId,0))
	BEGIN 
	 
		SELECT
			I.IdInstalacion,
			I.NombreInstalacion AS NombreInstalacion
		FROM  CC_CentroCostoInstalacion CCI (NOLOCK)
		 JOIN Adinco.dbo.CO_Instalacion AS I (NOLOCK)
			ON CCI.IdInstalacion = I.IdInstalacion		   
		 JOIN adinco.dbo.CO_Contrato AS C (NOLOCK) 
			ON I.IdAreaContractual = C.IdAreaContractual 
		 AND CCI.IdContrato = @IdContrato		 
		WHERE CAST(ISNULL(CCI.IdCentroCosto,'') AS NVARCHAR(MAX)) = ISNULL(@IdCentroCosto,'')
		ORDER BY I.NombreInstalacion ASC
	END 
	ELSE
	BEGIN 

		SELECT
			I.IdInstalacion,
			I.NombreInstalacion
		FROM Adinco.dbo.CO_Instalacion AS I (NOLOCK)
		 JOIN adinco.dbo.CO_Contrato AS C (NOLOCK) 
		 ON I.IdAreaContractual = C.IdAreaContractual 
		 AND C.IdContrato = @IdContrato
		ORDER BY I.NombreInstalacion ASC
	END 
	END
	

END
