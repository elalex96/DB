USE Petrovendor
GO
DROP PROCEDURE IF EXISTS AP_ValidacionCargaFactura
GO
CREATE PROCEDURE AP_ValidacionCargaFactura
@IdProveedor int 
AS
BEGIN
DECLARE @Cantidad int;
DROP TABLE IF EXISTS #TTableDetalle
	CREATE TABLE #TTableDetalle
	(
		Title varchar(500),
		Body varchar(500),
		Footer varchar(500)
	)
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
	IdProveedor,				Fecha,		Bloqueado)
	SELECT 
	tf.IdProveedorBloqueado ,	tf.Fecha,	bf.Bloqueado 
	FROM #TFechasProveedores tf
	join AP_BitacoraBloqueoFactura bf 
	on tf.IdProveedorBloqueado = bf.IdProveedorBloqueado and tf.Fecha = bf.CreadoEl
-----------------------------
--SE SELECCIONAN LOS BLOQUEADOS 
	set @Cantidad = (select  distinct
			pr.IdProveedor
			from #TFechasUltimas ultimas
	JOIN S_Proveedor pr
	ON ultimas.IdProveedor = pr.IdProveedor
	JOIN AP_BitacoraBloqueoFactura bbf
	ON ultimas.Fecha = bbf.CreadoEl and ultimas.IdProveedor = bbf.IdProveedorBloqueado
	JOIN S_Usuario u
	ON bbf.CreadoPor = u.IdUsuario
	where	bbf.Bloqueado = 1
			AND 
			pr.IdProveedor = @IdProveedor)
-----------------------------
	if @Cantidad > 0
	begin
		INSERT INTO #TTableDetalle (
		Title,	
		Body,
		Footer
		)
		VALUES (
		'Para las facturas con método de pago en parcialidades o diferido (PPD), te recordamos que una vez liquidada la factura debes emitir el complemento de pago y subirlo a PetroVendor, esto a más tardar el décimo día natural del mes siguiente al que se recibió el pago, en caso de no cumplir con esta obligación tus próximos pagos serán retenidos y no podrás ingresar nuevas facturas al sistema.',
		'Actualmente no puedes subir facturas a Petrovendor para Wintershall DEA, debido a un bloqueo por solicitud del área financiera.',
		'Por favor Ponte en contacto al siguiente correo: Invoice.Mexico@deutsche-erdoel-group.com para mayor información'
		)
	end
	select * from #TTableDetalle
END
