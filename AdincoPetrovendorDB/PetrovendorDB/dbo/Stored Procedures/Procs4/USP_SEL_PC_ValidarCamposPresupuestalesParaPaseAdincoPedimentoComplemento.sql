USE Petrovendor
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_PC_ValidarCamposPresupuestalesParaPaseAdincoPedimentoComplemento'
)
    DROP PROCEDURE USP_SEL_PC_ValidarCamposPresupuestalesParaPaseAdincoPedimentoComplemento;
GO
-- =============================================  
-- Author:  <Daniel AC>  
-- Create date: <28/10/2025>  
-- Description: <Se agrega validación para ver si el comprobante/pedimento tiene el detalle presupuesto para evitar que envie nulls a ADINCO >  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_SEL_PC_ValidarCamposPresupuestalesParaPaseAdincoPedimentoComplemento]
  
 -- Add the parameters for the stored procedure here  
 @IdPedimentoComprobante INT,  
 @IdProveedor INT,  
 @IdUsuario INT  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
 SET LANGUAGE Spanish
    -- Insert statements for procedure here  

 DECLARE @APLICAFLUJOCOMPROBANTEPEDIMENTOLINEASPASEADINCO INT;
 DECLARE @VALIDACION_PRESUPUESTO NVARCHAR(MAX);
 DECLARE @Tipocomprobante NVARCHAR(100) = ''

 SET @APLICAFLUJOCOMPROBANTEPEDIMENTOLINEASPASEADINCO = (SELECT COUNT(PC.Id)
															FROM AP_PreferenciaContrato PC
															JOIN FI_PedimentoComprobante P
																ON PC.ContratoId = P.IdContrato
															JOIN AP_Preferencias PR
																ON PC.PreferenciaId = PR.Id
																AND PR.Nombre ='FlujoComprobantePedimentoLineasPaseAdinco'
															WHERE P.IdPedimentoComprobante =@IdPedimentoComprobante )

   IF @APLICAFLUJOCOMPROBANTEPEDIMENTOLINEASPASEADINCO > 0 
   BEGIN 
		SET @VALIDACION_PRESUPUESTO =  (SELECT CONCAT(CASE WHEN ISNULL(IdPeriodo,0) = 0 THEN  'No contiene un periodo, ' ELSE '' END,
										CASE WHEN ISNULL(IdPresupuesto,0) = 0 THEN  'No contiene un presupuesto, ' ELSE '' END,
										CASE WHEN ISNULL(IdLineaPresupuesto,0) = 0 THEN  'No contiene una linea de presupuesto' ELSE '' END) 
										FROM FI_PedimentoComprobante
										WHERE IdPedimentoComprobante = @IdPedimentoComprobante)

		IF LEN(ISNULL(@VALIDACION_PRESUPUESTO,''))>0 
		BEGIN

			SET @Tipocomprobante = (SELECT CASE WHEN TipoOrigen = 'PC_CD'  THEN 'Pedimento' 
									WHEN  TipoOrigen = 'CE_CD' THEN 'Comprobante' END
									FROM FI_PedimentoComprobante
									WHERE IdPedimentoComprobante = @IdPedimentoComprobante)
			SET @VALIDACION_PRESUPUESTO = CONCAT('No es posible realizar la aprobación', ', el ', ISNULL(@Tipocomprobante,'Comprobante'), ': ',@VALIDACION_PRESUPUESTO)
		END 

   END 
    
  SELECT ISNULL(@VALIDACION_PRESUPUESTO,'') as Validacion
END  