USE Petrovendor
GO
--Modifier: Luis David
-- Modifier date: 24-06-2021
-- Description: extrae los proveedores con los que el proveedor ha tenido interaccion
DROP PROCEDURE IF EXISTS AP_sp_ProveedoresProveedor
go
CREATE PROCEDURE AP_sp_ProveedoresProveedor
@IdProveedor int
as
BEGIN 
-- SE CREA UNA TABLA TEMPORAL PARA OBTENER LAS FECHAS DE ULTIMA MODIFICACION DE CADA PROVEEDOR BLOQUEADO
	DROP TABLE IF EXISTS #TFechasProveedores
	DROP TABLE IF EXISTS #TFechasUltimas
	CREATE TABLE #TFechasProveedores
	(
		IdProveedorBloqueado int,
		Fecha Datetime
	)
	CREATE TABLE #TFechasUltimas
	(
		IdProveedor int,
		Fecha datetime,
		Bloqueado Bit
	)
-- SE INSERTAN LOS REGISTROS
	insert into #TFechasProveedores
	SELECT  
	IdProveedorBloqueado,
	MAX(CreadoEl) MaxDate
	FROM    AP_BitacoraBloqueoFactura 
	group by IdProveedorBloqueado
-- SE INSERTAN LOS ULTIMOS REGISTROS 
	insert into #TFechasUltimas (
	IdProveedor,						Fecha,		Bloqueado)
	SELECT tf.IdProveedorBloqueado ,	tf.Fecha,	bf.Bloqueado 
	FROM #TFechasProveedores tf
	join AP_BitacoraBloqueoFactura bf 
	on tf.IdProveedorBloqueado = bf.IdProveedorBloqueado and tf.Fecha = bf.CreadoEl
--- SE SELECCIONAN TODOS LOS LOS PROVEEDORES YA CON SU COLUMNA DE BLOQUEO
	SELECT 
	distinct 
	pr.IdProveedor,pr.RazonSocial,pr.RFC, ISNULL(bf.Bloqueado,0) AS Bloqueado
	from MM_Pedido p
	join S_Proveedor pr 
	on p.IdSubcontratista = pr.IdProveedor
	left join #TFechasUltimas bf
	on pr.IdProveedor = bf.IdProveedor
	where 
	p.IdProveedorCompras = @IdProveedor
	AND
	pr.IdNacionalidad = 1
	AND
	ISNULL(pr.IsEliminado,0) = 0
	AND
	ISNULL(bf.Bloqueado,0) = 0
	AND 
	ISNULL(P.IdEliminado,0) = 0
	AND 
	ISNULL(P.IdEstatusEliminado,0) = 0
	order by pr.RazonSocial asc
END

--EXEC AP_sp_ProveedoresProveedor 907