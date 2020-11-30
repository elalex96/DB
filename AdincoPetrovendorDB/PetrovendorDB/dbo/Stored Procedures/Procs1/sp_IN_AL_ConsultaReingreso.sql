
-- sp_IN_AL_ConsultaReingreso 1,0
create Proc [dbo].[sp_IN_AL_ConsultaReingreso]
@pIdAlmacen int,
@pTipo int, --0 todos, 1 autorizados, 2 pendientes,
@pTipoRegistro int --1 con referencia 2 sin referencia
as

	SELECT *,
	EsReingresoSinRef=ReingresSinRef
	FROM [IN_AL_Movimiento] m1
	--left join vw_IN_AL_Movimientos m2 on m2.idMovimiento = m1.IdMovimiento and m2.EsReingresoSinRef = 1
	where m1.IdTipoMovimiento = 3  and
	m1.IdAlmacen = @pIdAlmacen and m1.isEliminado = 0 and
	(
		@pTipo = 0 OR
		(@pTipo = 1  AND isnull(m1.IdUsuarioAutorizo,0) > 0 ) OR
		(@pTipo = 2  AND isnull(m1.IdUsuarioAutorizo,0) = 0 )
	)and
	(
		(@pTipoRegistro = 1 and isnull(m1.ReingresSinRef,0) =0)
		OR
		(@pTipoRegistro = 2 and isnull(m1.ReingresSinRef,0) =1)
	)

	order by m1.FechaMovimiento desc
