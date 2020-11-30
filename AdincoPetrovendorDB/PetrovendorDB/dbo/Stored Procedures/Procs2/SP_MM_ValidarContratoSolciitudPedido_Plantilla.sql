-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <25/11/2019>
-- Description:	<Validacion al cargar plantilla de una solciitud de pedido por contrato>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ValidarContratoSolciitudPedido_Plantilla]
	-- Add the parameters for the stored procedure here
	@IdPlantillaSolicitudPedido INT,
	@IdContrato INT,
	@IdUsuario INT,
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IDEXISTENTE INT = (SELECT
									COUNT(IdPlantillaSolicitudPedido)
								FROM dbo.MM_Plantillas_SolicitudPedido
								WHERE IdPlantillaSolicitudPedido = @IdPlantillaSolicitudPedido
									AND IdContrato = @IdContrato
									AND IdProveedor = @IdProveedor
									AND IdUsuarioSolicitante = @IdUsuario
								GROUP BY IdPlantillaSolicitudPedido);
    -- Insert statements for procedure here

	IF ISNULL(@IDEXISTENTE,0) > 0
	BEGIN
	    SELECT 'TRUE' AS RESPONSE
	END
	ELSE
	BEGIN
	    SELECT 'FALSE' AS RESPONSE
	END
END
