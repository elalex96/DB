
-- =============================================
-- Author:		Alexander G
-- Create date: 29-06-17
-- Description: Consulta los datos de la evaluacion por usuario
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_ConsultarEvaluacionUsuario] 
	-- Add the parameters for the stored procedure here
		@IdProveedor int,
		@ProveedorEvaluado int,
		@IdUsuario int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @ReseniaF int

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 
	 SELECT P.RazonSocial, P.Alias,ISNULL(Evaluacion, 0) AS Evaluacion, Resenia, FechaEvaluacion 
	 FROM DG_EvaluacionComercial_Proveedor
	 LEFT JOIN S_Proveedor AS P ON P.IdProveedor = IdProveedorEvaluado
	 WHERE IdProveedorEvaluador = @IdProveedor AND IdProveedorEvaluado = @ProveedorEvaluado AND IdUsuarioEvaluador = @IdUsuario

END



