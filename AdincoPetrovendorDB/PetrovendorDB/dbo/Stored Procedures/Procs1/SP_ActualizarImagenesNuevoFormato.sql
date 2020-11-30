-- =============================================
-- Author:		ABEL R
-- Create date: 08/01/2018
-- Description:	ACTUALIZAR IMAGEN 
-- =============================================
CREATE PROCEDURE SP_ActualizarImagenesNuevoFormato

	@ImagenReal  IMAGE,
	@ImagenThumb IMAGE,
	@IdMaterial  INT,

	/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME 
  /*--------------------
  --------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



	UPDATE dbo.MM_Material
	SET 
	Imagen_real = @ImagenReal,
	Imagen_thumb = @ImagenThumb
	WHERE IdMaterial = @IdMaterial

	SELECT 'MODIFICACION EXITOSA'

END
