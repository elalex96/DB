
-- =============================================
-- Author:		<Alexander G>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CantDocSitemaGestion]
	-- Add the parameters for the stored procedure here
@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	DECLARE @ISO14000 INT = (SELECT COUNT(*) FROM [dbo].[PV_SistemaGestion] WHERE IdProveedor = @IdProveedor AND IdTipoDocSG = 1 AND Activo = 1)
	DECLARE @ISO18000 INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND IdTipoDocSG = 2 AND Activo = 1)
	DECLARE @CESR INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND IdTipoDocSG = 3 AND Activo = 1)
	DECLARE @PCP INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND IdTipoDocSG = 4 AND Activo = 1)
	DECLARE @OTRA INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND IdTipoDocSG = 5 AND Activo = 1)
	DECLARE @ISO900 INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND IdTipoDocSG = 6 AND Activo = 1)
	DECLARE @CIL INT = (SELECT COUNT(IdSistemaGestion) FROM PV_SistemaGestion WHERE IdProveedor = @IdProveedor AND IdTipoDocSG = 7 AND Activo = 1)
	DECLARE @DOCUCAR INT = (@ISO14000+@ISO18000+@CESR+@PCP+@CIL+@ISO900)
	IF @OTRA >= 1
	BEGIN
		SET @DOCUCAR = @DOCUCAR + 1
	END

	DECLARE @DOCUREST INT = (7 - @DOCUCAR)

	SELECT @ISO14000 AS ISO1400, @ISO18000 AS ISO18000, @CESR AS CESR, @PCP AS PCP, @OTRA AS OTRA, @DOCUCAR AS DOCUMENTOSCARGADOS, @DOCUREST AS DOCUMENTOSRESTANTES, @ISO900 AS ISO900, @CIL AS CIL
END

