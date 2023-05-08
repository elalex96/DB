CREATE PROCEDURE PR_SP_InsertBitacoraSistemaMedicion
@IdSistema	int,
@UsuarioId	int,
@Accion VARCHAR(250)
AS
BEGIN
INSERT INTO PR_SistemasMedicionBitacora(
			Accion,
			CreadoPor,
			CreadoEl,
			IdSistema,IdTipoSistema,Marca,Modelo,NoSerie,TAG,Activo,TipoMedidor,IdContrato
		)SELECT @Accion,@UsuarioId,GETDATE(),IdSistema,IdTipoSistema,Marca,Modelo,NoSerie,TAG,Activo,TipoMedidor,IdContrato
			FROM PR_SistemasMedicion Where IdSistema = @IdSistema;
END