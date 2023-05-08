
create Proc [dbo].[sp_IN_AL_Det_ConsultarDocumentos]
@pIdMovimientoDetalle int
As

	select IdMovimientoDetalleDoc,
			IdMovimientoDetalle,
			--Documento,
			FileName,
			CreadoPor,
			CreadoEl
	from IN_AL_MovimientoDetalleDoc
	where IdMovimientoDetalle = @pIdMovimientoDetalle
