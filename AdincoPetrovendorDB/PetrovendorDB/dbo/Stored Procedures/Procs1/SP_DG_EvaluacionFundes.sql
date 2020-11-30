-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/052017>
-- Description:	<Procedimiento para insertar un documento en especidico(INE, RCF, ACTA CONSTITUTIVA) en la tabla S_Documento>
-- =============================================
CREATE PROCEDURE[dbo].[SP_DG_EvaluacionFundes] 

	-- Insertar Documento nuevo---
	
	@Documento                  nvarchar(MAX),
	@Puntuacion						float,
	@IdProveedorEvaluado            int,
	@IdProveedorEvaluador           int,
	@UsuarioEvaluador				int
    
AS

BEGIN

	INSERT INTO [dbo].[PV_FundesEvaluacion]
         (
		 [DocEvaluacion]
		,[Puntaje]
		,[ProveedorEvaluado]
		,[ProveedorEvaluador]
		,[UsuarioEvaluador]
		,[ModificadoEl]
		,[Activo]
         )
         VALUES
         (
		 @Documento,
		 @Puntuacion,
		 @IdProveedorEvaluado,
		 @IdProveedorEvaluador,
		 @UsuarioEvaluador,
		 GETDATE(),
		 1
         )
		 IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
END


