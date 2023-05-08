-- =============================================
-- Author:		ABEL R
-- Create date: 08-01-2018
-- Description:	CONSULTA IMAGENES 
-- =============================================
CREATE PROCEDURE [dbo].[SP_ImagenesMaterialExistentes]
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


	SELECT
	IdMaterial,Imagen
	FROM dbo.MM_Material
	WHERE (LEN(Imagen) > 1 AND Imagen IS NOT NULL)


END
