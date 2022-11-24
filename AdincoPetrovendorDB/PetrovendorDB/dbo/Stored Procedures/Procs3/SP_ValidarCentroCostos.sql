-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarCentroCostos]
@IdNumero NVARCHAR(10),
@IdProveedor INT
--@NombreCentro INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @NUMERO_EXISTENTE INT
	SET  @NUMERO_EXISTENTE = (SELECT COUNT (numero) FROM CC_CentroCosto 
	                          WHERE numero = @IdNumero AND 
							  IdProveedor = @IdProveedor AND
							  IsActivo = 1
							  )
	
	IF (@NUMERO_EXISTENTE > 0)
	BEGIN
	SELECT 'YA_EXISTE'
	END
	IF (@NUMERO_EXISTENTE = 0)
	BEGIN
	SELECT 'NUEVO_CENTRO_COSTOS'
	END
END

