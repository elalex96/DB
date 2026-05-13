use petrovendor
drop proc if exists USP_SEL_CO_ConsultarInstalacionesAdinco
go
-- =============================================  
-- Author:  <Daniel AC>  
-- Create date: <11/11/2025>  
-- Description: <Consulta las instalaciones de ADINCO desde Petrovendor>  
-- =============================================  
-- Author:  Luis David
-- Create date: 20/MAR/26
-- Description: Se agregan nolock a tablas estáticas
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
	FROM CO_Instalacion instalacion (NOLOCK)
	INNER JOIN CO_Contrato AS contrato (NOLOCK)
	ON instalacion.IdAreaContractual  = contrato.IdAreaContractual
	WHERE contrato.IdContrato = @IdContrato
	AND instalacion.ACTIVO = 1
END 
