CREATE PROCEDURE AP_sp_ProveedoresBloqueadosCargaFactura --907
@IdProveedor int
AS
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
	where IdProveedor = @IdProveedor
	group by IdProveedorBloqueado
-- SE INSERTAN LOS ULTIMOS REGISTROS 
	insert into #TFechasUltimas (
	IdProveedor,						Fecha,		Bloqueado)
	SELECT tf.IdProveedorBloqueado ,	tf.Fecha,	bf.Bloqueado 
	FROM #TFechasProveedores tf
	join AP_BitacoraBloqueoFactura bf 
	on tf.IdProveedorBloqueado = bf.IdProveedorBloqueado and tf.Fecha = bf.CreadoEl
	-----------------------------
	--SE SELECCIONAN LOS BLOQUEADOS 
	select  bbf.Id Folio,
			pr.IdProveedor, 
			pr.RazonSocial, 
			pr.RFC,
			ultimas.Fecha FechaBloqueo ,
			u.Nombre BloqueadoPor,
			bbf.Motivo
			from #TFechasUltimas ultimas
	JOIN S_Proveedor pr
	ON ultimas.IdProveedor = pr.IdProveedor
	JOIN AP_BitacoraBloqueoFactura bbf
	ON ultimas.Fecha = bbf.CreadoEl and ultimas.IdProveedor = bbf.IdProveedorBloqueado
	JOIN S_Usuario u
	ON bbf.CreadoPor = u.IdUsuario
	where bbf.Bloqueado = 1
	order by pr.RazonSocial asc
END
--AP_sp_ProveedoresBloqueadosCargaFactura 907