USE Adinco
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_ConsultarInstalacionesAdinco'
)
    DROP PROCEDURE USP_SEL_CO_ConsultarInstalacionesAdinco;
GO
-- =============================================  
-- Author:  <Daniel AC>  
-- Create date: <11/11/2025>  
-- Description: <Consulta las instalaciones de ADINCO desde Petrovendor>  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_SEL_CO_ConsultarInstalacionesAdinco]
 @IdContrato INT,  
 @IdProveedor INT,  
 @IdUsuario INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
    -- Insert statements for procedure here  

	SELECT instalacion.IdInstalacion, instalacion.NombreInstalacion
	FROM CO_Instalacion instalacion 
	INNER JOIN CO_Contrato contrato
	ON instalacion.IdAreaContractual  = contrato.IdAreaContractual
	WHERE contrato.IdContrato = @IdContrato
	AND instalacion.ACTIVO = 1
END  