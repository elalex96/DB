CREATE PROCEDURE AP_ValidacionCargaFactura  
@IdProveedor int
AS
BEGIN
-- =============================================
-- Author:  
-- Create date: 
-- Description: 
-- 20220211 BAAC    Se modifica para que el texto mostrado al usuario indique que cuenta con
--					5 dias para cargar el complemento
-- =============================================
SET NOCOUNT ON

CREATE TABLE #TTableDetalle  
(  
  Title varchar(500),  
  Body varchar(500),  
  Footer varchar(500)  
)

-- SE CREA UNA TABLA TEMPORAL PARA OBTENER LAS FECHAS DE ULTIMA MODIFICACION DE CADA PROVEEDOR BLOQUEADO  
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

DECLARE @Cantidad int;  
  
-- SE INSERTAN LOS REGISTROS  
 INSERT INTO #TFechasProveedores  
 SELECT
	 IdProveedorBloqueado,  
	 MAX(CreadoEl) MaxDate  
 FROM    AP_BitacoraBloqueoFactura   
 GROUP BY IdProveedorBloqueado  

-- SE INSERTAN LOS ULTIMOS REGISTROS   
 INSERT INTO #TFechasUltimas (  
	IdProveedor,    Fecha,  Bloqueado)  
 SELECT
	tf.IdProveedorBloqueado , 
	tf.Fecha, 
	bf.Bloqueado   
 FROM #TFechasProveedores tf  
 JOIN AP_BitacoraBloqueoFactura bf   
	 ON tf.IdProveedorBloqueado = bf.IdProveedorBloqueado 
	 AND tf.Fecha = bf.CreadoEl  
-----------------------------  
--SE SELECCIONAN LOS BLOQUEADOS   
 SET @Cantidad = (select  distinct
   pr.IdProveedor  
 FROM
	#TFechasUltimas ultimas  
 JOIN
	S_Proveedor pr  
	ON ultimas.IdProveedor = pr.IdProveedor  
 JOIN
	AP_BitacoraBloqueoFactura bbf  
	ON ultimas.Fecha = bbf.CreadoEl 
	and ultimas.IdProveedor = bbf.IdProveedorBloqueado  
 JOIN
	S_Usuario u  
	ON bbf.CreadoPor = u.IdUsuario  
 where bbf.Bloqueado = 1
   AND
   pr.IdProveedor = @IdProveedor)  
-----------------------------  
 IF @Cantidad > 0
 BEGIN
	  INSERT INTO #TTableDetalle
	  (  
		  Title,   
		  Body,  
		  Footer  
	  )  
	  VALUES (  
	  'Para las facturas con método de pago en parcialidades o diferido (PPD), te recordamos que una vez liquidada la factura debes emitir el complemento de pago y subirlo a PetroVendor, esto a más tardar el quinto día natural del mes siguiente al que se recibió el pago, en caso de no cumplir con esta obligación tus próximos pagos serán retenidos y no podrás ingresar nuevas facturas al sistema.',  
	  'Actualmente no puedes subir facturas a Petrovendor para Wintershall DEA, debido a un bloqueo por solicitud del área financiera.',  
	  'Por favor Ponte en contacto al siguiente correo: invoice.mexico@wintershalldea.com para mayor información'
	  )  
 END  
 SELECT * FROM #TTableDetalle  
END
