USE [Petrovendor]
GO
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'SP_ObtenerAprobadoresxIdFlujo')
    DROP PROCEDURE SP_ObtenerAprobadoresxIdFlujo
GO
/****** Object:  StoredProcedure [dbo].[SP_ObtenerAprobadoresxIdFlujo]    Script Date: 24/02/2026 12:31:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 11/07/2018
-- Description:	ahora la aprobacion es por cada pedido y no una aprobacion para todos los pedidos generados
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/02/2026
-- Description:	Se agrega la columna de EstatusAprobacion
-- =============================================
CREATE PROCEDURE SP_ObtenerAprobadoresxIdFlujo
    @IdFlujoTarea INT, @IdOperacion INT = 0
AS
BEGIN
    SET NOCOUNT ON;

	IF @IdOperacion = 0
	BEGIN
		
		SELECT		
			ROW_NUMBER() OVER (ORDER BY NoSecuencia)AS Fila, 
			ft.Nombre, 
			NoSecuencia, 
			u.Nombre AS NomUsuario, 
			u.Correo, 
			TFT.Nombre AS TipoFlujo
		FROM		dbo.TA_FlujoTarea ft
		LEFT JOIN	dbo.TA_Aprobador
			ON TA_Aprobador.IdFlujoTarea = ft.IdFlujoTarea
		LEFT JOIN	dbo.S_Usuario u
			ON u.IdUsuario = TA_Aprobador.IdUsuario
		LEFT JOIN	TA_TipoFlujoTarea TFT
			ON TFT.IdTipoFlujoTarea = ft.IdTipoFlujo
		WHERE		ft.IdFlujoTarea = @IdFlujoTarea
	END
	ELSE
	BEGIN
		
		SELECT 
			ROW_NUMBER() OVER (ORDER BY NoSecuencia)AS Fila, 
			TF.Nombre,
			TT.NoSecuencia, 
			U.Nombre as NomUsuario, 
			U.Correo, 
			TFT.Nombre AS TipoFlujo,
			TE.Nombre AS Estado
		FROM TA_Estatus TE
		INNER JOIN TA_Tarea TT 	ON TE.IdEstatus = TT.IdEstatus	
		INNER JOIN S_Usuario U	ON U.IdUsuario = TT.IdAprobador
		INNER JOIN TA_Operacion TAO ON TT.IdOperacion = TAO.IdOperacion
		INNER JOIN TA_FlujoTarea AS TF ON TAO.IdFlujoTarea = TF.IdFlujoTarea
		LEFT JOIN TA_TipoFlujoTarea TFT ON TFT.IdTipoFlujoTarea = TF.IdTipoFlujo
		WHERE  TAO.IdOperacion = @IdOperacion AND TAO.IdTipoOperacion = 9 
		ORDER BY TT.NoSecuencia ASC

	END

END
GO