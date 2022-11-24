-- =============================================
-- Author: Daniel AC
-- Create date: 26-08-2022
-- Description:	 Se actualiza información de la firma de la tarea  
-- =============================================
CREATE procedure [dbo].[SP_MM_ActualizarFirmaTarea]
	@IdTarea INT,
	@Firma NVARCHAR(MAX) 
AS
BEGIN
	
	UPDATE TA_Tarea
	SET IdFirma=@Firma 
	WHERE IdTarea=@IdTarea	

END