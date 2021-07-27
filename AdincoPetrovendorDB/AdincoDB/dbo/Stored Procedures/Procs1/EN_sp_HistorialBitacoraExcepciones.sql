DROP PROCEDURE IF EXISTS EN_sp_HistorialBitacoraExcepciones
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 27/02/2021
-- Description:	<OBTIENE LA BITACORA DE EXCEPCIONES>
-- =============================================
go
CREATE PROCEDURE EN_sp_HistorialBitacoraExcepciones
@IdContrato int,
@IdUsuario int = null
AS
BEGIN
	SELECT 
	exb.IdInstanciaEntregable as ID,
	e.DocumentoEntregable as Entregable,
	exb.FechaCalculadaEntregaRegAnterior as FechaCalculadaAnterior,
	u.Nombre as Usuario,
	exb.FechaMovimiento
	FROM EN_ExcepcionesFechaBitacora exb
	JOIN EN_InstanciasEntregable ie 
	ON exb.IdInstanciaEntregable = ie.idInstanciaEntregable
	JOIN EN_ContratoEntregable ce
	ON ie.IdContratoEntregable = ce.IdContratoEntregable
	JOIN EN_Entregable e 
	ON ce.IdEntregable = e.IdEntregable
	JOIN AP_Usuario u 
	ON exb.UsuarioId = u.UsuarioID
	where exb.ContratoId = @IdContrato
	order by IdExcepcionBitacora desc
END
