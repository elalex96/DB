USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AD_SP_ComboInstalaciones'
)
    DROP PROCEDURE AD_SP_ComboInstalaciones;
GO
/****** Object:  StoredProcedure [dbo].[AD_SP_ComboInstalaciones]    Script Date: 09/11/2023 01:11:45 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel
-- Create date: 08-11-2023
-- Description:	SP PARA OBTENER INSTALACION CON VALIDACION DE PREFERENCIA
-- =============================================

CREATE PROCEDURE [dbo].[AD_SP_ComboInstalaciones]
	@IdContrato INT,
	@IdCentroCosto NVARCHAR(300)
AS
BEGIN
	
	DECLARE @PreferenciaId INT = (SELECT Id FROM [AP_Preferencias] WHERE [Nombre]='FiltroInstalacionesPorCentroCosto')


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