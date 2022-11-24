-- =============================================
-- Author: Pedro Acu�a
-- Create date: 27/04/2018
-- Description: se registra la operacion donde se deriba todo
-- =============================================

CREATE PROCEDURE SP_MA_WSAgregarAprobadorCabecera @IdDocumento INT, @IdUsuarioRegistro INT ,
												  @FechaFinalizacion DATETIME, @IdContrato INT ,
												  @ComentarioGral NVARCHAR(MAX), @TipoAprobacion INT ,
												  @IdTipoOperacion INT, @IdLineaTiempo INT ,
												  @NombreInstancia NVARCHAR(MAX), @IdApp INT
AS
	BEGIN
		SET DATEFORMAT DMY
		INSERT INTO Adinco.dbo.MA_Operacion
			( IdDocumento, IdLineaTiempo, IdEstatusOperacion, IdContrato, IdUsuarioRegistro, FechaRegistro ,
			  ComentarioGral , FechaModificacion, FechaFinalizacion, ModificadoPor, IdTipoAprobacion, IdTipoOperacion ,
			  NombreInstancia , IdApp )
		VALUES
			( @IdDocumento ,		-- IdDocumento - int
			  @IdLineaTiempo ,		-- IdLineaTiempo - int
			  1 ,					-- IdEstatusOperacion - int -- 1 En Aprobacion
			  @IdContrato ,			-- IdContrato - int
			  @IdUsuarioRegistro ,	-- IdUsuarioRegistro - int
			  GETDATE () ,			-- FechaRegistro - datetime
			  @ComentarioGral ,		-- ComentarioGral - nvarchar(max)
			  NULL ,				-- FechaModificacion - datetime
			  @FechaFinalizacion ,	-- FechaFinalizacion - datetime
			  NULL ,				-- ModificadoPor - int
			  @TipoAprobacion ,		-- IdTipoAprobacion - int
			  @IdTipoOperacion, @NombreInstancia, @IdApp )

		SELECT 1
	END
--------------------------------------------------------------------------------------------------------------
