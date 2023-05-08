-- =============================================
-- Author:		Daniel AC
-- Create date: 19/01/2022
-- Description:	Optimizacion
-- =============================================
CREATE PROCEDURE [dbo].[EN_sp_HistorialBitacoraExcepciones]
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
	FROM EN_ExcepcionesFechaBitacora exb (NOLOCK)
	JOIN EN_InstanciasEntregable ie (NOLOCK)
		ON exb.IdInstanciaEntregable = ie.idInstanciaEntregable
	JOIN EN_ContratoEntregable ce (NOLOCK)
		ON ie.IdContratoEntregable = ce.IdContratoEntregable
	JOIN EN_Entregable e (NOLOCK)
		ON ce.IdEntregable = e.IdEntregable
	JOIN AP_Usuario u (NOLOCK)
		ON exb.UsuarioId = u.UsuarioID
	where exb.ContratoId = @IdContrato
	order by IdExcepcionBitacora desc
END