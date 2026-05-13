
CREATE proc [dbo].[DEA_SP_AdministrarUsuarioOBS]
@TipoConsulta NVARCHAR(MAX),
@ContratoId INT = 0,
@UsuarioId INT = 0
AS
BEGIN

	DECLARE @Contador INT = 0

	IF @TipoConsulta ='AGREGAR'
	BEGIN 
		
		SELECT @Contador=COUNT(1) 
		FROM DEA_UsuarioOBS 
		WHERE IdContrato = @ContratoId
		AND IdUsuario = @UsuarioId
			
		IF @Contador>0
		BEGIN 
			/*ACTIVAR USUARIO*/
			UPDATE DEA_UsuarioOBS
			SET Activo= 1,
			ModificadoEl = GETDATE()
			WHERE IdContrato = @ContratoId
			AND IdUsuario = @UsuarioId			
		END 
		ELSE 
		BEGIN
			/*AGREGAR USUARIO*/
			INSERT INTO DEA_UsuarioOBS(IdUsuario, IdContrato,CreadoEl,Activo)
			VALUES(@UsuarioId,@ContratoId,GETDATE(),1)
		END 
	END 

	IF @TipoConsulta ='ELIMINAR'
	BEGIN 

		/*DESACTIVAR USUARIO*/
		UPDATE DEA_UsuarioOBS
		SET Activo= 0,
		ModificadoEl = GETDATE()
		WHERE IdContrato = @ContratoId
		AND IdUsuario = @UsuarioId	

	END 
			
END
