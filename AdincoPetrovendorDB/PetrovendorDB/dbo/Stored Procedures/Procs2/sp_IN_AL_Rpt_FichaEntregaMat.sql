
-- sp_IN_AL_Rpt_FichaEntregaMat 2
Create Proc [dbo].[sp_IN_AL_Rpt_FichaEntregaMat]
@pIdMovimiento int
As

	select Folio = Folio,
		EntregadoEn = EntregadoEn,
		Fecha = FechaMovimiento,
		EntregadoA = EntregadoA,
		mov.Cantidad,
		mov.Unidad,
		mov.IdMaterial,
		DescripcionMat = rtrim(mov.MaterialDes) + rtrim(mov.MaterialDesLarga),
		mov.Comentarios,
		mov.Autorizo,
		mov.Atendio
	from [dbo].[vw_IN_AL_Movimientos] mov
	where IdMovimiento = @pIdMovimiento and
	mov.IdTipoMovimiento = 2 --Solo Entrega
	order by mov.MaterialDes
