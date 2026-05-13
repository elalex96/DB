-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12/02/2018>
-- Description:	<Consultar Matriz>
-- =============================================

CREATE PROCEDURE ME_ConsultaMatriz
	@IdProveedorEvaluador int
as 
begin
	select me.IdMatrizEvaluacion as Id, tp.Nombre as IdTipoEvaluacion, me.Nombre, me.Descripcion
	from ME_MatrizEvaluacion me
	inner join ME_TiposMatriz tp on tp.IdTipoEvaluacion=me.IdTipoEvaluacion
	where me.IdProveedorEvaluador= @IdProveedorEvaluador
	AND (me.Activo = 1 OR me.Activo IS NULL)
END

