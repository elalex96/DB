
-- =============================================
-- Author:		Alexander G
-- Create date: 29-06-17
-- Description: Consulta los datos de la evaluacion por usuario
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_EvaluacionProveedor] 
	-- Add the parameters for the stored procedure here
		@IdProveedor int,
		@ProveedorEvaluado int,
		@IdUsuario int,
		@Evaluacion int,
		@Resenia nvarchar(MAX)
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @ReseniaF int

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SET @ReseniaF = (
	 SELECT IdEvaluacionProveedor FROM DG_EvaluacionComercial_Proveedor
	 WHERE 
		IdProveedorEvaluador = @IdProveedor AND 
		IdProveedorEvaluado = @ProveedorEvaluado AND 
		IdUsuarioEvaluador = @IdUsuario
	 )

	 IF @ReseniaF IS NULL
	 BEGIN
		 INSERT INTO DG_EvaluacionComercial_Proveedor (
		 IdProveedorEvaluado,
		 IdProveedorEvaluador,
		 Evaluacion,
		 IdUsuarioEvaluador,
		 Resenia,
		 FechaEvaluacion,
		 ModificadoEl,
		 ModificadoPor
		 )
		 VALUES
		 (
		 @ProveedorEvaluado,
		 @IdProveedor,
		 @Evaluacion,
		 @IdUsuario,
		 @Resenia,
		 GETDATE(),
		 GETDATE(),
		 @IdUsuario
		 )
		 SELECT 'Evaluacion Enviada Exitosamente' AS Respose
	 END

	 IF @ReseniaF > 0
	 BEGIN
		UPDATE DG_EvaluacionComercial_Proveedor
		SET
			Evaluacion = @Evaluacion,
			Resenia = @Resenia,
			ModificadoEl = GETDATE(),
			ModificadoPor = @IdUsuario
			WHERE	IdProveedorEvaluado = @ProveedorEvaluado AND
					IdProveedorEvaluador = @IdProveedor AND
					IdUsuarioEvaluador = @IdUsuario
			SELECT 'Evaluacion Enviada Exitosamente' AS Respose
	 END
END



