-- =============================================
-- Author:		Pedro Acuña
-- Create date: 11/07/2018
-- Description:	ahora la aprobacion es por cada pedido y no una aprobacion para todos los pedidos generados
-- =============================================

CREATE PROCEDURE SP_ObtenerAprobadoresxIdFlujo @IdFlujoTarea INT
AS
	BEGIN
		SELECT		ROW_NUMBER() OVER (ORDER BY NoSecuencia)AS Fila, ft.Nombre, NoSecuencia, u.Nombre AS NomUsuario, u.Correo, TFT.Nombre AS TipoFlujo
		FROM		dbo.TA_FlujoTarea ft
		LEFT JOIN	dbo.TA_Aprobador
			ON TA_Aprobador.IdFlujoTarea = ft.IdFlujoTarea
		LEFT JOIN	dbo.S_Usuario u
			ON u.IdUsuario = TA_Aprobador.IdUsuario
		LEFT JOIN	TA_TipoFlujoTarea TFT
			ON TFT.IdTipoFlujoTarea = ft.IdTipoFlujo
		WHERE		ft.IdFlujoTarea = @IdFlujoTarea
	END
