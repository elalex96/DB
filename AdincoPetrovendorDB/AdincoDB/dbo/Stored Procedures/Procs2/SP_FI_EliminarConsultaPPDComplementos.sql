-- =============================================
-- Author:		Neri Garcia
-- Create date: 25-08-2021
-- Description:	Eliminar FI_ControlPPDComplementos por Id principal
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EliminarConsultaPPDComplementos] 
-- ============================================= 
@IdControlPPDC   INT,
@IdContrato      INT, 
@IdUsuario       INT
AS    
BEGIN       
    SET NOCOUNT ON; 
	BEGIN TRY
	BEGIN TRAN
		-- =============================================  
		DELETE FROM  dbo.FI_ControlPPDComplementos WHERE IdControlPPDC = @IdControlPPDC
		-- =============================================
		SELECT 'Ok';
	/*===========*/
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		/*===========*/
		ROLLBACK TRAN		
		SELECT 'ERROR SP_FI_EliminarConsultaPPDComplementos ['+ ERROR_MESSAGE() + '] LINEA ['+ CAST(ERROR_LINE() AS VARCHAR)+']';
		/*===========*/
	END CATCH	
END