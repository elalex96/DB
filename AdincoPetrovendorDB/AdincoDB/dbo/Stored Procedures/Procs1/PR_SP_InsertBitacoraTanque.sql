
CREATE PROCEDURE PR_SP_InsertBitacoraTanque
@TanqueId	int,
@UsuarioId	int,
@Accion VARCHAR(250)
AS
BEGIN
		INSERT INTO PR_TanqueBitacora(Accion,CreadoPor,CreadoEl,TanqueId,Clave,Nombre,Descripcion,Estatus,Estacion,
					Capacidad,Producto,Diametro,Altura,Constante,PctNoBombeable,VolNoBombeable,PctMaximo,VolMaximo,PorcentajeAgua,
					ProductoAlmacenado,IdTipoTanque,MedicionManual,PuntoEntregaID,Activo)
		SELECT @Accion,@UsuarioId,GETDATE(),Id,Clave,Nombre,Descripcion,Estatus,Estacion,
				Capacidad,Producto,Diametro,Altura,Constante,PctNoBombeable,VolNoBombeable,PctMaximo,VolMaximo,PorcentajeAgua,
				ProductoAlmacenado,IdTipoTanque,MedicionManual,PuntoEntregaID ,Activo
			FROM 
				PR_Tanque 
			WHERE 
				Id = @TanqueId;
END