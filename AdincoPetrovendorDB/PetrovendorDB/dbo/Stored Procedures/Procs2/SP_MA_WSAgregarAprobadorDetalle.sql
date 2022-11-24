CREATE PROCEDURE SP_MA_WSAgregarAprobadorDetalle @IdDocumento INT, @CorreoUsuario NVARCHAR(MAX), @NoSecuencia INT ,
												 @EnlaceDetalle NVARCHAR(MAX), @EnlaceAprobado NVARCHAR(MAX) ,
												 @EnlaceRechazo NVARCHAR(MAX), @IdUsuarioRegistro INT, @IdContrato INT ,
												 @IdUsuarioTarea INT, @IdTipoOperacion INT, @IdLineaTiempo INT ,
												 @NombreUsuario NVARCHAR(MAX)
AS
	BEGIN
		SET DATEFORMAT DMY
		DECLARE @IdAprobador INT, @IdOperacion INT

		SELECT	@IdOperacion = IdOperacion
		FROM	Adinco.dbo.MA_Operacion
		WHERE
				IdDocumento = @IdDocumento
				AND IdTipoOperacion = @IdTipoOperacion
				AND IdLineaTiempo = @IdLineaTiempo

		INSERT INTO Adinco.dbo.MA_Aprobador
			( IdOperacion, NoSecuencia, IdUsuario, IdSubcontratista, IdContrato, CreadoPor, CreadoEl, ModificadoPor ,
			  ModificadoEl , Correo, EnlaceDetalle, EnlaceAprobado, EnlaceRechazo, IdLineaTiempo, IdTipoOperacion ,
			  NombreUsuario
		)
		VALUES
			( @IdOperacion ,		-- IdOperacion - int
			  @NoSecuencia ,		-- NoSecuencia - int
			  @IdUsuarioTarea ,		-- IdUsuario - int
			  NULL ,				-- IdSubcontratista - int
			  @IdContrato ,			-- IdContrato - int
			  @IdUsuarioRegistro ,	-- CreadoPor - int
			  GETDATE () ,			-- CreadoEl - datetime
			  NULL ,				-- ModificadoPor - int
			  NULL ,				-- ModificadoEl - datetime
			  @CorreoUsuario ,		-- Correo - nvarchar(150)
			  @EnlaceDetalle ,		-- EnlaceDetalle - nvarchar(max)
			  @EnlaceAprobado ,		-- EnlaceAprobado - nvarchar(max)
			  @EnlaceRechazo ,		-- EnlaceRechazo - nvarchar(max)
			  @IdLineaTiempo,
			  @IdTipoOperacion ,
			  @NombreUsuario
		)

		SELECT	@IdAprobador = @@IDENTITY

		INSERT INTO Adinco.dbo.MA_OperacionDetalle
			( IdAprobador, IdEstatus, Comentario, FechaRegistro, FechaCambioEstatus, Activo, NoSecuencia, IdOperacion ,
			  IsEliminado , IdFirma, IdContrato, IdSubcontratista, IdLineaTiempo
		)
		VALUES
			( @IdAprobador ,	-- IdAprobador - int
			  1 ,				-- IdEstatus - int
			  '' ,				-- Comentario - nvarchar(max)
			  GETDATE () ,		-- FechaRegistro - datetime
			  GETDATE () ,		-- FechaCambioEstatus - datetime
			  1 ,				-- Activo - bit
			  @NoSecuencia ,	-- NoSecuencia - int
			  @IdOperacion ,	-- IdOperacion - int
			  0 ,				-- IsEliminado - bit
			  N'' ,				-- IdFirma - nvarchar(35)
			  @IdContrato ,		-- IdContrato - int
			  NULL ,			-- IdSubcontratista - int
			  @IdLineaTiempo
		)

		SELECT	1
	END
--------------------------------------------------------------------------------------------------------------
