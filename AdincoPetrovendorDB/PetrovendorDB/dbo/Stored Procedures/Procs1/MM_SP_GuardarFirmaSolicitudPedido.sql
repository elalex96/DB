
--**************************************************************--
-- Creado por:      <Jose Roman>								--
-- Updated date: <07/01/2018>									--
-- Description: <Se guarda la Firma electronica en MM_SolicitudPedido>			--
--**************************************************************--

CREATE procedure MM_SP_GuardarFirmaSolicitudPedido
	@IdSolicitudPedido INT,
	@Firma NVARCHAR(MAX),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/

AS
BEGIN
	UPDATE dbo.MM_SolicitudPedido
	SET IdFirma = @Firma
	WHERE IdSolicitudPedido = @IdSolicitudPedido
END
