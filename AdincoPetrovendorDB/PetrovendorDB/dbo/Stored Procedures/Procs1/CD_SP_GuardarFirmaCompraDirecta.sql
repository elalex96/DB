
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09-01-2018>
-- Description:	<Guarda la firma electronica por IdOperacion
-- =============================================

CREATE procedure CD_SP_GuardarFirmaCompraDirecta
	@IdOperacion INT,
	@Firma NVARCHAR(35),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    --@IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
  /*---------------------------------------------------------------*/ 

AS
BEGIN
	UPDATE dbo.TA_Operacion
		SET IdFirma = @Firma
		WHERE IdOperacion = @IdOperacion
END
