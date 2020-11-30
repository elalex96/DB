-- =============================================
-- Author:		Oscar Mtz
-- Create date: 30/06/2017
-- Description:	Elimina un registro en la tabla AP_Usuario.
-- =============================================
CREATE PROCEDURE dbo.sp_AP_EliminaUsuarios
@UsuarioID as int
AS
BEGIN 
DECLARE @RowAffected as int;
SET NOCOUNT ON;
	BEGIN TRY

		UPDATE	[dbo].[AP_Usuario]
		SET		[IsActivo] = 0 ,[IsEliminado] = 1    
		WHERE	UsuarioID = @UsuarioID;
 
		 --Filas afectadas.
		 SELECT @RowAffected = @@ROWCOUNT
		 SELECT @RowAffected as FilasAfectadas;
	END TRY
	 BEGIN CATCH
		 SELECT   
				ERROR_NUMBER() AS NumeroError  
				--,ERROR_SEVERITY() AS ErrorSeverity  
				--,ERROR_STATE() AS ErrorState  
				,ERROR_PROCEDURE() AS ProcedimientoError  
				,ERROR_LINE() AS LineaError  
				,ERROR_MESSAGE() AS MensajeError;   
	 END CATCH
END