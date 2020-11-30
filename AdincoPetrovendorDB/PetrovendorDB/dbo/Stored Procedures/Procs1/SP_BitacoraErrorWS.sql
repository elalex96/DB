-- =============================================
-- Author: Pedro Acu�a
-- Create date: 28/04/2018
-- Description: se registran en caso de error en la bitacora
-- =============================================

CREATE PROCEDURE SP_BitacoraErrorWS
	( @HResult INT ,
	  @Mensaje NVARCHAR(MAX) ,
	  @StackTrace NVARCHAR(MAX) ,
	  @IdUsuario INT ,
	  @IdProveedor INT
)
AS
	BEGIN
		DECLARE @valorInsertado INT

		INSERT INTO Adinco.dbo.MA_WS_BitacoraErrores
			( HResult, Mensaje, StackTrace, IdUsuario, IdSubcontratista, IdContrato, FechaRegistro )
		VALUES
			( @HResult ,	-- HResult - int
			  @Mensaje ,	-- Mensaje - nvarchar(max)
			  @StackTrace , -- StackTrace - nvarchar(max)
			  @IdUsuario ,	-- IdUsuario - int
			  0 ,			-- IdSubcontratista - int
			  0 ,			-- IdContrato - int
			  GETDATE ()	-- FechaRegistro - datetime
		)

		SELECT	@valorInsertado = @@IDENTITY

		SELECT	CONCAT ( CONVERT ( NVARCHAR(255), ABS ( @HResult )), '-', IdError )
		FROM	Adinco.dbo.MA_WS_BitacoraErrores
		WHERE	IdError = @valorInsertado
	END
--------------------------------------------------------------------------------------------------------------
