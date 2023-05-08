
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <>
-- Description:	<>
-- =============================================

CREATE PROCEDURE MM_SP_ConsultaMaterialesModificacionOferta	
	@IdPeticionOferta INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT pod.IdPeticionOfertaDetalle, pod.MaterialCotizadoTextoC, pod.MaterialCotizadoTextoL, pod.FechaVigencia
	FROM dbo.MM_PeticionOfertaDetalle pod
	WHERE pod.IdPeticionOferta = @IdPeticionOferta
END