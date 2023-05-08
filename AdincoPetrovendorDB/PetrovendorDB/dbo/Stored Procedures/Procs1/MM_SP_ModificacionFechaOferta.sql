
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <>
-- Description:	<>
-- =============================================

CREATE PROCEDURE MM_SP_ModificacionFechaOferta	
	@IdPeticionOfertaDetalle INT,
	@FechaVigencia DATETIME,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	UPDATE dbo.MM_PeticionOfertaDetalle
	SET FechaVigencia = @FechaVigencia
	WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
END