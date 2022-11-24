
-- sp_IN_AL_Rpt_FichaRecepcionMat 1
Create Proc [dbo].[sp_IN_AL_Rpt_FichaRecepcionMat]
@pIdMovimiento int
As

	select Folio = Folio,
		EntregadoEn = EntregadoEn,
		Fecha = FechaMovimiento,
		mov.RecibidoEn,
		mov.Cantidad,
		mov.Unidad,
		mov.IdMaterial,
		DescripcionMat = rtrim(mov.MaterialDes) + rtrim(mov.MaterialDesLarga),
		mov.Comentarios,
		mov.Autorizo,
		mov.Atendio,
		mov.IdPedido
	from [dbo].[vw_IN_AL_Movimientos] mov
	where IdMovimiento = @pIdMovimiento and
	mov.IdTipoMovimiento = 1 --Solo Recepcion
	order by mov.MaterialDes
