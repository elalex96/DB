-- =============================================
-- Author: DANIEL AC 
-- Create date: 21/12/2017
-- Description:	VALIDAR QUE UNIDAD SEA DEL MATERIAL INDICADO
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ValidarUnidadMaterial_MV1_5] 
	-- Add the parameters for the stored procedure here
	@IdMaterial INT,
	@IdUnidad INT,
	@CotizacionRestringida BIT,
	/*--------------------   parametros contrato  --------------------*/
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME 
  /*----------------------------------------*/
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
	 DECLARE @ExisteUnidad INT; 
	 DECLARE @RESPONSE NVARCHAR(20);

	 SET @ExisteUnidad  = (SELECT COUNT(IdMaterial) FROM  MM_Material WHERE IdMaterial=@IdMaterial AND (IdUnidad=@IdUnidad OR IdUnidad_1= @IdUnidad OR IdUnidad_2=@IdUnidad OR IdUnidad_3=@IdUnidad))

	 IF (@CotizacionRestringida = 0)
	 BEGIN

	     IF ISNULL(@ExisteUnidad,0) > 0 
		 BEGIN
		     SET @RESPONSE = 'UNIDAD_VALIDA';
		 END
		 END
		 BEGIN
		     SET @RESPONSE = 'UNIDAD_INVALIDA';
		 END
			
	 END
	 BEGIN
	 BEGIN
	     SET @RESPONSE = 'UNIDAD_VALIDA';
	 END;

	 SELECT @RESPONSE;

 
END
